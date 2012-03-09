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
    appDelegate =[[UIApplication sharedApplication] delegate];
    AL=[[AlbumDataSource alloc]init];
    AL=appDelegate.dataSource;
    self.textField.autocapitalizationType =  UITextAutocapitalizationTypeWords;
    playName=@"标题";
    self.textField.placeholder=playName;
    if(bum.chooseType!=nil)
    {  NSString *a=NSLocalizedString(bum.chooseType, @"title");
        self.TypeLabel.text=a;
    }
    if(bum.isFavorite.boolValue)
    {
        favoriteSW.on=YES;
    }
    if(bum.conDateRule.datePeriod!=nil)
    {
        NSString *a=NSLocalizedString(bum.conDateRule.datePeriod, @"title");
        self.DateLabel.text=a;
    }
    if(bum.sortKey!=nil)
    {
         NSString *a=NSLocalizedString(bum.sortKey, @"title");
         NSString *b=NSLocalizedString(@"ASC", @"title");
         NSString *c=NSLocalizedString(@"DSC", @"title");
        if([bum.sortOrder boolValue])
        {
        SortOrder.text=[NSString stringWithFormat:@"%@ (%@)",a,b];
        }
        else
        {
           SortOrder.text=[NSString stringWithFormat:@"%@ (%@)",a,c]; 
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
    
    NSString *y=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:y forState:UIControlStateNormal];
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
        NSLog(@"DS");
        NSString *a=NSLocalizedString(@"None",@"title");
        if((textField.text==nil||textField.text.length==0)&&bum.transitType==nil&&
           bum.music==nil&&![bum.isFavorite boolValue]&&[PersonLabel.text isEqualToString:a]&&
           [DateLabel.text isEqualToString:a]&&[EventLabel.text isEqualToString:a]&&[SortOrder.text isEqualToString:a])
       
        {
            NSLog(@"delete");
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
}
-(void)textFieldDidEndEditing:(UITextField *)textField1
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

//-(IBAction)updateTable:(id)sender{
//    UISwitch *newSwitcn  = (UISwitch *)sender;
//    mySwc = newSwitcn.on;
//    if (newSwitcn.on) {
//        [listTable beginUpdates];
//        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:7]] withRowAnimation:UITableViewRowAnimationTop];
//        [listTable endUpdates];
//    }else{
//        [listTable beginUpdates];
//        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:7]] withRowAnimation:UITableViewRowAnimationTop];
//        [listTable endUpdates];
//    }
//}
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
        NSString *a=NSLocalizedString(@"None", @"title");
        PersonLabel.text=a;
    }
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
    NSString *a=NSLocalizedString(bum.sortKey, @"title");
    NSString *b=NSLocalizedString(@"ASC", @"title");
    NSString *c=NSLocalizedString(@"DSC", @"title");
    if([bum.sortOrder boolValue])
    {
        SortOrder.text=[NSString stringWithFormat:@"%@ (%@)",a,b];
    }
    else
    {
        SortOrder.text=[NSString stringWithFormat:@"%@ (%@)",a,c]; 
    }
}
-(void)changeEvent:(NSNotification *)note
{
    NSDictionary *dic=[note userInfo];
    NSMutableArray *events=[dic objectForKey:@"evename"];
    [self eventLabel:events];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    selectedIndexPaths = nil;
    textField = nil;
    listTable =nil;
    userNames = nil;
    state = nil;
}
@end
