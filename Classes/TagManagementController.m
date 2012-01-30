#import "TagManagementController.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
#import "AssetTablePicker.h"
#import "PhotoAppDelegate.h"
@implementation TagManagementController
@synthesize list;
@synthesize button;
@synthesize tableView,tools,bo;
@synthesize coreData,favorate,people;
@synthesize result,IdList;
int j=1,count=0;


-(void)viewDidLoad
{  
    NSMutableArray *parray=[[NSMutableArray alloc]init];
    NSMutableArray *parray1=[[NSMutableArray alloc]init];
    self.IdList=parray1;
    favorate=[[People alloc]init];
   self.people=parray;
   [people addObject:favorate];
    NSLog(@"PEOPLE:%@",people);
    [self table];
    bool1 = NO;
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
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
    tools = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 100,45)];
    tools.barStyle = UIBarStyleBlack;
    NSString *a=NSLocalizedString(@"Back", @"button");
    NSString *b=NSLocalizedString(@"Edit", @"button");
    UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
    self.navigationItem.leftBarButtonItem=BackButton;
    UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    addButon.style = UIBarButtonItemStyleBordered;
    editButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:editButton];
    [buttons addObject:addButon];
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *myBtn = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = myBtn;
    
}
-(void)creatButton1
{
    NSString *b=NSLocalizedString(@"Edit", @"button");
    UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    addButon.style = UIBarButtonItemStyleBordered;
    editButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = addButon;
    self.navigationItem.leftBarButtonItem = editButton;
    
}


//-(void)nobody
//{
//    
//    NSString *selectIdOrder1=[NSString stringWithFormat:@"select id from idOrder where id=0"];
//    NSMutableArray *IDList=[da selectOrderId:selectIdOrder1];
//    if([IDList count]==0)
//    {
//        NSString *insertUserTable= [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(ID,NAME) VALUES(%d,'%@')",UserTable,0,@"NoBody"];
//        NSLog(@"%@",insertUserTable);
//        [da insertToTable:insertUserTable];
//        NSString *insertIdOrder= [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(ID) VALUES(%d)",idOrder,0];
//        NSLog(@"%@",insertIdOrder);
//        [da insertToTable:insertIdOrder];
//        
//    }
//    NSString *selectIdOrder=[NSString stringWithFormat:@"select id from idOrder"];
//    self.list=[da selectOrderId:selectIdOrder];
//    
//}
-(IBAction)toggleAdd:(id)sender
{  
    bool1=YES;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
} 
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    
    
    NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
   // NSString *readName=(NSString *)ABRecordCopyCompositeName(person);
    ABRecordID recId = ABRecordGetRecordID(person);
    fid=[NSNumber numberWithInt:recId];
    //fname=[NSString stringWithFormat:@"%@",readName];
    //NSMutableArray *IdList=[[NSMutableArray alloc]init];
    
    NSLog(@"WWWW%@",IdList);  
    NSLog(@"WWWW%@",IdList);
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
   
    }
    else
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]]; 
        favorate=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
        favorate.firstName=personName;
        favorate.lastName=lastname;
        favorate.addressBookId=[NSNumber numberWithInt:[fid intValue]];
        [appDelegate.dataSource.coreData saveContext];
        [self table];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    return NO;
    
	
}

-(IBAction)toggleEdit:(id)sender
{ 
    //
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
    if (self.tableView.editing) {
        editButton.title = a;
    }else{
        editButton.title = b;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
}
-(void)toggleback
{
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"resetToolBar" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    bool1=NO;
    tools.alpha=1;
    tools.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack;    
}
-(void)viewWillDisappear:(BOOL)animated
{   if(bool1==NO)
{
    tools.alpha=0;
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
} 
}
-(void)table
{
    appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=[appDelegate.dataSource.coreData managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    NSMutableArray *parray1=[[NSMutableArray alloc]init];
    self.result=parray1;
    
    result=[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if(result==nil)
    {
        NSLog(@"读取了空数据！");
    }
    NSLog(@"result:%@",result);
    [self.IdList removeAllObjects];
    for(int i=0;i<[self.result count];i++)
    {
        People *a = (People *)[result objectAtIndex:i];
        [self.IdList addObject:a.addressBookId];
    }  
    NSLog(@"idlist:%@",IdList);
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    self.tableView=nil;
	self.list=nil;
    self.button=nil;
	[super viewDidUnload];
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return[result count];
    
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
    People *am = (People *)[result objectAtIndex:indexPath.row];
    if (am.lastName == nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",am.firstName];
    }else
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",am.firstName, am.lastName];
        
    return cell; 
}
#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
    id1=[NSString stringWithFormat:@"%d",indexPath.row]; 
    People *favorate1=[self.result objectAtIndex:indexPath.row];
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        [appDelegate.dataSource.coreData.managedObjectContext deleteObject:favorate1];
        [self.result removeObject:favorate1];
    }
     [appDelegate.dataSource.coreData saveContext];
    [self table];

    
    /*NSString *selectTag= [NSString stringWithFormat:@"select ID from tag"];
    
    NSMutableArray *listid1=[da selectFromTAG:selectTag];
    if([[self.list objectAtIndex:indexPath.row]intValue]==0)
    {
        NSString *a=NSLocalizedString(@"hello", @"title");
        NSString *b=NSLocalizedString(@"Inherent members, can not be deleted", @"title");
        NSString *c=NSLocalizedString(@"ok", @"title");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:a message:b delegate:self cancelButtonTitle:c otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        if([listid1 containsObject:[list objectAtIndex:indexPath.row]])
        {
            NSString *a=NSLocalizedString(@"hello", @"title");
            NSString *b=NSLocalizedString(@"This person has been used as a photo tag, you sure you want to delete it", @"title");
            NSString *c=NSLocalizedString(@"NO", @"title");
            NSString *d=NSLocalizedString(@"YES", @"title");
            
            UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:a message:b delegate:self cancelButtonTitle:c otherButtonTitles:nil];
            [alert1 addButtonWithTitle:d];
            [alert1 show];
            [alert1 release];
            
        }
        else
        {
            NSString *deleteIdTable = [NSString stringWithFormat:@"DELETE FROM idOrder WHERE ID='%@'",[self.list objectAtIndex:indexPath.row]];
            NSLog(@"%@",deleteIdTable );
            [da deleteDB:deleteIdTable ];  
            NSString *DeleteUserTable= [NSString stringWithFormat:@"DELETE FROM UserTable WHERE ID='%@'",[self.list objectAtIndex:indexPath.row]];
            [da deleteDB:DeleteUserTable];
            [self creatTable];
            [self.tableView reloadData];
        }
    }*/
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    People *selectedPeople = [self.result objectAtIndex:indexPath.row];
   [self dismissModalViewControllerAnimated:YES];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:selectedPeople,@"people",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addTagPeople" 
                                                       object:self 
                                                     userInfo:dic];
    [table deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)alertView:(UIAlertView *)alert1 didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    switch (buttonIndex) {
//        case 1:
//            NSString *deleteIdTable= [NSString stringWithFormat:@"DELETE FROM idOrder WHERE ID='%@'",[list objectAtIndex:[id1 intValue]]];
//            NSLog(@"%@",deleteIdTable);
//            [da deleteDB:deleteIdTable];  
//            NSString *deleteUserTable= [NSString stringWithFormat:@"DELETE FROM UserTable WHERE ID='%@'",[list objectAtIndex:[id1 intValue]]];
//            [da deleteDB:deleteUserTable];
//            NSString *deleteTag= [NSString stringWithFormat:@"DELETE FROM TAG WHERE ID='%@'",[list objectAtIndex:[id1 intValue]]];
//            [da deleteDB:deleteTag];
//            [self viewDidLoad];
//            [self.tableView reloadData];            
//            break;
//        case 0:
//            [self.tableView reloadData];
//            break;
//    }
    
    
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissModalViewControllerAnimated:YES];
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    People *p=[self.result objectAtIndex:fromIndexPath.row];
    [self.result removeObjectAtIndex:fromIndexPath.row];
    [self.result insertObject:p atIndex:toIndexPath.row];

} 

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return 0;
}
@end
