//
//  PlaylistDetailController.m
//  PhotoApp
//
//  Created by Andy on 11/3/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PlaylistDetailController.h"
#import "AnimaSelectController.h"
#import "PhotoAppDelegate.h"
#import "AmptsAlbum.h"
#import "People.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
#import "Album.h"
#import "Asset.h"
#import "TdCalendarView.h"
#import "TestiPhoneCalViewController.h"
#import "AlbumDataSource.h"
#import "DateRule.h"

@implementation PlaylistDetailController
@synthesize listTable;
@synthesize textFieldCell,switchCell,tranCell,musicCell;
@synthesize tranLabel,musicLabel,state,stateButton;
@synthesize textField;
@synthesize mySwitch;
@synthesize selectedIndexPaths,Transtion;
@synthesize bum,appDelegate,coreData; 
@synthesize list;
@synthesize nameList;
@synthesize PeopleRuleCell;
@synthesize OrderCell;
@synthesize SortCell;
@synthesize DateRangeCell,StopDateRangeCell;
@synthesize PeopleSeg;
@synthesize stopText;
@synthesize startText;
@synthesize date;
@synthesize dateRule;
@synthesize DateSeg;
@synthesize sortSeg;
@synthesize sortOrder;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{ 
    NSMutableArray *parry=[[NSMutableArray alloc]init];
    self.selectedIndexPaths=parry;
    startText.tag=2;
    startText.delegate=self;
    stopText.tag=3;
    stopText.delegate=self;
    key=0;
    appDelegate =[[UIApplication sharedApplication] delegate];
    AL=[[AlbumDataSource alloc]init];
    AL=appDelegate.dataSource;
    keybord=NO;
    NSEntityDescription *entity5 = [NSEntityDescription entityForName:@"PeopleRule" inManagedObjectContext:[ appDelegate.dataSource.coreData managedObjectContext]]; 
    pr1=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    date = [NSEntityDescription insertNewObjectForEntityForName:@"DateRule" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    if(bum!=nil&&bum.conDateRule!=nil)
    {
        date=bum.conDateRule;
    }
    
    NSManagedObjectContext *managedObjectContext=[appDelegate.dataSource.coreData managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    NSMutableArray *parray1=[[NSMutableArray alloc]init];
     NSMutableArray *parray2=[[NSMutableArray alloc]init];
    self.list=parray1;
    self.nameList=parray2;
    list=[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];  
    
    
    if(bum.transitType!=nil)
  {
      self.tranLabel.text=bum.transitType;
  }else{
      self.tranLabel.text = nil;
  }
    album=[[AlbumController alloc]init];
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    mySwc = NO;
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];

    self.textField.delegate=self;
    self.textField.tag=1;
    
    if(bum!=nil)
    {
       if([bum.conPeopleRule.allOrAny boolValue]==YES)
        {
        }
        else
        {
            PeopleSeg.selectedSegmentIndex=1;
        }
    }
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTransitionAccessoryLabel:) name:@"changeTransitionLabel" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDate:) name:@"changeDate" object:nil];
    [super viewDidLoad];
}

-(void)album
{
    bum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    bum.conPeopleRule=pr1;
    pr1.conAlbum=bum;
    if(PeopleSeg.selectedSegmentIndex==0)
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
    }
}
-(void)huyou
{
    if(keybord==NO&&textField.text!=nil&&textField.text.length!=0)
    {
        if(bum==nil)
        {
            [self album];  
        }
    bum.name=textField.text;
    [appDelegate.dataSource.coreData saveContext];
    }
    [self.navigationController popViewControllerAnimated:YES]; 
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:bum,@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];
    
    
}
#pragma mark -
#pragma mark UITableView  method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            if (mySwc) {
                return 4;
            }
            else{
                return 3;
            }
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return [list count];
            break;
        default:
            break;
        
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowNum=indexPath.row;
   
       if (indexPath.section == 0) {
        UITableViewCell *cell = nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
                if (cell == nil) {
                    cell = self.textFieldCell;
                }
                if(bum!=nil)
                {
                    if(keybord==NO)
                    {
                self.textField.text = bum.name;
                    }
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"transitionsCell"];
                if (cell == nil) {
                    cell = self.tranCell;
                }
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"playMusicCell"];
                if (cell == nil) {
                    cell = self.switchCell;
                }
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
                if (cell == nil) {
                    cell = self.musicCell;
                }
                break;
            default:
                cell = nil;
                break;
        }
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"SortCell"];
                if (cell == nil) {
                    cell=self.SortCell;
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
                if (cell == nil) {
                    cell=self.OrderCell;
                }
                break;
            default:
                cell=nil;
                break;
                
        }
        if(bum!=nil)
        {      
            if([bum.sortKey isEqualToString:@"date"])
            {
                self.sortSeg.selectedSegmentIndex=0;
            }
            else if([bum.sortKey isEqualToString:@"numPeopleTag"])
            {
                self.sortSeg.selectedSegmentIndex=1;
            }
            else if([bum.sortKey isEqualToString:@"numOfLike"])
            {
                self.sortSeg.selectedSegmentIndex=2;
            }
            
            if([bum.sortOrder boolValue]==YES)
            {
                self.sortOrder.selectedSegmentIndex=0;
            }
            else if([bum.sortOrder boolValue]==NO)
            {
                self.sortOrder.selectedSegmentIndex=1;
            }
        }

        return cell;
        
    }
       else if(indexPath.section == 2)
    {
        
               UITableViewCell *cell = nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"dateRule"];
                if (cell == nil) {
                    cell=self.dateRule;
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"DateRangeCell"];
                if (cell == nil) {
                    cell=self.DateRangeCell;
                }
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"StopDateRangeCell"];
                if (cell == nil) {
                    cell=self.StopDateRangeCell;
                }
                break;
            default:
                cell=nil;
                break;
        
        }
        if(bum!=nil)
        {      
            if([bum.conDateRule.opCode isEqualToString:@"EXCLUDE"])
            {
                self.DateSeg.selectedSegmentIndex=1;
            }
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            
            [outputFormatter setDateFormat:@"yyyy:MM:dd"];
            if(bum.conDateRule.startDate!=nil)
            {
            NSString *startDateString= [outputFormatter stringFromDate:bum.conDateRule.startDate];
            self.startText.text=[NSString stringWithFormat:startDateString];
            }
            if(bum.conDateRule.stopDate!=nil)
            {
            NSString *stopDateString= [outputFormatter stringFromDate:bum.conDateRule.stopDate];
            self.stopText.text=[NSString stringWithFormat:stopDateString];
            }
        }
        

        return cell;
        
    }
    else if(indexPath.section == 3)
    {
        UITableViewCell *cell = nil;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"PeopleRuleCell"];
        if (cell == nil) {
            cell=self.PeopleRuleCell;
        }
        return cell;
        
    }

   else if(indexPath.section == 4) 
    {
        static NSString *cellIdentifier = @"nameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
           
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
            name.tag = indexPath.row;
            name.backgroundColor = [UIColor clearColor];
            People *am = (People *)[list objectAtIndex:indexPath.row];
            if (am.lastName.length == 0 || am.lastName == nil) {
                name.text = am.firstName;
            }
            else if(am.firstName.length == 0 || am.firstName == nil)
            {
                name.text = am.lastName;
            }
            else{
                name.text = [NSString stringWithFormat:@"%@ %@",am.lastName,am.firstName];
            }
            [cell.contentView addSubview:name];

            UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectButton.tag = indexPath.row;
            [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.frame = CGRectMake(10, 11, 30, 30);
            [selectButton setImage:unselectImg forState:UIControlStateNormal];
            if(bum!=nil)
            {                
                NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                [request setEntity:entity];
                
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",bum.conPeopleRule];
                [request setPredicate:pre];
                People *p1 = (People *)[list objectAtIndex:indexPath.row];
                NSError *error = nil;
                NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
                for(int i=0;i<[A count];i++)
                {
                PeopleRuleDetail *p=[A objectAtIndex:i];
    
            
      
            if([p.conPeople isEqual:p1])
            {
                 cell.accessoryView = [self getStateButton];
                [selectedIndexPaths addObject:indexPath];
                [selectButton setImage:selectImg forState:UIControlStateNormal];
                if([p.opcode isEqualToString:@"INCLUDE"])
                {
                    [stateButton setTitle:INCLUDE forState:UIControlStateNormal];
                    stateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
                }
                else if([p.opcode isEqualToString:@"EXCLUDE"])
                {
                    stateButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [stateButton setTitle:EXCLUDE forState:UIControlStateNormal];
                }
                
            }
              
            }
            }

            [cell.contentView addSubview:selectButton];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textField resignFirstResponder];
    [self.startText resignFirstResponder];
    [self.stopText resignFirstResponder];
    if (indexPath.section ==0 && indexPath.row == 1 && self.textField.text != nil && self.textField.text.length != 0) {
        AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
        animateController.tranStyle = self.tranLabel.text;
        animateController.Text=textField.text;
        animateController.album = bum;
        [self.navigationController pushViewController:animateController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section ==0 && indexPath.row == 2)
    {
        [textField resignFirstResponder];
    }
    if (indexPath.section ==0 && indexPath.row == 3) {
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = @"Select songs";
        
        [self presentModalViewController:mediaPicker animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section == 4) {
        if(textField.text==nil||textField.text.length==0)
        { NSString *c=NSLocalizedString(@"note", @"title");
            NSString *b=NSLocalizedString(@"ok", @"title");
            NSString *d=NSLocalizedString(@"Please fill out the rule name", @"title");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:c
                                  message:d
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:b,nil];
            [alert show];
            

        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIButton *button1 = [self getStateButton];
            if (cell.accessoryView==nil) {
                cell.accessoryView = button1;
            }else{
                cell.accessoryView = nil;
            }
            for (UIButton *button in cell.contentView.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    if ([button.currentImage isEqual:unselectImg]) {
                        [button setImage:selectImg forState:UIControlStateNormal]; 
                        NSString *rule=@"INCLUDE";
                        [self insert:indexPath.row rule:rule];
                        [selectedIndexPaths addObject:indexPath];
                    }
                    else
                    {
                        [button setImage:unselectImg forState:UIControlStateNormal];
                        People *p1 = (People *)[list objectAtIndex:indexPath.row];
                        NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
                        NSFetchRequest *request = [[NSFetchRequest alloc]init];
                        [request setEntity:entity];
                        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
                        [request setPredicate:pre];
                        NSError *error = nil;
                        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
                        PeopleRuleDetail *p=[A objectAtIndex:0];
                        [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
                        [appDelegate.dataSource.coreData saveContext];

                    }
                }
            }

           }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
-(IBAction)PeopleRuleButton
{
    if(PeopleSeg.selectedSegmentIndex==0)
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
    }
     [appDelegate.dataSource.coreData saveContext];
}
-(IBAction)DateRuleButton
{
    [self setDate];
    [appDelegate.dataSource.coreData saveContext];
}
-(void)setDate
{
    if(DateSeg.selectedSegmentIndex==0)
    {
        date.opCode=@"INCLUDE";
    }
    else
    {
        date.opCode=@"EXCLUDE";
    }
    
}

-(IBAction)sortKeyButton
{
    [self setSort];
    [appDelegate.dataSource.coreData saveContext];
     
}
-(void)setSort
{
    
    if(sortSeg.selectedSegmentIndex==0)
    {
        bum.sortKey=@"date";
    }
    else if(sortSeg.selectedSegmentIndex==1)
    {
       bum.sortKey=@"numPeopleTag";
    }
    else
    {
        bum.sortKey=@"numOfLike";
        
    }

}
-(IBAction)sortOrderButton
{
    [self setOrder];
    [appDelegate.dataSource.coreData saveContext];
  
}
-(void)setOrder
{
    if(sortOrder.selectedSegmentIndex==0)
    {
        bum.sortOrder=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.sortOrder=[NSNumber numberWithBool:NO];
    }
}
-(IBAction)AddButton1
{
    bu=YES;
    TestiPhoneCalViewController *Test=[[TestiPhoneCalViewController alloc]init];
    [self.navigationController pushViewController:Test animated:YES];
}
-(IBAction)AddButton2
{
    bu=NO;
    TestiPhoneCalViewController *Test=[[TestiPhoneCalViewController alloc]init];
    [self.navigationController pushViewController:Test animated:YES];
}
-(IBAction)DeleteButton1
{
    if(self.startText.text!=nil&&self.startText.text.length!=0)
    {
        date.startDate=nil;
        self.startText.text=nil;
    }
    [appDelegate.dataSource.coreData saveContext];
}
-(IBAction)DeleteButton2
{
    if(self.stopText.text!=nil&&self.stopText.text.length!=0)
    {
        date.stopDate=nil;
        self.stopText.text=nil;
    }
   [appDelegate.dataSource.coreData saveContext];

}
#pragma mark -
#pragma mark media picker delegate method
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play]; 
        self.musicLabel.text = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    }
    [mediaPicker dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [mediaPicker dismissModalViewControllerAnimated: YES];
}

-(void)insert:(NSInteger)Row rule:(NSString *)rule
{
    People *p1 = (People *)[list objectAtIndex:Row];
    NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:[ appDelegate.dataSource.coreData managedObjectContext]]; 
    PeopleRuleDetail *prd1=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    //prd1.firstName=p1.firstName;
    //prd1.lastName=p1.lastName;
    prd1.conPeople=p1;
    [p1 addConPeopleRuleDetailObject:prd1];
    prd1.opcode=rule;   
    prd1.conPeopleRule=bum.conPeopleRule;
    [bum.conPeopleRule addConPeopleRuleDetailObject:prd1];
    [appDelegate.dataSource.coreData saveContext];
 }
-(void)update:(NSInteger)Row rule:(NSString *)rule
{
    People *p1 = (People *)[list objectAtIndex:Row];
    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
    [request setPredicate:pre];
    NSError *error = nil;
    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
    PeopleRuleDetail *p=[A objectAtIndex:0];
    p.opcode=rule;
    [appDelegate.dataSource.coreData saveContext];
    
}
#pragma mark -
#pragma mark Coustom method
-(UIButton *)getStateButton{
  stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stateButton.frame = CGRectMake(0, 0, 75, 28);
    [stateButton addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    [stateButton setTitle:INCLUDE forState:UIControlStateNormal];
    stateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [stateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return stateButton;
}
-(void)changeState:(id)sender{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *index = [listTable indexPathForCell:cell];
    NSInteger Row=index.row;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:INCLUDE]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:EXCLUDE forState:UIControlStateNormal];
        NSString *rule=@"EXCLUDE";
        [self update:Row rule:rule];
    }
    else{
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:INCLUDE forState:UIControlStateNormal];
        NSString *rule=@"INCLUDE";
        [self update:Row rule:rule];
    }
}
-(void)setSelectState:(id)sender{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *index = [listTable indexPathForCell:cell];
    NSInteger Row=index.row;
   
     if ([button.currentImage isEqual:selectImg]) {
              [button setImage:unselectImg forState:UIControlStateNormal];
        NSIndexPath *index = [listTable indexPathForCell:cell];
        [selectedIndexPaths removeObject:index];
        cell.accessoryView = nil;
         [button setImage:unselectImg forState:UIControlStateNormal];
         People *p1 = (People *)[list objectAtIndex:Row];
         NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
         NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
         NSFetchRequest *request = [[NSFetchRequest alloc]init];
         [request setEntity:entity];
         
         NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
         [request setPredicate:pre];
         
         NSError *error = nil;
         NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
         PeopleRuleDetail *p=[A objectAtIndex:0];
         [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
         [appDelegate.dataSource.coreData saveContext];

    }else{
        [button setImage:selectImg forState:UIControlStateNormal];
        NSIndexPath *index = [listTable indexPathForCell:cell];
        [selectedIndexPaths addObject:index];
        cell.accessoryView = [self getStateButton];
        NSString *rule=@"INCLUDE";
        [self insert:index.row rule:rule];
    }
   
}
#pragma mark -
#pragma mark IBAction method
-(IBAction)hideKeyBoard:(id)sender{
    [sender resignFirstResponder];

   }
-(void)textFieldDidBeginEditing:(UITextField *)textField2
{
    if(textField2.tag==2)
    {
        bu=YES;
        TestiPhoneCalViewController *Test=[[TestiPhoneCalViewController alloc]init];
        [self.navigationController pushViewController:Test animated:YES];
    }
   else if(textField2.tag==3)
    {
        bu=NO;
        TestiPhoneCalViewController *Test=[[TestiPhoneCalViewController alloc]init];
        [self.navigationController pushViewController:Test animated:YES];
    }

    
}
-(void)textFieldDidEndEditing:(UITextField *)textField1
{
    if(textField1.tag==1)
{
  
    if(textField.text==nil||textField.text.length==0)
    {
        NSString *c=NSLocalizedString(@"note", @"title");
        NSString *b=NSLocalizedString(@"ok", @"title");
        NSString *d=NSLocalizedString(@"Rule name can not be empty!", @"title");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:c
                              message:d
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:b,nil];
        [alert show];
        if(keybord==YES)
        {

          textField.text=bum.name;
        }
        else
        {
            
        }

    }
    else
    {
        [self addPlay];
    }   
    
}
}
-(void)addPlay
{
      keybord=YES;
       if(bum==nil)
    {
        [self album];  
    }

    bum.name=textField.text;
    [appDelegate.dataSource.coreData saveContext];
}

-(IBAction)updateTable:(id)sender{
    UISwitch *newSwitcn  = (UISwitch *)sender;
    mySwc = newSwitcn.on;
    if (newSwitcn.on) {
        [listTable beginUpdates];
        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }else{
        [listTable beginUpdates];
        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }
}

-(IBAction)resetAll{
    for (NSIndexPath *path in selectedIndexPaths) {
        
        if (path.section == 4) {
            UITableViewCell *cell = [listTable cellForRowAtIndexPath:path];
            cell.accessoryView = nil;
            for (UIButton *button in cell.contentView.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    if ([button.currentImage isEqual:selectImg]) {
                        [button setImage:unselectImg forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
    [selectedIndexPaths removeAllObjects];
    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",bum.conPeopleRule];
    [request setPredicate:pre];
    NSError *error = nil;
    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
    PeopleRuleDetail *p=[A objectAtIndex:0];
    [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
    [appDelegate.dataSource.coreData saveContext];

   /* NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];*/
}

-(IBAction)playAlbumPhotos:(id)sender{
    NSMutableArray *assets = nil;
    NSPredicate *pre =  [appDelegate.dataSource ruleFormation:bum];
    if([bum.sortOrder boolValue]==YES){
        assets=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
    }else {
        assets=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:NO];
        
    }
    pre=[appDelegate.dataSource excludeRuleFormation:bum];
    if (pre!=nil) {
        NSMutableArray* excludePeople=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
        if(excludePeople!=nil) {
            [assets removeObjectsInArray:excludePeople];
            //NSLog(@"Exclude predicate : %d , %@",[excludePeople count],pre );
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:assets, @"assets", self.bum.transitType, @"transition",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
}

#pragma mark -
#pragma mark Notification method
-(void)changeTransitionAccessoryLabel:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSString *labelText = [dic objectForKey:@"tranStyle"];
    self.tranLabel.text = labelText;
}

-(void)changeDate:(NSNotification *)note{
     NSDictionary *dic = [note userInfo];
    if(bu==YES)
    {
       // self.startText.text=[dic objectForKey:@"Date"];
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone1 = [NSTimeZone timeZoneForSecondsFromGMT:0*3600]; 
        [inputFormatter setTimeZone:timeZone1];
        [inputFormatter setDateFormat:@"yyyy:MM:dd"];
        date.startDate=[inputFormatter dateFromString:[dic objectForKey:@"Date"]];
        NSDateFormatter *outFormatter=[[NSDateFormatter alloc]init];
       [outFormatter setDateFormat:@"yyyy:MM:dd"];
        NSString *startDateString= [outFormatter stringFromDate:date.startDate];
        self.startText.text=[NSString stringWithFormat:startDateString];
    }
    else
    {
    //self.stopText.text=[dic objectForKey:@"Date"];
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone1 = [NSTimeZone timeZoneForSecondsFromGMT:0*3600]; 
        [inputFormatter setTimeZone:timeZone1];
        [inputFormatter setDateFormat:@"yyyy:MM:dd"];
        date.stopDate=[inputFormatter dateFromString:[dic objectForKey:@"Date"]];
        NSDateFormatter *outFormatter=[[NSDateFormatter alloc]init];
        [outFormatter setDateFormat:@"yyyy:MM:dd"];
        NSString *stopDateString= [outFormatter stringFromDate:date.stopDate];
        self.stopText.text=[NSString stringWithFormat:stopDateString];
    }
    [self setDate];
    date.conAlbum=bum;
    bum.conDateRule=date;
    [appDelegate.dataSource.coreData saveContext];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    selectedIndexPaths = nil;
    textFieldCell = nil;
    textField = nil;
    tranCell = nil;
    tranLabel = nil;
    switchCell = nil;
    mySwitch = nil;
    musicCell = nil;
    musicLabel = nil;
    listTable =nil;
    userNames = nil;
    state = nil;
}
@end
