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
@synthesize tableView,bo;
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
        UIEdgeInsets insets = self.tableView.contentInset;
        [self.tableView setContentInset:UIEdgeInsetsMake(0, insets.left, insets.bottom, insets.right)];
    }
    if(bo==nil)
    {
        [self creatButton1];
    }
    count = [list count];
    [self setTableViewEdge:[UIApplication sharedApplication].statusBarOrientation];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(table) name:@"add" object:nil];
	[super viewDidLoad];
   	
 }
-(void)creatButton
{
    tools = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width/3+5,self.navigationController.navigationBar.frame.size.height)];
    tools.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    NSString *a=NSLocalizedString(@"Back", @"button");
    NSString *b=NSLocalizedString(@"Edit", @"button");
     NSString *c=NSLocalizedString(@"Mult", @"button");
    UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
    MultipleButton=[[UIBarButtonItem alloc] initWithTitle:c style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMutiple:)];
    self.navigationItem.leftBarButtonItem=BackButton;
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    editButton.style = UIBarButtonItemStyleBordered;
     NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
     [buttons addObject:MultipleButton];
    [buttons addObject:editButton];
   
    
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *myBtn = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
    self.navigationItem.rightBarButtonItem = myBtn;
    
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
    A=YES;
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
           // peopleList=[datasource addPeople:favorate];
            [peopleList addObjectsFromArray:[datasource addPeople:favorate]];
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
-(IBAction)toggleMutiple:(id)sender
{
    self.tableView.allowsMultipleSelectionDuringEditing=YES; 
    NSString *d=NSLocalizedString(@"Back", @"button");
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Sing", @"title");
    NSString *c=NSLocalizedString(@"Mult", @"button");
    UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:d style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
    self.navigationItem.leftBarButtonItem=BackButton;
     editButton.style=UIBarButtonItemStyleBordered;
    if([MultipleButton.title isEqualToString:c])
    {
        MultipleButton.title=b;
         editButton.title=a;
        self.tableView.editing=NO;
        [choosePeople removeAllObjects];
        //MultipleButton.style=UIBarButtonItemStyleDone;
        choose=YES;
        
    }
    else
    { [choosePeople removeAllObjects];
        self.tableView.editing=YES;
        MultipleButton.title=c;
         editButton.title=a;
        choose=NO;
         //MultipleButton.style=UIBarButtonItemStyleBordered;
       
    }
     [self.tableView setEditing:!self.tableView.editing animated:YES];
   
}
-(IBAction)toggleEdit:(id)sender
{ 
    [choosePeople removeAllObjects];
    self.tableView.allowsMultipleSelectionDuringEditing=NO;
    MultipleButton.style=UIBarButtonItemStyleBordered;
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
    NSString *c=NSLocalizedString(@"Mult", @"button");
    NSString *d=NSLocalizedString(@"Back", @"button");
    if([editButton.title isEqualToString:a])
    {
        editButton.style=UIBarButtonItemStyleDone;         
        editButton.title=b;
        MultipleButton.title=c;
        self.tableView.editing=NO;
        UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
        addButon.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = addButon;
    }
    else
    {
        editButton.style=UIBarButtonItemStyleBordered;

        editButton.title=a;
        MultipleButton.title=c;
        self.tableView.editing=YES;
        if(bo!=nil)
        {

        UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:d style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
        self.navigationItem.leftBarButtonItem=BackButton;
        }
        else
        {
            self.navigationItem.leftBarButtonItem=nil;
        }
       
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
}
-(void)toggleback
{
    
    [self dismissModalViewControllerAnimated:YES];
    if([choosePeople count]!=0)
    {
        [self dismissModalViewControllerAnimated:YES];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:choosePeople,@"people",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addTagPeople" 
                                                           object:self 
                                                         userInfo:dic];
    }

   // [[NSNotificationCenter defaultCenter]postNotificationName:@"resetToolBar" object:nil];
    else
    {
   [[NSNotificationCenter defaultCenter]postNotificationName:@"resetToolBar" object:nil];
   NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    bool1=NO;
    tools.alpha=1;
    tools.barStyle = UIBarStyleBlack;
   // self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    if(bo!=nil)
    {
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack; 
        UIEdgeInsets insets = self.tableView.contentInset;
        [self.tableView setContentInset:UIEdgeInsetsMake(0, insets.left, insets.bottom, insets.right)];
        
    }
    else
    {
         self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{   /*if(bool1==NO)
{
    tools.alpha=0;
} */
   
    if(A==YES)
    {}
    else
    {
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    }
}

-(void)table
{
    NSLog(@"TABLE");
   //favorate.favorite=[NSNumber numberWithBool:YES];
    [peopleList removeAllObjects];
    [self.result removeAllObjects];
    [IdList removeAllObjects];
    appDelegate = [[UIApplication sharedApplication] delegate];
    datasource=appDelegate.dataSource;
    [datasource refreshPeople];
   if(bo!=nil)
   {
       for (int i=1;i<[datasource.favoriteList count];i++)
       {
           [peopleList addObject:[datasource.favoriteList objectAtIndex:i]];
       }
   }
   
    else
    {
    
        peopleList=datasource.favoriteList;
    }

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
    return ([IdList objectAtIndex:indexPath.row]==[NSNumber numberWithInt:-1]) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   if([IdList objectAtIndex:indexPath.row]==[NSNumber numberWithInt:-1])
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
      // People *am = (People *)[result objectAtIndex:indexPath.row];
    
    favorite *fa=[peopleList objectAtIndex:indexPath.row];
    if([IdList objectAtIndex:indexPath.row]==[NSNumber numberWithInt:-1])
    {
        cell.textLabel.textColor=[UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        
    }
    else
    {
      cell.textLabel.textColor=[UIColor blackColor];   
    }

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
    dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:[[self.peopleList objectAtIndex:indexPath.row]assetsList], @"myAssets",a,@"title",nil];
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
    favorate1.favorite=[NSNumber numberWithBool:NO];
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
    if([IdList objectAtIndex:toIndexPath.row]!=[NSNumber numberWithInt:-1])
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self setTableViewEdge:toInterfaceOrientation];
    
}
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation{
    UIEdgeInsets insets = self.tableView.contentInset;
    if(bo!=nil)
    {
       //[self.tableView setContentInset:UIEdgeInsetsMake(0, insets.left, insets.bottom, insets.right)];
//        if (UIInterfaceOrientationIsLandscape(orientation)) {
//            tools.frame=CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width/4+5,self.navigationController.navigationBar.frame.size.height);
//            [self.tableView setContentInset:UIEdgeInsetsMake(33, insets.left, insets.bottom, insets.right)];
//            //tools = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 110,33)];
//            
//        }else{
//            [self.tableView setContentInset:UIEdgeInsetsMake(45, insets.left, insets.bottom, insets.right)];
//            tools.frame=CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width/3+5,self.navigationController.navigationBar.frame.size.height);
//        }

    }
    else
    {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        //tools.frame=CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width/8+5,self.navigationController.navigationBar.frame.size.height);
        [self.tableView setContentInset:UIEdgeInsetsMake(33, insets.left, insets.bottom, insets.right)];
        //tools = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 110,33)];
        
    }else{
        [self.tableView setContentInset:UIEdgeInsetsMake(45, insets.left, insets.bottom, insets.right)];
        //tools.frame=CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width/3+5,self.navigationController.navigationBar.frame.size.height);
    }
    }
}
@end
