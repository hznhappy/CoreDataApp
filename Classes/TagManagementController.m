#import "TagManagementController.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
#import "AssetTablePicker.h"
#import "PhotoAppDelegate.h"
#import "Asset.h"
#import "PeopleTag.h"
#import "favorite.h"
@implementation TagManagementController
@synthesize list;
@synthesize button;
@synthesize tableView,tools,bo;
@synthesize coreData,favorate;
@synthesize result,IdList;
@synthesize favorate1;
@synthesize as;
@synthesize choosePeople;
@synthesize peopleList;
int j=1,count=0;
-(void)viewDidLoad
{  
    [self.navigationItem setTitle:@"Favorite"];
    NSMutableArray *parray1=[[NSMutableArray alloc]init];
    choosePeople=[[NSMutableArray alloc]init];
    peopleList=[[NSMutableArray alloc]init];
    result=[[NSMutableArray alloc]init];
    self.IdList=parray1;
    [self table];
    bool1 = NO;
    choose=NO;
    if(bo!=nil)
    {  
        [self creatButton];
    }
    if(bo==nil)
    {
        [self creatButton1];
    }
    count = [list count];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(table) name:@"add" object:nil];
	[super viewDidLoad];
   	
 }
-(void)creatButton
{
    self.tableView.allowsMultipleSelectionDuringEditing=YES;
    NSString *a=NSLocalizedString(@"Back", @"button");
    NSString *b=NSLocalizedString(@"choose", @"button");
    UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
    self.navigationItem.leftBarButtonItem=BackButton;
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    editButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = editButton;
    
}
-(void)creatButton1
{
    NSString *b=NSLocalizedString(@"Edit", @"button");
   
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    
    editButton.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.rightBarButtonItem = editButton;
    
}
-(IBAction)toggleAdd:(id)sender
{  
    bool1=YES;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
} 
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    
    
    NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABRecordID recId = ABRecordGetRecordID(person);
    fid=[NSNumber numberWithInt:recId];
    if([self.IdList containsObject:fid])
    {
       /* NSString *b=NSLocalizedString(@"Already exists", @"button");
        NSString *a=NSLocalizedString(@"note", @"button");
        NSString *c=NSLocalizedString(@"ok", @"button");
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:a
                              message:b
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:c,nil];
        [alert show];
        alert.tag=0;*/
   
    }
    else
    {
        NSPredicate *favor=[NSPredicate predicateWithFormat:@"addressBookId==%@",fid]; 
        NSArray *fa1 = [datasource simpleQuery:@"People" predicate:favor sortField:nil sortOrder:YES];
        if([fa1 count]==0)
        {
            NSLog(@"whit out");
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[datasource.coreData managedObjectContext]]; 
            favorate=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[datasource.coreData managedObjectContext]];
            favorate.firstName=personName;
            favorate.lastName=lastname;
            favorate.addressBookId=[NSNumber numberWithInt:[fid intValue]];
            favorate.favorite=[NSNumber numberWithBool:YES];
            favorite *fe=[peopleList lastObject];
            favorate.listSort=[NSNumber numberWithInt:[fe.people.listSort intValue]+1];
            [datasource.coreData saveContext];
            peopleList=[datasource addPeople:favorate];
            [self.result addObject:favorate];
            [IdList addObject:fid];
            [self.tableView reloadData];
        }
        else
        {NSLog(@"with");
            People *p=(People *)[fa1 objectAtIndex:0];
            p.favorite=[NSNumber numberWithBool:YES];
            p.inAddressBook=[NSNumber numberWithBool:NO];
            favorite *fe=[peopleList lastObject];
            p.listSort=[NSNumber numberWithInt:[fe.people.listSort intValue]+1];
            NSLog(@"FElistSort:%@",favorate.listSort);
            [datasource.coreData saveContext];
            [self table];
            
       }
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
    
	
}

-(IBAction)toggleEdit:(id)sender
{ 
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
     NSString *c=NSLocalizedString(@"choose", @"button");
    if (self.tableView.editing) {
        editButton.style=UIBarButtonItemStyleBordered;
        if(bo==nil)
        {
            editButton.title = a;
        }
        else
        {
            editButton.title=c;
        }

        if(bo!=nil)
        {
            NSString *c=NSLocalizedString(@"Back", @"button");
            UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:c style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
            self.navigationItem.leftBarButtonItem=BackButton;
            choose=NO;
            if([choosePeople count]!=0)
            {
            [self dismissModalViewControllerAnimated:YES];
           NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:choosePeople,@"people",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"addTagPeople" 
                                                               object:self 
                                                             userInfo:dic];
            }
           
 
        }
        else
        {
            
        self.navigationItem.leftBarButtonItem=nil;
        }
    }else{
        [choosePeople removeAllObjects];
        editButton.style=UIBarButtonItemStyleDone;
       
        editButton.title = b;
              UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
        addButon.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = addButon;
        if(bo!=nil)
        {
        choose=YES;
        }
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
}
-(void)toggleback
{
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"resetToolBar" object:nil];
    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1];

}

-(void)viewWillAppear:(BOOL)animated
{
    bool1=NO;
    tools.alpha=1;
    tools.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
}
-(void)viewWillDisappear:(BOOL)animated
{   if(bool1==NO)
{
    tools.alpha=0;
} 
}
-(void)table
{
   //favorate.favorite=[NSNumber numberWithBool:YES];
    [peopleList removeAllObjects];
    [self.result removeAllObjects];
    [IdList removeAllObjects];
    appDelegate = [[UIApplication sharedApplication] delegate];
    datasource=appDelegate.dataSource;
    [datasource refreshPeople];
    peopleList=datasource.favoriteList;
      for(favorite *a  in peopleList)
    {
        [self.result addObject:a.people];
        [IdList addObject:a.people.addressBookId];
       // NSLog(@"listSort:%@",a.people.listSort);
    }
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    self.tableView=nil;
	self.list=nil;
    self.button=nil;
	[super viewDidUnload];
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        return NO;
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return[peopleList count];
    
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    if(indexPath.row==0)
    {
       cell.textLabel.textColor=[UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        
    }
   // People *am = (People *)[result objectAtIndex:indexPath.row];
    
    favorite *fa=[peopleList objectAtIndex:indexPath.row];
    //People *pl=fa.people;
    //pl.listSort=[NSNumber numberWithInt:indexPath.row];
    if(fa.num!=0)
    {
    if (fa.firstname == nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",fa.lastname,fa.num];
    }
    else if(fa.lastname == nil)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",fa.firstname,fa.num];
    } 
    else
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ (%d)",fa.lastname, fa.firstname,fa.num];
    }
    else
    {
        if (fa.firstname == nil) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",fa.lastname];
        }
        else if(fa.lastname == nil)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",fa.firstname];
        } 
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",fa.lastname, fa.firstname];

    }
    return cell; 
}
#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
        
    id1=[NSString stringWithFormat:@"%d",indexPath.row]; 
    favorate1=[self.result objectAtIndex:indexPath.row];
   // NSPredicate *pre=[NSPredicate predicateWithFormat:@"conPeople==%@",favorate1];
   // self.as=[appDelegate.dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:YES];
    favorite *f=[peopleList objectAtIndex:indexPath.row];

     if(f.num!=0)
     {
         NSString *a=NSLocalizedString(@"hello", @"title");
         NSString *b=NSLocalizedString(@"This person has been used as a photo tag, you sure you want to delete it", @"title");
         NSString *c=NSLocalizedString(@"NO", @"title");
         NSString *d=NSLocalizedString(@"YES", @"title");
         index=indexPath.row;
         UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:a message:b delegate:self cancelButtonTitle:d otherButtonTitles:nil];
         [alert1 addButtonWithTitle:c];
         [alert1 show];
         alert1.tag=1;

     }
   
    else
    {
        if(editingStyle==UITableViewCellEditingStyleDelete)
        {
            [datasource.coreData.managedObjectContext deleteObject:favorate1];
            [self.result removeObjectAtIndex:indexPath.row];
            [self.peopleList removeObjectAtIndex:indexPath.row];
            [self.IdList removeObjectAtIndex:indexPath.row];
        }
        [datasource.coreData saveContext];
        [self.tableView reloadData];

        
    }
    [self table];
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(choose==YES)
    {
         People *selectedPeople = [[self.peopleList objectAtIndex:indexPath.row]people];
        [choosePeople addObject:selectedPeople];
    }
    else
    {
   if(bo!=nil)
   {
    [choosePeople removeAllObjects];
       
   [self dismissModalViewControllerAnimated:YES];
 
    People *selectedPeople = [[self.peopleList objectAtIndex:indexPath.row] people];
    [self dismissModalViewControllerAnimated:YES];
       [choosePeople addObject:selectedPeople];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:choosePeople,@"people",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addTagPeople" 
                                                       object:self 
                                                     userInfo:dic];
   
   }
    else
    {
    People *favorate11=[[self.peopleList objectAtIndex:indexPath.row]people];
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"conPeople==%@",favorate11];
    self.as=[appDelegate.dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:YES];
    NSMutableArray *WE=[[NSMutableArray alloc]init];
    for(int i=0;i<[self.as count];i++)
    {
        PeopleTag *PT=[self.as objectAtIndex:i];
        [WE addObject:PT.conAsset];
    }
    NSMutableDictionary *dic = nil;
        NSString *a=nil;
        if (favorate11.firstName == nil) {
            a = [NSString stringWithFormat:@"%@",favorate11.lastName];
        }
        else if(favorate11.lastName == nil)
        {
            a = [NSString stringWithFormat:@"%@",favorate11.firstName];
        } 
        else
            a = [NSString stringWithFormat:@"%@ %@",favorate11.lastName, favorate11.firstName];
    dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:WE, @"myAssets",a,@"title",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pushPeopleThumbnailView" object:nil userInfo:dic];
    }
        [table deselectRowAtIndexPath:indexPath animated:YES];
    }
    
  
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    People *selectedPeople = [self.result objectAtIndex:indexPath.row];
    [choosePeople removeObject:selectedPeople];
}

-(void)alertView:(UIAlertView *)alert1 didDismissWithButtonIndex:(NSInteger)buttonIndex{
   if(alert1.tag==1)
   {
    switch (buttonIndex) {
        case 0:
            [self deletePeople:index];
            break;
        case 1:  
            break;
        default:
            break;
    }
   }
    
}
-(void)deletePeople:(NSInteger)Index
{
    //[datasource.coreData.managedObjectContext deleteObject:favorate1];
    favorate1.favorite=[NSNumber numberWithBool:YES];
    [datasource.coreData saveContext]; 
    [self.result removeObjectAtIndex:Index];
    [self.peopleList removeObjectAtIndex:Index];
    [self.IdList removeObjectAtIndex:Index];
    [self.tableView reloadData]; 
    //[self table];
  }

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[self dismissModalViewControllerAnimated:YES];
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if([toIndexPath row]>0)
    {
      favorite *p=[self.peopleList objectAtIndex:fromIndexPath.row];
      People *po=p.people;
      favorite *pp=[self.peopleList objectAtIndex:toIndexPath.row];
      People *pop=pp.people;
      //po.listSort=[NSNumber numberWithInt:toIndexPath.row];
        po.listSort=pop.listSort;
        NSLog(@"from row:%d, to row:%d",fromIndexPath.row,toIndexPath.row);
        if(fromIndexPath.row>toIndexPath.row)
        {
            for(int i=toIndexPath.row;i<fromIndexPath.row;i++)
            {
                favorite *p1=[self.peopleList objectAtIndex:i];
                People *po1=p1.people;
                
                po1.listSort=[NSNumber numberWithInt:[po1.listSort intValue]+1];
                //[datasource.coreData saveContext];
            }
        }
        if(fromIndexPath.row<toIndexPath.row)
        {
            for(int i=fromIndexPath.row+1;i<=toIndexPath.row;i++)
            {
                favorite *p1=[self.peopleList objectAtIndex:i];
                People *po1=p1.people;
                po1.listSort=[NSNumber numberWithInt:[po1.listSort intValue]-1];
                
            }
    }
        [datasource.coreData saveContext];

        [self.peopleList removeObjectAtIndex:fromIndexPath.row];
        [self.peopleList insertObject:p atIndex:toIndexPath.row];              
    }
    [self table];
   

  

} 

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return 0;
}
@end
