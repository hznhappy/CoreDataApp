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
#import "AlbumMediaTypeView.h"
#import "eventView.h"
#import "DatefilterView.h"
#import "sortOrderView.h"
#import "personfilterView.h"
#import "EffectsView.h"
#import "PeopleRuleDetail.h"




@implementation PlaylistDetailController
@synthesize listTable;
@synthesize favoriteSW;
@synthesize textField;
@synthesize selectedIndexPaths,Transtion;
@synthesize bum,appDelegate,coreData; 
@synthesize list;
@synthesize nameList;
@synthesize PersonLabel;
@synthesize DateLabel;
@synthesize SortOrder;
@synthesize date;
@synthesize IdList;
@synthesize PlayNameCell;
@synthesize TypeCell;
@synthesize MyfavoriteCell;
@synthesize PeosonCell;
@synthesize EventCell;
@synthesize SetDateCell;
@synthesize SortOrderCell;
@synthesize EffectCell;
@synthesize TypeLabel;
@synthesize EventLabel;
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
//    self.list=[[NSMutableArray alloc]init];
//    self.nameList=[[NSMutableArray alloc]init];
//    self.IdList=[[NSMutableArray alloc]init];
//    dateList = [NSArray arrayWithObjects:@"Recent week",@"Recent two weeks",@"Recent month",@"Recent three months",@"Recent six months", @"Recent year",@"More than one year",nil];
    
    appDelegate =[[UIApplication sharedApplication] delegate];
    AL=[[AlbumDataSource alloc]init];
    AL=appDelegate.dataSource;
    self.textField.autocapitalizationType =  UITextAutocapitalizationTypeWords;
    playName=@"标题";
    self.textField.placeholder=playName;
    if(bum.chooseType!=nil)
    {
        self.TypeLabel.text=bum.chooseType;
    }
    if(bum.isFavorite.boolValue)
    {
        favoriteSW.on=YES;
    }
    if(bum.conDateRule.datePeriod!=nil)
    {
        self.DateLabel.text=bum.conDateRule.datePeriod;
    }
    if(bum.sortKey!=nil)
    {
        if([bum.sortOrder boolValue])
        {
        SortOrder.text=[NSString stringWithFormat:@"%@ ASC",bum.sortKey];
        }
        else
        {
           SortOrder.text=[NSString stringWithFormat:@"%@ DSC",bum.sortKey]; 
        }
    }
    if(bum.conPeopleRule!=nil)
    {  
        NSMutableArray *peo=[[NSMutableArray alloc]init];
        NSPredicate *favor=[NSPredicate predicateWithFormat:@"conPeopleRule==%@",bum.conPeopleRule];
        NSArray *fa2 = [AL simpleQuery:@"PeopleRuleDetail" predicate:favor sortField:nil sortOrder:YES];
        for(PeopleRuleDetail *pr in fa2)
        {
            [peo addObject:pr.conPeople];
        }
        [self personLabel:peo];
       
    }
    if(bum.conEventRule.count>0)
    {
        NSMutableArray *eventname=[[NSMutableArray alloc]init];
        for(EventRule *e in bum.conEventRule)
        {
            [eventname addObject:e.conEvent.name];
        }
        [self eventLabel:eventname];

    }
    
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeType:) name:@"changeType" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePeople:) name:@"people" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDate:) name:@"changeDate" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSort:) name:@"changeSort" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeEvent:) name:@"changeEvent" object:nil];
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

    bum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:[AL.coreData managedObjectContext]];
    if(textField.text==nil||[textField.text length]==0)
    {
        bum.name= textField.placeholder;
    }
    else
    {
        bum.name=textField.text;
    }
   // bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
//    bum.sortKey=@"date";
//    bum.sortOrder=[NSNumber numberWithBool:YES];
  //bum.conPeopleRule=pr1;
    //pr1.conAlbum=bum;
    bum.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    bum.sortKey=@"date";
    bum.sortOrder=[NSNumber numberWithBool:YES];
    //bum.transitType=nil;
   [appDelegate.dataSource.coreData saveContext];
    
//    NSEntityDescription *entity5 = [NSEntityDescription entityForName:@"PeopleRule" inManagedObjectContext:[ appDelegate.dataSource.coreData managedObjectContext]]; 
//    pr1=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
//    bum.conPeopleRule=pr1;
//    pr1.conAlbum=bum;
    
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
    if(bum!=nil)
    {
        if(textField.text==nil||[textField.text length]==0)
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
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 4;
        case 3:
            return 1;
            break;
        default:
            break;
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 4 && indexPath.row == 1) {
//        return 216;
//    }else{
        return 44;
   // }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowNum=indexPath.row;
    if(indexPath.section==0)
    {
         UITableViewCell *cell=nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"PlayNameCell"];
        if (cell == nil) {
            cell = self.PlayNameCell;
        }
        if(bum!=nil)
        {
            if(keybord==NO)
            {
                self.textField.text = bum.name;
            }
        }

        return cell;

    }
    
    else if(indexPath.section==1)
    {
        UITableViewCell *cell=nil;
        switch (rowNum) {
                case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"];
                if (cell == nil) {
                    cell = self.TypeCell;
                }
                break;
              case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"MyfavoriteCell"];
                if (cell == nil) {
                    cell = self.MyfavoriteCell;
//                    cell.accessoryView = [self chooseButton];
                     cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                
            default:
                break;
        }
        return cell;
    }
    else if(indexPath.section==2)
    {
        UITableViewCell *cell=nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"PeosonCell"];
                if (cell == nil) {
                    cell = self.PeosonCell;
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
                if (cell == nil) {
                    cell = self.EventCell;
                }
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"SetDateCell"];
                if (cell == nil) {
                    cell = self.SetDateCell;
                }
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:@"SortOrderCell"];
                if (cell == nil) {
                    cell = self.SortOrderCell;
                }
                break;
                
            default:
                break;
        }
        return cell;

    }
    else if(indexPath.section==3)
    {
        UITableViewCell *cell=nil;
       
                cell = [tableView dequeueReusableCellWithIdentifier:@"EffectCell"];
                if (cell == nil) {
                    cell = self.EffectCell;
                }
                    return cell;
               

    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
if(bum==nil)
{
    [self album];
}
    [self.textField resignFirstResponder];
    if (indexPath.section ==1 && indexPath.row == 0) {
        AlbumMediaTypeView *type=[[AlbumMediaTypeView alloc]init];
//        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:type];
//        [self.navigationController presentModalViewController:navController animated:YES];
//
        type.album=bum;
        type.chooseType=self.TypeLabel.text;
        [self.navigationController pushViewController:type animated:YES];
        
    }
    
    else if(indexPath.section==2 && indexPath.row==0)
    {
       // personfiter *person=[[personfiter alloc]init];
        personfilterView *person=[[personfilterView alloc]init];
        person.album=bum;
        [self.navigationController pushViewController:person animated:YES];
    }
    else if(indexPath.section==2 && indexPath.row==1)
    {
        eventView *evevnt=[[eventView alloc]init];
        evevnt.album=bum;
        [self.navigationController pushViewController:evevnt animated:YES];
    }
    else if(indexPath.section==2 && indexPath.row==2)
    {
        DatefilterView *dateA=[[DatefilterView alloc]init];
        dateA.album=bum;
        [self.navigationController pushViewController:dateA animated:YES];
    }
    else if(indexPath.section==2 && indexPath.row==3)
    {
        sortOrderView *sort=[[sortOrderView alloc]init];
        sort.album=bum;
        [self.navigationController pushViewController:sort animated:YES];
    }
    else if(indexPath.section==3)
    {
        EffectsView *effect=[[EffectsView alloc]init];
        effect.album=bum;
        [self.navigationController pushViewController:effect animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        if(bum==nil)
//        {
//            [self album];
//        }
//        AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
//        animateController.tranStyle = self.tranLabel.text;
//        animateController.Text=textField.text;
//        animateController.album = bum;
//        [self.navigationController pushViewController:animateController animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    if (indexPath.section ==7 && indexPath.row == 1)
//    {
//        [textField resignFirstResponder];
//    }
//    if (indexPath.section ==7 && indexPath.row == 2) {
//        if(bum==nil)
//        {
//            [self album];
//        }
//        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
//        
//        mediaPicker.delegate = self;
//        mediaPicker.allowsPickingMultipleItems = YES;
//        mediaPicker.prompt = @"Select songs";
//        
//        [self presentModalViewController:mediaPicker animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    if (indexPath.section == 2) {
//        if(bum==nil)
//        {
//            [self album];
//        }
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//            UIButton *button1 = [self getStateButton];
//            if (cell.accessoryView==nil) {
//                cell.accessoryView = button1;
//            }else{
//                cell.accessoryView = nil;
//            }
//            for (UIButton *button in cell.contentView.subviews) {
//            
//                if ([button isKindOfClass:[UIButton class]]) {
//                    if ([button.currentImage isEqual:unselectImg]) {
//                        [button setImage:selectImg forState:UIControlStateNormal]; 
//                        NSString *rule=@"INCLUDE";
//                        [self insert:indexPath.row rule:rule];
//                        [selectedIndexPaths addObject:indexPath];
//                    }
//                    else
//                    {
//                        [button setImage:unselectImg forState:UIControlStateNormal];
//                        People *p1 = (People *)[list objectAtIndex:indexPath.row];
//                        NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
//                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
//                        NSFetchRequest *request = [[NSFetchRequest alloc]init];
//                        [request setEntity:entity];
//                        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
//                        [request setPredicate:pre];
//                        NSError *error = nil;
//                        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
//                        PeopleRuleDetail *p=[A objectAtIndex:0];
//                        [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
//                        [appDelegate.dataSource.coreData saveContext];
//
//                    }
//                }
//            }
//
//    }
//    if(indexPath.section==5)
//    {  
//        if(bum==nil)
//        {
//            [self album];
//        }
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        for (UIButton *button in cell.contentView.subviews) {
//            
//            if ([button isKindOfClass:[UIButton class]]) {
//                if ([button.currentImage isEqual:unselectImg]) {
//                    [button setImage:selectImg forState:UIControlStateNormal]; 
//                    bum.isFavorite=[NSNumber numberWithBool:YES];
//                }
//                else
//                {
//                    [button setImage:unselectImg forState:UIControlStateNormal];
//                    bum.isFavorite=nil;
//                    [appDelegate.dataSource.coreData saveContext];
//                    
//                }
//            }
//        }
//   
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
//- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
//{
//    if (mediaItemCollection) {
//        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
//        NSArray *items = [mediaItemCollection items];
//        MPMediaItem *item = [items objectAtIndex:0];
//       // [musicPlayer play]; 
//        //self.musicLabel.text = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
//        self.musicLabel.text = [item valueForProperty:MPMediaItemPropertyTitle]; 
//        bum.music = self.musicLabel.text;
//    }
//    [mediaPicker dismissModalViewControllerAnimated: YES];
//}

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
//-(UIButton *)getStateButton{
//  stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    stateButton.frame = CGRectMake(0, 0, 75, 28);
//    [stateButton addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
//    [stateButton setTitle:INCLUDE forState:UIControlStateNormal];
//    stateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
//    [stateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
//    return stateButton;
//}
-(UIButton *)chooseButton{
    chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
   chooseButton.frame = CGRectMake(0, 0, 105, 28);
    [chooseButton addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    [chooseButton setTitle:@"NO" forState:UIControlStateNormal];
    chooseButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [chooseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return chooseButton;
}
//-(UIButton *)sortButton{
//    sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    sortButton.frame = CGRectMake(0, 0, 105, 28);
//    [sortButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
//    [sortButton setTitle:@"time" forState:UIControlStateNormal];
//    sortButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
//    [sortButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
//    return sortButton;
//}
//-(UIButton *)orderButton{
//    orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    orderButton.frame = CGRectMake(0, 0, 105, 28);
//    [orderButton addTarget:self action:@selector(order:) forControlEvents:UIControlEventTouchUpInside];
//    [orderButton setTitle:@"ASC" forState:UIControlStateNormal];
//    orderButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
//    [orderButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
//    return orderButton;
//}
//-(UIButton *)peopleRuleButton{
//    peopleRuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    peopleRuleButton.frame = CGRectMake(0, 0, 105, 28);
//    [peopleRuleButton addTarget:self action:@selector(peopleRule:) forControlEvents:UIControlEventTouchUpInside];
//    [peopleRuleButton setTitle:@"AND" forState:UIControlStateNormal];
//    peopleRuleButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
//    [peopleRuleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
//    return peopleRuleButton;
//}
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
    UIButton *button = (UIButton *)sender;
      [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
      if ([button.titleLabel.text isEqualToString:@"NO"]) {
            button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
           [button setTitle:@"YES" forState:UIControlStateNormal];
          // bum.chooseType=@"YES";
      }
    else
    {
        [button setTitle:@"NO" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    }
    
//    if(bum==nil)
//    {
//        [self album];
//    }
//    UIButton *button = (UIButton *)sender;
//    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
//    if ([button.titleLabel.text isEqualToString:PhotoVideo]) {
//        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
//        [button setTitle:Photo forState:UIControlStateNormal];
//        bum.chooseType=@"Photo";
//      
//       
//    }
//    else if ([button.titleLabel.text isEqualToString:Photo]){
//        button.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
//        [button setTitle:Video forState:UIControlStateNormal];
//        bum.chooseType=@"Video";
//  
//    }
//    else
//    {
//        button.backgroundColor =[UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
//        [button setTitle:PhotoVideo forState:UIControlStateNormal]; 
//        bum.chooseType=@"Photo&Video";
//    }
//   // bum.name=textField.text;
//    [appDelegate.dataSource.coreData saveContext];
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
//-(void)setSelect7:(id)sender{
//    NSLog(@"7");
//    if(bum==nil)
//    {
//        [self album];
//    }
//    UIButton *button = (UIButton *)sender;
//    if ([button.currentImage isEqual:selectImg]) {
//        [button setImage:unselectImg forState:UIControlStateNormal];
//        NSLog(@"2");
//        bum.isFavorite=nil;
//        
//    }
//    else
//    {
//        [button setImage:selectImg forState:UIControlStateNormal];
//        NSLog(@"1");
//        bum.isFavorite=[NSNumber numberWithBool:YES];
//       
//    }
//    [appDelegate.dataSource.coreData saveContext];
//}
//-(void)setSelectState:(id)sender{
//   if(bum==nil)
//   {
//       [self album];
//   }
//    UIButton *button = (UIButton *)sender;
//    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
//    NSIndexPath *index = [listTable indexPathForCell:cell];
//    NSInteger Row=index.row;
//   
//     if ([button.currentImage isEqual:selectImg]) {
//              [button setImage:unselectImg forState:UIControlStateNormal];
//        NSIndexPath *index = [listTable indexPathForCell:cell];
//        [selectedIndexPaths removeObject:index];
//        cell.accessoryView = nil;
//         [button setImage:unselectImg forState:UIControlStateNormal];
//         People *p1 = (People *)[list objectAtIndex:Row];
//         NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
//         NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
//         NSFetchRequest *request = [[NSFetchRequest alloc]init];
//         [request setEntity:entity];
//         
//         NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
//         [request setPredicate:pre];
//         
//         NSError *error = nil;
//         NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
//         PeopleRuleDetail *p=[A objectAtIndex:0];
//         [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
//         [appDelegate.dataSource.coreData saveContext];
//
//    }else{
//        [button setImage:selectImg forState:UIControlStateNormal];
//        NSIndexPath *index = [listTable indexPathForCell:cell];
//        [selectedIndexPaths addObject:index];
//        cell.accessoryView = [self getStateButton];
//        NSString *rule=@"INCLUDE";
//        [self insert:index.row rule:rule];
//    }
//   
//}
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
//           NSString *text = [self.textField text];
//        NSString *caplitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
//        NSLog(@"%@ uppercased is %@", text, caplitalized);
//        if()
//        self.textField.text=caplitalized;
//    

        
}
-(void)textFieldDidEndEditing:(UITextField *)textField1
{
    NSLog(@"FDFD");
//    if(textField1.tag==1)
//{
  
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
    
//}
}
-(void)addPlay
{NSLog(@"FDFD");
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
        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:7]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }else{
        [listTable beginUpdates];
        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:7]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }
}

//-(IBAction)upSort:(id)sender
//{
//    UISwitch *newSwitcn  = (UISwitch *)sender;
//    sortSwc = newSwitcn.on;
//    if (newSwitcn.on) {
//        [listTable beginUpdates];
//        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:4],nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [listTable endUpdates];
//    }else{
//        bum.conDateRule = nil;
//        date = nil;
//        [listTable beginUpdates];
//        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:4],nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [listTable endUpdates];
//    }
//    
//}
//
//-(IBAction)resetAll{
//    if([selectedIndexPaths count]>0)
//    {
//    for (NSIndexPath *path in selectedIndexPaths) {
//        
//        if (path.section == 5) {
//            UITableViewCell *cell = [listTable cellForRowAtIndexPath:path];
//            cell.accessoryView = nil;
//            for (UIButton *button in cell.contentView.subviews) {
//                if ([button isKindOfClass:[UIButton class]]) {
//                    if ([button.currentImage isEqual:selectImg]) {
//                        [button setImage:unselectImg forState:UIControlStateNormal];
//                    }
//                }
//            }
//        }
//    }
//    [selectedIndexPaths removeAllObjects];
//    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    [request setEntity:entity];
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",bum.conPeopleRule];
//    [request setPredicate:pre];
//    NSError *error = nil;
//    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
//    PeopleRuleDetail *p=[A objectAtIndex:0];
//    [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
//    [appDelegate.dataSource.coreData saveContext];
//    }
//
//}
//
//-(IBAction)playAlbumPhotos:(id)sender{
//    [musicPlayer play];
//    NSMutableArray *assets = nil;
//    NSPredicate *pre =  [appDelegate.dataSource ruleFormation:bum];
//    if([bum.sortOrder boolValue]==YES){
//        assets=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
//    }else {
//        assets=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:NO];
//        
//    }
//    pre=[appDelegate.dataSource excludeRuleFormation:bum];
//    if (pre!=nil) {
//        NSMutableArray* excludePeople=[appDelegate.dataSource simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
//        if(excludePeople!=nil) {
//            [assets removeObjectsInArray:excludePeople];
//            }
//    }
//    AmptsAlbum *ampAlbum = [appDelegate.dataSource.assetsBook objectAtIndex:0];
//    NSPredicate *newPre = [NSPredicate predicateWithFormat:@"self in %@",assets];
//    NSArray *array = [ampAlbum.assetsList filteredArrayUsingPredicate:newPre];
//    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:array, @"assets", self.bum.transitType, @"transition",nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
//}
//
//#pragma mark -
//#pragma mark Notification method
//-(void)changeTransitionAccessoryLabel:(NSNotification *)note{
//    NSDictionary *dic = [note userInfo];
//    NSString *labelText = [dic objectForKey:@"tranStyle"];
//   // self.tranLabel.text = labelText;
//}


-(void)changeType:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
    NSString *labelText = [dic objectForKey:@"TypeStyle"];
    self.TypeLabel.text = labelText;
}
-(IBAction)chooseMyfavorite:(id)sender
{if(bum==nil)
{
    [self album];
}
    UISwitch *newSwitcn  = (UISwitch *)sender;
    
    if (newSwitcn.on) {
        bum.isFavorite=[NSNumber numberWithBool:YES];
       
    }else{
        bum.isFavorite=nil;
    }
    [AL.coreData saveContext];
}

-(void)changePeople:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
    NSMutableArray *people1=[dic objectForKey:@"name"] ;
    if(people1.count>0)
    {
    NSMutableArray *name=[[NSMutableArray alloc]init];
    for(People *p in people1)
    {
        [name addObject:p];
    }
    [self personLabel:name];
    }    
    else
    {
        PersonLabel.text=@"None";
    }
//    if(name.count==1)
//   {
//       if([[name objectAtIndex:0] firstName]==nil)
//       {
//           self.PersonLabel.text=[[name objectAtIndex:0]lastName];
//       }
//       else if([[name objectAtIndex:0] lastName]==nil)
//       {
//           self.PersonLabel.text=[[name objectAtIndex:0]firstName];
//       }
//       else
//           self.PersonLabel.text=[NSString stringWithFormat:@"%@ %@",[[name objectAtIndex:0]lastName],[[name objectAtIndex:0]firstName]];
//
//       
//   }
// 
//    else if(name.count>1)
//    {
//        if([[name objectAtIndex:0] firstName]==nil)
//        {
//            self.PersonLabel.text=[NSString stringWithFormat:@"%@等%d个人",[[name objectAtIndex:0]lastName],name.count];
//        }
//        else if([[name objectAtIndex:0] lastName]==nil)
//        {
//            self.PersonLabel.text= [NSString stringWithFormat:@"%@等%d个人",[[name objectAtIndex:0]firstName],name.count];
//        }
//        else
//            self.PersonLabel.text=[NSString stringWithFormat:@"%@ %@等%d个人",[[name objectAtIndex:0]lastName],[[name objectAtIndex:0]firstName],[name count]];
//    }
    //self.PersonLabel.text = labelText;
}
-(void)personLabel:(NSMutableArray *)person
{
    if(person.count==1)
    {
        if([[person objectAtIndex:0] firstName]==nil)
        {
            self.PersonLabel.text=[[person objectAtIndex:0]lastName];
        }
        else if([[person objectAtIndex:0] lastName]==nil)
        {
            self.PersonLabel.text=[[person objectAtIndex:0]firstName];
        }
        else
            self.PersonLabel.text=[NSString stringWithFormat:@"%@ %@",[[person objectAtIndex:0]lastName],[[person objectAtIndex:0]firstName]];
        
        
    }
    
    else if(person.count>1)
    {
        if([[person objectAtIndex:0] firstName]==nil)
        {
            self.PersonLabel.text=[NSString stringWithFormat:@"%@等%d个人",[[person objectAtIndex:0]lastName],person.count];
        }
        else if([[person objectAtIndex:0] lastName]==nil)
        {
            self.PersonLabel.text= [NSString stringWithFormat:@"%@等%d个人",[[person objectAtIndex:0]firstName],person.count];
        }
        else
            self.PersonLabel.text=[NSString stringWithFormat:@"%@ %@等%d个人",[[person objectAtIndex:0]lastName],[[person objectAtIndex:0]firstName],[person count]];
    }

}
-(void)eventLabel:(NSMutableArray *)event
{
    if(event.count==1)
    {
        self.EventLabel.text=[event objectAtIndex:0];        
    }
    
    else if(event.count>1)
    {
        self.EventLabel.text=[NSString stringWithFormat:@"%@等%d个事件",[event objectAtIndex:0],[event count]];
    }

}
-(void)changeDate:(NSNotification *)note
{
     NSDictionary *dic = [note userInfo];
    NSString *date1=[dic objectForKey:@"date"];
    DateLabel.text=date1;
    
}
-(void)changeSort:(NSNotification *)note
{
    NSDictionary *dic=[note userInfo];
    NSString *order=nil;
    if([[dic objectForKey:@"order"] boolValue])
    {
        order=@"ASC";
    }
    else
    {
        order=@"DSC";
    }
    SortOrder.text=[NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"sort"],order];
}
-(void)changeEvent:(NSNotification *)note
{
    NSLog(@"CHANGE");
    NSDictionary *dic=[note userInfo];
    NSMutableArray *events=[dic objectForKey:@"evename"];
    [self eventLabel:events];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    selectedIndexPaths = nil;
   // textFieldCell = nil;
    textField = nil;
  //  tranCell = nil;
   // tranLabel = nil;
  //  switchCell = nil;
    //mySwitch = nil;
   // musicCell = nil;
    //musicLabel = nil;
    listTable =nil;
    userNames = nil;
    state = nil;
}
@end
