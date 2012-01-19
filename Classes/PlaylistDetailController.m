//
//  PlaylistDetailController.m
//  PhotoApp
//
//  Created by Andy on 11/3/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PlaylistDetailController.h"
#import "DBOperation.h"
#import "AnimaSelectController.h"
#import "PhotoAppDelegate.h"
#import "AmptsAlbum.h"
#import "People.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
#import "Album.h"
#import "Asset.h"
#import "timeController.h"

@implementation PlaylistDetailController
@synthesize listTable;
@synthesize textFieldCell,switchCell,tranCell,musicCell;
@synthesize tranLabel,musicLabel,state,stateButton;
@synthesize textField;
@synthesize mySwitch;
@synthesize listName,photos;
@synthesize userNames;
@synthesize selectedIndexPaths,Transtion;
@synthesize mySwc,a,playrules_idList,playIdList,orderList;
@synthesize bum,appDelegate,coreData; 
@synthesize list;
@synthesize nameList;
@synthesize al;
@synthesize PeopleRuleCell;
@synthesize OrderCell;
@synthesize SortCell;
@synthesize DateRangeCell;
@synthesize PeopleSeg;
@synthesize stopText;
@synthesize startText;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [selectedIndexPaths release];
    [musicLabel release];
    [tranLabel release];
    [mySwitch release];
    [textField release];
    [textFieldCell release];
    [switchCell release];
    [tranCell release];
    [musicCell release];
    [listTable release];
    [listName release];
    [userNames release];
    [state release];
    [a release];
    [photos release];
    [playrules_idList release];
    [playIdList release];
    [orderList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{ 
    appDelegate =[[UIApplication sharedApplication] delegate];
    keybord=NO;
    NSLog(@"AL:%@",al);
    
    
    NSEntityDescription *entity5 = [NSEntityDescription entityForName:@"PeopleRule" inManagedObjectContext:[ appDelegate.dataSource.coreData managedObjectContext]]; 
    pr1=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
   // appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=[appDelegate.dataSource.coreData managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    NSMutableArray *parray1=[[NSMutableArray alloc]init];
     NSMutableArray *parray2=[[NSMutableArray alloc]init];
    self.list=parray1;
    self.nameList=parray2;
    [parray1 release];
    [parray2 release];
    list=[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];  
    
    
    if(Transtion!=nil)
  {
      self.tranLabel.text=Transtion;
  }
    album=[[AlbumController alloc]init];
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    [backItem release];

    key=0;
    mySwc = NO;
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
    dataBase=[DBOperation getInstance];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *playArray = [[NSMutableArray alloc]init];
    NSMutableArray *IdOrderArray = [[NSMutableArray alloc]init];
    NSMutableArray *IdArray = [[NSMutableArray alloc]init];
    NSMutableArray *temArray = [[NSMutableArray alloc]init];
    self.selectedIndexPaths = temArray;
    self.userNames = tempArray;
    self.textField.delegate=self;
    [IdOrderArray release];
    [IdArray release];
    [tempArray release];
    [temArray release];
    [playArray release];
    
    if(al!=nil)
    {
        NSLog(@"album:%@",al.conPeopleRule.allOrAny);
        
        if([al.conPeopleRule.allOrAny boolValue]==YES)
        {
            NSLog(@"0wwwwww:%@",al.conPeopleRule.allOrAny);
            
        }
        else
        {
            NSLog(@"1");
            PeopleSeg.selectedSegmentIndex=1;
            
            
        }
    }
  /*  NSString *selectIdOrder=[NSString stringWithFormat:@"select id from idOrder"];
    self.orderList=[dataBase selectOrderId:selectIdOrder];
    for (id object in orderList) {
        
        [self.userNames addObject:[dataBase getUserFromUserTable:[object intValue]]];
    }
   
   NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
   [inputFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
   NSDate *formatterDate = [inputFormatter dateFromString:@"1999-07-11 at 10:30:03"];
   NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
   [outputFormatter setDateFormat:@"HH:mm 'on' EEEE MMMM d"];
   NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
   NSLog(@"newDateString %@", newDateString);
   */
    
    NSManagedObjectContext *managedObjectContext1=[appDelegate.dataSource.coreData managedObjectContext];
    NSFetchRequest *request1=[[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity1=[NSEntityDescription entityForName:@"Asset" inManagedObjectContext:managedObjectContext1];
    [request1 setEntity:entity1];
    NSError *error1;
    NSArray *A1=[[managedObjectContext1 executeFetchRequest:request1 error:&error1] mutableCopy];
    for(int i=0;i<[A1 count];i++)
    {
        Asset *ast=(Asset *)[A1 objectAtIndex:i];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *newDateString = [outputFormatter stringFromDate:ast.date];
        NSLog(@"DATE:%@",newDateString);
        
    }
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTransitionAccessoryLabel:) name:@"changeTransitionLabel" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDate:) name:@"changeDate" object:nil];
    [super viewDidLoad];
}
-(void)huyou
{
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];
    

    [self.navigationController popViewControllerAnimated:YES]; 
}
#pragma mark -
#pragma mark UITableView  method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
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
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 1;
            break;
        case 5:
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
                if(al!=nil)
                {
                    if(keybord==NO)
                    {
                self.textField.text = al.name;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"SortCell"];
        if (cell == nil) {
            cell=self.SortCell;
        }
        return cell;
        
    }
    else if(indexPath.section == 2)
    {
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
        if (cell == nil) {
            cell=self.OrderCell;
        }
        return cell;
        
    }
    else if(indexPath.section == 3)
    {
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"DateRangeCell"];
        if (cell == nil) {
            cell=self.DateRangeCell;
        }
        return cell;
        
    }
    else if(indexPath.section == 4)
    {
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"PeopleRuleCell"];
        if (cell == nil) {
            cell=self.PeopleRuleCell;
        }
        return cell;
        
    }

   else if(indexPath.section == 5) 
    {
        static NSString *cellIdentifier = @"nameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
           
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
            name.tag = indexPath.row;
            
            People *am = (People *)[list objectAtIndex:indexPath.row];
            
            name.text = [NSString stringWithFormat:@"%@ %@",am.firstName,am.lastName];
            [cell.contentView addSubview:name];
            [name release];

            UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectButton.tag = indexPath.row;
            [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.frame = CGRectMake(10, 11, 30, 30);
            [selectButton setImage:unselectImg forState:UIControlStateNormal];
            if(al!=nil)
            {                NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                [request setEntity:entity];
                
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",al.conPeopleRule];
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
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textField resignFirstResponder];
    if (indexPath.section ==0 && indexPath.row == 1) {
        AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
        animateController.tranStyle = self.tranLabel.text;
        animateController.play_id=a;
        animateController.Text=textField.text;
        [self.navigationController pushViewController:animateController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [animateController release];
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
        
        [self.navigationController pushViewController:mediaPicker animated:YES];
        [mediaPicker release];    
    }
    if (indexPath.section == 5) {
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
            [alert release];
            

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
                    }
                    else
                    {
                        [button setImage:unselectImg forState:UIControlStateNormal];
                        People *p1 = (People *)[list objectAtIndex:indexPath.row];
                        NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
                        NSFetchRequest *request = [[NSFetchRequest alloc]init];
                        [request setEntity:entity];
                        if(al==nil)
                        {
                        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
                        [request setPredicate:pre];
                        }
                        else
                        {
                            NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,al.conPeopleRule];
                            [request setPredicate:pre];
                            
                        }
                        
                        
                        NSError *error = nil;
                        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
                        PeopleRuleDetail *p=[A objectAtIndex:0];
                        
    
                        NSLog(@"peopleRULE:%d",[A count]);
                        //[p setOpcode:rule];
                         [appDelegate.dataSource.coreData.managedObjectContext deleteObject:p];
                        [appDelegate.dataSource.coreData saveContext];

                    }
                }
            }

           }
    }
  }
-(IBAction)PeopleRuleButton
{
   if(al==nil)
   {
    NSLog(@"people:%d",PeopleSeg.selectedSegmentIndex); 
    if(PeopleSeg.selectedSegmentIndex==0)
    {
        pr1.allOrAny=[NSNumber numberWithBool:YES];
    }
    else
    {
        NSLog(@"no");
        pr1.allOrAny=[NSNumber numberWithBool:NO];
    }
   }
    else
    {
        if(PeopleSeg.selectedSegmentIndex==0)
        {NSLog(@"YES");
            al.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
        }
        else
        {
            NSLog(@"no");
            al.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
        }

        
    }
    [appDelegate.dataSource.coreData saveContext];
}


-(IBAction)AddButton1
{
    NSLog(@"1");
    timeController *time=[[timeController alloc]init];
     [self.navigationController pushViewController:time animated:YES];
    

}
-(IBAction)AddButton2
{
    NSLog(@"2");
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
    [self dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}
-(void)deletes:(NSInteger)Row playId:(int)playId
{
    NSString *deleteRules= [NSString stringWithFormat:@"DELETE FROM Rules WHERE playlist_id=%d and user_id='%@'",playId,[orderList objectAtIndex:Row]];
    NSLog(@"%@",deleteRules);
    [dataBase deleteDB:deleteRules];
}


-(void)insert:(NSInteger)Row rule:(NSString *)rule
{
    People *p1 = (People *)[list objectAtIndex:Row];
    NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:[ appDelegate.dataSource.coreData managedObjectContext]]; 
    PeopleRuleDetail *prd1=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    NSLog(@"2");
    //prd1.firstName=p1.firstName;
    //prd1.lastName=p1.lastName;
    prd1.conPeople=p1;
    [p1 addConPeopleRuleDetailObject:prd1];
    prd1.opcode=rule;   
    if(al==nil)
    {NSLog(@"3");
        prd1.conPeopleRule=pr1;
        [pr1 addConPeopleRuleDetailObject:prd1];
        NSLog(@"4");
    }
    else
    {
        prd1.conPeopleRule=al.conPeopleRule;
        [al.conPeopleRule addConPeopleRuleDetailObject:prd1];
    }
    NSLog(@"insert:%@",pr1);
    NSLog(@"5");
    [appDelegate.dataSource.coreData saveContext];
    NSLog(@"6");
 }
-(void)update:(NSInteger)Row rule:(NSString *)rule
{
    People *p1 = (People *)[list objectAtIndex:Row];
    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    if(al==nil)
    {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
    [request setPredicate:pre];
    }
    else
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,al.conPeopleRule];
        [request setPredicate:pre];
    }
    NSError *error = nil;
    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
    PeopleRuleDetail *p=[A objectAtIndex:0];
    
    p.opcode=rule;
    NSLog(@"peopleRULE:%@",p);
    //[p setOpcode:rule];

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
    NSLog(@"no file");
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[button superview];
   NSIndexPath *index = [listTable indexPathForCell:cell];
    NSInteger Row=index.row;
   // int playID=0;
     ///   playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue]+1;
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
         [appDelegate.dataSource.coreData.managedObjectContext deleteObject:p];
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
    key=1;
   }
-(void)textFieldDidEndEditing:(UITextField *)textField1
{
    NSLog(@"end");
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
        [alert release];
        if(al!=nil)
        {
            textField.text=listName;
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
-(void)addPlay
{
    
  if(al==nil)
  {
  if(keybord==NO)
  {
   bum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
   bum.name=textField.text;
   //bum.byCondition=@"numOfLike";
   // bum.sortOrder=[NSNumber numberWithBool:YES];
    
      if(al==nil)
      {
          NSLog(@"people:%d",PeopleSeg.selectedSegmentIndex); 
          if(PeopleSeg.selectedSegmentIndex==0)
          {
              pr1.allOrAny=[NSNumber numberWithBool:YES];
          }
          else
          {
              NSLog(@"no");
              pr1.allOrAny=[NSNumber numberWithBool:NO];
          }
      }
      else
      {
          if(PeopleSeg.selectedSegmentIndex==0)
          {
              al.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
          }
          else
          {
              NSLog(@"no");
              al.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
          }
          
          
      }
   bum.conPeopleRule=pr1;
   pr1.conAlbum=bum;

   [appDelegate.dataSource.coreData saveContext];
    NSLog(@"BUM:%@",bum);
  }
    else
    {
        bum.name=textField.text;
        [appDelegate.dataSource.coreData saveContext];
        [appDelegate.dataSource.assetsBook removeObjectAtIndex:[appDelegate.dataSource.assetsBook count]-1];
        
    }
    AmptsAlbum * album1=[[AmptsAlbum alloc]init];
    album1.name=bum.name;
    album1.alblumId=bum.objectID;
    [appDelegate.dataSource.assetsBook addObject:album1];
  }
    else
    {
        al.name=textField.text;
        [appDelegate.dataSource.coreData saveContext];
        
    }
    
   
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
        if (path.section == 1) {
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
    if(a==nil)
    {
    NSString *deleteRules=[NSString stringWithFormat:@"delete from Rules where playList_id=%d",[[playIdList objectAtIndex:[playIdList count]-1]intValue]];
        NSLog(@"%@",deleteRules);
        [dataBase deleteDB:deleteRules];
    }
    else
    {
        NSString *deleteRules1=[NSString stringWithFormat:@"delete from Rules where playList_id=%d",[a intValue]];
        NSLog(@"%@",deleteRules1);
        [dataBase deleteDB:deleteRules1];
    }
    [selectedIndexPaths removeAllObjects];
   /* NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];*/
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
    self.startText.text=[dic objectForKey:@"Date"];
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
    a = nil;
    //dataBase = nil;
    listTable =nil;
    listName = nil;
    userNames = nil;
    state = nil;
}
@end
