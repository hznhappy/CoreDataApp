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
#import "AlbumDataSource.h"
#import "DateRule.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"

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
@synthesize AddPeopleCell;
@synthesize date;
@synthesize dateRule;
@synthesize IdList;
@synthesize sortOrderCell;
@synthesize sortSw;
@synthesize chooseCell;
@synthesize chooseButton;
@synthesize pickerView;
@synthesize sortButton;
@synthesize orderButton;
@synthesize peopleRuleButton;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle
-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}
- (void)viewDidLoad
{ 
    self.list=[[NSMutableArray alloc]init];
    self.nameList=[[NSMutableArray alloc]init];
    self.IdList=[[NSMutableArray alloc]init];
    dateList = [NSArray arrayWithObjects:@"Recent week",@"Recent two weeks",@"Recent month",@"Recent three months",@"Recent six months", @"Recent year",@"More than one year",nil];
    self.textField.autocapitalizationType =  UITextAutocapitalizationTypeWords;
    playName=@"标题";
    self.textField.placeholder=playName;
    sortSwc=NO;
    NSMutableArray *parry=[[NSMutableArray alloc]init];
    self.selectedIndexPaths=parry;
    key=0;
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if (bum != nil && bum.music != nil) {
        NSString *musicName = [NSString stringWithFormat:@"%@",bum.music];
        MPMediaPropertyPredicate *pre = [MPMediaPropertyPredicate predicateWithValue:musicName forProperty:MPMediaItemPropertyTitle];
        NSSet *set = [NSSet setWithObject:pre];
        MPMediaQuery *mediaQuery = [[MPMediaQuery alloc]initWithFilterPredicates:set];
        [musicPlayer setQueueWithQuery:mediaQuery];
    }
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
    
    
    if(date.datePeriod!=nil)
    {
        sortSwc=YES;
        sortSw.on=YES;
    }
 
   
    
    
    [self table];
    if(bum.transitType!=nil)
  {
      NSString *b=NSLocalizedString(bum.transitType, @"title");
      self.tranLabel.text=b;
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
    
    /*if(bum!=nil)
    {
       if([bum.conPeopleRule.allOrAny boolValue]==YES)
        {
        }
        else
        {
            PeopleSeg.selectedSegmentIndex=1;
        }
    }*/
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTransitionAccessoryLabel:) name:@"changeTransitionLabel" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDate:) name:@"changeDate" object:nil];
    [super viewDidLoad];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)table
{   
    //[self.list removeAllObjects];
    [self.IdList removeAllObjects];
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"favorite==%@",[NSNumber numberWithBool:YES]];
    list= [AL simpleQuery:@"People" predicate:favor sortField:@"listSort" sortOrder:YES];
    NSPredicate *ads=[NSPredicate predicateWithFormat:@"inAddressBook==%@",[NSNumber numberWithBool:YES]];
    NSArray *adsList=[AL simpleQuery:@"People" predicate:ads sortField:nil sortOrder:YES];
    [list addObjectsFromArray:adsList];
    
    for(int i=0;i<[list count];i++)
    {
        People *po=(People *)[list objectAtIndex:i];
        [self.IdList addObject:po.addressBookId];
    }
    [self.listTable reloadData];

}
-(void)album
{
    bum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
    if(textField.text==nil||[textField.text length]==0)
    {
        bum.name= textField.placeholder;
    }
    else
    {bum.name=textField.text;
    }
    bum.conPeopleRule=pr1;
    pr1.conAlbum=bum;
    bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    bum.sortKey=@"date";
    bum.sortOrder=[NSNumber numberWithBool:YES];
    //[appDelegate.dataSource.coreData saveContext];
   /* if(PeopleSeg.selectedSegmentIndex==0)
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
    }*/
}
-(void)huyou
{
    if(keybord==NO&&textField.text!=nil&&textField.text.length!=0)
    {
        NSString *text = [self.textField text];
        NSString *caplitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
        self.textField.text=caplitalized;
        if(bum==nil)
        {
            [self album];  
        }
        if(bum!=nil)
        {
            bum.name=self.textField.text;
        }
       // [self setSort];
        //[self setOrder];
    //bum.name=textField.text;
    [appDelegate.dataSource.coreData saveContext];
    }
    if(bum!=nil&&keybord==YES)
    {
        NSLog(@"1");
        if(bum.name==nil||bum.name.length==0)
        {
        [appDelegate.dataSource.coreData.managedObjectContext deleteObject:bum];
        [appDelegate.dataSource.coreData saveContext];
            bum=nil;
        }
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
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [list count];
            
            break;
        case 3:
            return 1;
            break;
        case 4:
            if(sortSwc)
            {
                return 2;
            }
            else
            {
                return 1;
            }
            break;
       /* case 4:
            return 1;
            break;*/
        case 5:
            return 2;
            break;
        case 6:
            if(mySwc)
            return 3;
            else
            return 2;
            break;
        default:
            break;
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3 && indexPath.row == 1) {
        return 216;
    }else{
        return 44;
    }
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
                   cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell"];
                   if (cell == nil) {
                       cell=self.chooseCell;
                   }
                   cell.accessoryView = [self chooseButton];
                   if(bum!=nil&&![bum.chooseType isEqualToString:PhotoVideo])
                   {
                       if ([bum.chooseType isEqualToString:Photo]) {
                           chooseButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                           [chooseButton setTitle:Photo forState:UIControlStateNormal];
                           
                           
                       }
                       else if ([bum.chooseType isEqualToString:Video]){
                           chooseButton.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
                           [chooseButton setTitle:Video forState:UIControlStateNormal];
                           
                       }
                   }
                   break;
                   default:
                   break;

                   
           }
            return cell;
    }
    else if(indexPath.section==1)
    {
        UITableViewCell *cell=nil;
        
   
        cell = [tableView dequeueReusableCellWithIdentifier:@"PeopleRuleCell"];
        if (cell == nil) {
            cell=self.PeopleRuleCell;
            cell.accessoryView=[self peopleRuleButton];
            if(bum!=nil)
            {
                if (![bum.conPeopleRule.allOrAny boolValue]) {
                    peopleRuleButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [peopleRuleButton setTitle:@"OR" forState:UIControlStateNormal];    
                }
            }
            
        }
       
       
      return cell;
    }
    else if(indexPath.section == 5)
    {
        UITableViewCell *cell = nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"SortCell"];
                if (cell == nil) {
                    cell=self.SortCell;
                     cell.accessoryView = [self sortButton];
                    if(bum!=nil&&![bum.sortKey isEqualToString:@"date"])
                    {
                                    
                       if ([bum.sortKey isEqualToString:@"numOfLike"]) {
                            sortButton.backgroundColor =[UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                            [sortButton setTitle:@"numOfLike" forState:UIControlStateNormal];
                            
                            
                        }
                       else if ([bum.sortKey isEqualToString:@"numOfTag"]) {
                        
                           sortButton.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
                            [sortButton setTitle:@"numOfTag" forState:UIControlStateNormal];
                            
                        }

                    }
                }
                
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
                if (cell == nil) {
                    cell=self.OrderCell;
                     cell.accessoryView = [self orderButton];
                    if(bum!=nil)
                    {
                        if (![bum.sortOrder boolValue]) {
                            orderButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                            [orderButton setTitle:@"DSC" forState:UIControlStateNormal];    
                        }
                    }

                }
                break;
                
            default:
                cell=nil;
                break;
                
        }
        return cell;
        
    }
       else if(indexPath.section == 4)
    {
        
        UITableViewCell *cell = nil;
        switch (rowNum) {
                case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"sortOrderCell"];
                if (cell == nil) {
                    cell=self.sortOrderCell;
                }
                break;

            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"daterule"];
                if (cell == nil) {
                    cell = self.dateRule;
                }
                break;
            default:
                cell=nil;
                break;
        
        }
        if(bum!=nil)
        {      
            [pickerView selectRow:[dateList indexOfObject:date.datePeriod] inComponent:0 animated:NO];

        }
        

        return cell;
        
    }
    else if(indexPath.section == 3)
    {
        UITableViewCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddPeopleCell"];
                if (cell == nil) {
                    cell=self.AddPeopleCell;
                }
               return cell;
        
    }
  else if(indexPath.section == 6) 
  {
      UITableViewCell *cell = nil;
      switch (rowNum) {
  case 0:
      cell = [tableView dequeueReusableCellWithIdentifier:@"transitionsCell"];
      if (cell == nil) {
          cell = self.tranCell;
      }
      break;
  case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"playMusicCell"];
      if (cell == nil) {
          cell = self.switchCell;
      }
      break;
  case 2:
      cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
      if (cell == nil) {
          cell = self.musicCell;
      }
      if (bum != nil && bum.music!=nil && bum.music.length != 0) {
          self.musicLabel.text = bum.music;
      }
      break;
  default:
      cell = nil;
      break;

  }
      return cell;
  }

   else if(indexPath.section == 2) 
    {
        
        static NSString *cellIdentifier = @"nameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
         cell.accessoryView=nil;
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
        name.tag = indexPath.row;
        name.backgroundColor = [UIColor clearColor];
        People *am =[self.list objectAtIndex:indexPath.row];
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
        [cell.contentView addSubview:selectButton];
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
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    [self.textField resignFirstResponder];
    if (indexPath.section ==6 && indexPath.row == 0) {
        if(bum==nil)
        {
            [self album];
        }
        AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
        animateController.tranStyle = self.tranLabel.text;
        animateController.Text=textField.text;
        animateController.album = bum;
        [self.navigationController pushViewController:animateController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section ==6 && indexPath.row == 1)
    {
        [textField resignFirstResponder];
    }
    if (indexPath.section ==6 && indexPath.row == 2) {
        if(bum==nil)
        {
            [self album];
        }
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = @"Select songs";
        
        [self presentModalViewController:mediaPicker animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section == 2) {
        if(bum==nil)
        {
            [self album];
        }
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
-(IBAction)PeopleRuleButton
{
    /*if(PeopleSeg.selectedSegmentIndex==0)
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
    }
     [appDelegate.dataSource.coreData saveContext];*/
}


-(IBAction)sortKeyButton
{
    /*[self setSort];
    [appDelegate.dataSource.coreData saveContext];*/
     
}
-(void)setSort
{
    
   /* if(sortSeg.selectedSegmentIndex==0)
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
        
    }*/

}
-(IBAction)sortOrderButton
{
   /* [self setOrder];
    [appDelegate.dataSource.coreData saveContext];*/
  
}
-(void)setOrder
{
   /* if(sortOrder.selectedSegmentIndex==0)
    {
        bum.sortOrder=[NSNumber numberWithBool:YES];
    }
    else
    {
        bum.sortOrder=[NSNumber numberWithBool:NO];
    }*/
}
-(IBAction)AddContacts
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate =self;
    [self presentModalViewController:picker animated:YES];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABRecordID recId = ABRecordGetRecordID(person);
   NSNumber *fid=[NSNumber numberWithInt:recId];
    if([self.IdList containsObject:fid])
    {
        NSString *b=NSLocalizedString(@"Already exists", @"button");
        NSString *a=NSLocalizedString(@"note", @"button");
        NSString *c=NSLocalizedString(@"ok", @"button");
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:a
                              message:b
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:c,nil];
        [alert show];
        alert.tag=0;
        
    }
    else
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[AL.coreData managedObjectContext]]; 
       People *addressBook=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[AL.coreData managedObjectContext]];
        addressBook.firstName=personName;
        addressBook.lastName=lastname;
        addressBook.addressBookId=[NSNumber numberWithInt:[fid intValue]];
        addressBook.inAddressBook=[NSNumber numberWithBool:YES];
        [AL.coreData saveContext];
        [self table];
        [self.listTable reloadData];
    }

    
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return 0;
}
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark media picker delegate method
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        NSArray *items = [mediaItemCollection items];
        MPMediaItem *item = [items objectAtIndex:0];
       // [musicPlayer play]; 
        //self.musicLabel.text = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        self.musicLabel.text = [item valueForProperty:MPMediaItemPropertyTitle]; 
        bum.music = self.musicLabel.text;
    }
    [mediaPicker dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [mediaPicker dismissModalViewControllerAnimated: YES];
}

#pragma mark - 
#pragma mark UIPickerView delegate method
-(void)pickerView:(UIPickerView *)pickerViews didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *selectDate = [NSString stringWithFormat:@"%@",[dateList objectAtIndex:[pickerViews selectedRowInComponent:0]]];
    date.datePeriod = selectDate;
    date.conAlbum=bum;
    bum.conDateRule=date;
    [appDelegate.dataSource.coreData saveContext];
}

#pragma mark - 
#pragma mark UIPickerView Datasource method
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [dateList count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [dateList objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 240;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
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
-(UIButton *)chooseButton{
    chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
   chooseButton.frame = CGRectMake(0, 0, 105, 28);
    [chooseButton addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    [chooseButton setTitle:PhotoVideo forState:UIControlStateNormal];
    chooseButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [chooseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return chooseButton;
}
-(UIButton *)sortButton{
    sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sortButton.frame = CGRectMake(0, 0, 105, 28);
    [sortButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
    [sortButton setTitle:@"time" forState:UIControlStateNormal];
    sortButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [sortButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return sortButton;
}
-(UIButton *)orderButton{
    orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    orderButton.frame = CGRectMake(0, 0, 105, 28);
    [orderButton addTarget:self action:@selector(order:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setTitle:@"ASC" forState:UIControlStateNormal];
    orderButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [orderButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return orderButton;
}
-(UIButton *)peopleRuleButton{
    peopleRuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    peopleRuleButton.frame = CGRectMake(0, 0, 105, 28);
    [peopleRuleButton addTarget:self action:@selector(peopleRule:) forControlEvents:UIControlEventTouchUpInside];
    [peopleRuleButton setTitle:@"AND" forState:UIControlStateNormal];
    peopleRuleButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [peopleRuleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return peopleRuleButton;
}
-(void)peopleRule:(id)sender
{
    if(bum==nil)
    {
        [self album];
    }
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"AND"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"OR" forState:UIControlStateNormal];
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
   
        

        
    }
    else if ([button.titleLabel.text isEqualToString:@"OR"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"AND" forState:UIControlStateNormal];
        bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
        
      
        
    }
      [appDelegate.dataSource.coreData saveContext];

    
}
-(void)order:(id)sender
{
    if(bum==nil)
    {
        [self album];
    }
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"ASC"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"DSC" forState:UIControlStateNormal];
         bum.sortOrder=[NSNumber numberWithBool:NO];
        
    }
    else if ([button.titleLabel.text isEqualToString:@"DSC"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"ASC" forState:UIControlStateNormal];
         bum.sortOrder=[NSNumber numberWithBool:YES];
        
    }
    [appDelegate.dataSource.coreData saveContext];
 
}
-(void)sort:(id)sender
{if(bum==nil)
{
    [self album];
}
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"time"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"numOfLike" forState:UIControlStateNormal];
        bum.sortKey=@"numOfLike";

        
    }
    else if ([button.titleLabel.text isEqualToString:@"numOfLike"]){
        button.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
        [button setTitle:@"numOfTag" forState:UIControlStateNormal];
        bum.sortKey=@"numPeopleTag";
        
    }
    else
    {
        button.backgroundColor =[UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"time" forState:UIControlStateNormal]; 
          bum.sortKey=@"date";
    }
    [appDelegate.dataSource.coreData saveContext];

}
-(void)choose:(id)sender{
    if(bum==nil)
    {
        [self album];
    }
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:PhotoVideo]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:Photo forState:UIControlStateNormal];
        bum.chooseType=@"Photo";
      
       
    }
    else if ([button.titleLabel.text isEqualToString:Photo]){
        button.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
        [button setTitle:Video forState:UIControlStateNormal];
        bum.chooseType=@"Video";
  
    }
    else
    {
        button.backgroundColor =[UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:PhotoVideo forState:UIControlStateNormal]; 
        bum.chooseType=@"Photo&Video";
    }
   // bum.name=textField.text;
    [appDelegate.dataSource.coreData saveContext];
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
   if(bum==nil)
   {
       [self album];
   }
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

    if(textField2.tag==1)
    {
        textField.placeholder=nil;
        
        if(textField.text!=nil&&textField.text.length>0)

        {
        NSString *text = [self.textField text];
        NSString *caplitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
        self.textField.text=caplitalized;
        }
    }
    
}
-(IBAction)text
{
          /* NSString *text = [self.textField text];
        NSString *caplitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
        NSLog(@"%@ uppercased is %@", text, caplitalized);
        if()
        self.textField.text=caplitalized;
    
*/
        
}
-(void)textFieldDidEndEditing:(UITextField *)textField1
{
    if(textField1.tag==1)
{
  
    if(textField.text==nil||textField.text.length==0)
    {
        textField.placeholder=playName;
       /* NSString *c=NSLocalizedString(@"note", @"title");
        NSString *b=NSLocalizedString(@"ok", @"title");
        NSString *d=NSLocalizedString(@"Rule name can not be empty!", @"title");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:c
                              message:d
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:b,nil];
        [alert show];*/
        if(bum!=nil&&keybord==NO)
        {

          textField.text=bum.name;
        }
        else
        {
            
        }

    }
    else
    {
        NSString *text = [self.textField text];
        NSString *caplitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
        NSLog(@"%@ uppercased is %@", text, caplitalized); 
        self.textField.text=caplitalized;
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
        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:6]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }else{
        [listTable beginUpdates];
        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:6]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }
}

-(IBAction)upSort:(id)sender
{
    UISwitch *newSwitcn  = (UISwitch *)sender;
    sortSwc = newSwitcn.on;
    if (newSwitcn.on) {
        [listTable beginUpdates];
        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:3],nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [listTable endUpdates];
    }else{
        bum.conDateRule = nil;
        date = nil;
        [listTable beginUpdates];
        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:3],nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [listTable endUpdates];
    }
    
}

-(IBAction)resetAll{
    if([selectedIndexPaths count]>0)
    {
    for (NSIndexPath *path in selectedIndexPaths) {
        
        if (path.section == 5) {
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
    }

}

-(IBAction)playAlbumPhotos:(id)sender{
    [musicPlayer play];
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
            }
    }
    AmptsAlbum *ampAlbum = [appDelegate.dataSource.assetsBook objectAtIndex:0];
    NSPredicate *newPre = [NSPredicate predicateWithFormat:@"self in %@",assets];
    NSArray *array = [ampAlbum.assetsList filteredArrayUsingPredicate:newPre];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:array, @"assets", self.bum.transitType, @"transition",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
}

#pragma mark -
#pragma mark Notification method
-(void)changeTransitionAccessoryLabel:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSString *labelText = [dic objectForKey:@"tranStyle"];
    self.tranLabel.text = labelText;
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
