//
//  personfilterView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "personfilterView.h"
#import "PhotoAppDelegate.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
#import "People.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"

@implementation personfilterView
@synthesize table;
@synthesize album;
@synthesize peopleRuleCell;

-(void)viewDidLoad
{
    NSString *a=NSLocalizedString(@"PeopleRule", @"title");
    NSString *d=NSLocalizedString(@"Favorite", @"title");
    NSString *c=NSLocalizedString(@"phonebook", @"title");
    nameList=[[NSMutableArray alloc]init];
    
    Title=[[NSMutableArray alloc]initWithObjects:a,d,c,nil];
    app =[[UIApplication sharedApplication] delegate];
    dataSource=[[AlbumDataSource alloc]init];
    dataSource=app.dataSource;
    if(album.conPeopleRule==nil)
    {
    NSEntityDescription *entity5 = [NSEntityDescription entityForName:@"PeopleRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
    pr1=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
    album.conPeopleRule=pr1;
    pr1.conAlbum=album;
    album.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
    [dataSource.coreData saveContext];
    }
    [self tableReload];    

    
    
    UIBarButtonItem *editButton =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd)];
    editButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem=editButton;
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
}
-(void)back
{
     NSMutableArray *peo=[[NSMutableArray alloc]init];
    if(album.conPeopleRule!=nil)
    {  
       
        NSPredicate *favor=[NSPredicate predicateWithFormat:@"conPeopleRule==%@",album.conPeopleRule];
        NSArray *fa2 = [dataSource simpleQuery:@"PeopleRuleDetail" predicate:favor sortField:nil sortOrder:YES];
        for(PeopleRuleDetail *pr in fa2)
        {
            [peo addObject:pr.conPeople];
        }
    }

    [self.navigationController popViewControllerAnimated:YES]; 
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:peo,@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"people" 
                                                       object:self 
                                                     userInfo:dic1];
}
-(void)toggleAdd
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate =self ;
    [self presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 1;
    }
    
    else if(section==1)
    {
        return favoriteList.count;
    }
    else
        return phonebookList.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *tit=[Title objectAtIndex:section];
    return tit;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell *cell=nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"peopleRuleCell"];
        if (cell == nil) {
            cell = self.peopleRuleCell;
            cell.accessoryView = [self peopleRuleButton];
            if(![album.conPeopleRule.allOrAny boolValue])
            {
                peopleRuleButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                [peopleRuleButton setTitle:@"Or" forState:UIControlStateNormal];
            }
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;       
    }
   else if(indexPath.section==1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:@"Cell"];
        }
        
        //[cell.contentView removeFromSuperview];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
        name.tag = indexPath.row;
        name.backgroundColor = [UIColor clearColor];
        People *fa=(People *)[favoriteList objectAtIndex:indexPath.row];
        if (fa.firstName == nil) {
            name.text = [NSString stringWithFormat:@"%@",fa.lastName];
        }
        else if(fa.lastName == nil)
        {
            name.text = [NSString stringWithFormat:@"%@",fa.firstName];
        } 
        else
            name.text = [NSString stringWithFormat:@"%@ %@",fa.lastName, fa.firstName];
       // NSString *name1=[NSString stringWithFormat:@"%@ %@",[[favoriteList objectAtIndex:indexPath.row] lastName],[[favoriteList objectAtIndex:indexPath.row] firstName]];
       // name.text=name1;
        [cell.contentView addSubview:name];
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = indexPath.row;
        [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
        selectButton.frame = CGRectMake(10, 11, 30, 30);
        [selectButton setImage:unselectImg forState:UIControlStateNormal];
        [cell.contentView addSubview:selectButton];
        
        
        if(album!=nil)
        {                
            NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
            NSFetchRequest *request = [[NSFetchRequest alloc]init];
            [request setEntity:entity];
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",album.conPeopleRule];
            [request setPredicate:pre];
            People *p1 = (People *)[favoriteList objectAtIndex:indexPath.row];
            NSError *error = nil;
            NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
            for(int i=0;i<[A count];i++)
            {
                PeopleRuleDetail *p=[A objectAtIndex:i];
                
                
                
                if([p.conPeople isEqual:p1])
                {
                    cell.accessoryView = [self getStateButton];
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
            

        
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:@"Cell"];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //[cell.contentView removeFromSuperview];
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
        name.tag = indexPath.row;
        name.backgroundColor = [UIColor clearColor];
        People *fa=(People *)[phonebookList objectAtIndex:indexPath.row];
        if (fa.firstName == nil) {
            name.text = [NSString stringWithFormat:@"%@",fa.lastName];
        }
        else if(fa.lastName == nil)
        {
            name.text = [NSString stringWithFormat:@"%@",fa.firstName];
        } 
        else
            name.text = [NSString stringWithFormat:@"%@ %@",fa.lastName, fa.firstName];;
        [cell.contentView addSubview:name];
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = indexPath.row;
        [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
        selectButton.frame = CGRectMake(10, 11, 30, 30);
        [selectButton setImage:unselectImg forState:UIControlStateNormal];
        [cell.contentView addSubview:selectButton];
        
        if(album!=nil)
        {                
            NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
            NSFetchRequest *request = [[NSFetchRequest alloc]init];
            [request setEntity:entity];
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeopleRule == %@",album.conPeopleRule];
            [request setPredicate:pre];
            People *p1 = (People *)[phonebookList objectAtIndex:indexPath.row];
            NSError *error = nil;
            NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
            for(int i=0;i<[A count];i++)
            {
                PeopleRuleDetail *p=[A objectAtIndex:i];
                
                
                
                if([p.conPeople isEqual:p1])
                {
                    cell.accessoryView = [self getStateButton];
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

        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}
-(UIButton *)peopleRuleButton
{
    peopleRuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    peopleRuleButton.frame = CGRectMake(0, 0, 75, 28);
    [peopleRuleButton addTarget:self action:@selector(changeRule:) forControlEvents:UIControlEventTouchUpInside];
    [peopleRuleButton setTitle:@"And" forState:UIControlStateNormal];
    peopleRuleButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [peopleRuleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return peopleRuleButton;
    
}
-(void)changeRule:(id)sender{
    UIButton *button = (UIButton *)sender;
    //UITableViewCell *cell = (UITableViewCell *)[button superview];
   // NSIndexPath *index = [table indexPathForCell:cell];
    //NSInteger Row=index.row;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"And"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"Or" forState:UIControlStateNormal];
        album.conPeopleRule.allOrAny=[NSNumber numberWithBool:NO];
        //NSString *rule=@"EXCLUDE";
       // [self update:Row rule:rule];
    }
    else{
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"And" forState:UIControlStateNormal];
        album.conPeopleRule.allOrAny=[NSNumber numberWithBool:YES];
       // NSString *rule=@"INCLUDE";
        //[self update:Row rule:rule];
    }
    [dataSource.coreData saveContext];
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    
    NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABRecordID recId = ABRecordGetRecordID(person);
    NSNumber *fid=[NSNumber numberWithInt:recId];
    if([IdList containsObject:fid])
    {
//        NSString *b=NSLocalizedString(@"Already exists", @"button");
//        NSString *a=NSLocalizedString(@"note", @"button");
//        NSString *c=NSLocalizedString(@"ok", @"button");
//        
//        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:a
//                              message:b
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:c,nil];
//        [alert show];
//        alert.tag=0;
        
    }
    else
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
        People *addressBook=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
        addressBook.firstName=personName;
        addressBook.lastName=lastname;
        addressBook.addressBookId=[NSNumber numberWithInt:[fid intValue]];
        addressBook.inAddressBook=[NSNumber numberWithBool:YES];
        [dataSource.coreData saveContext];
        [self tableReload];
        //[self table];
        //[self.listTable reloadData];
    }
    
     [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self dismissModalViewControllerAnimated:YES];
    return NO;

//    NSString *Name=[NSString stringWithFormat:@"%@ %@",personName,lastname];
//    // NSLog(@"name:%@",lastname);
//    [phonebookList addObject:Name];
//    [self.table reloadData];
//    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
//    [self dismissModalViewControllerAnimated:YES];
//    return NO;
    
	
}
-(void)tableReload
{
    favoriteList=[[NSMutableArray alloc]init];
    phonebookList=[[NSMutableArray alloc]init];
    allList=[[NSMutableArray alloc]init];
    IdList=[[NSMutableArray alloc]init];
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"favorite==%@",[NSNumber numberWithBool:YES]];
    favoriteList= [dataSource simpleQuery:@"People" predicate:favor sortField:@"listSort" sortOrder:YES];
    NSPredicate *ads=[NSPredicate predicateWithFormat:@"inAddressBook==%@",[NSNumber numberWithBool:YES]];
    phonebookList=[dataSource simpleQuery:@"People" predicate:ads sortField:nil sortOrder:YES];
    [allList addObjectsFromArray:favoriteList];
    [allList addObjectsFromArray:phonebookList];
    for(People *p in allList)
    {
        [IdList addObject:p.addressBookId];
    }
    [self.table reloadData];
    
}
-(void)update:(NSInteger)Row rule:(NSString *)rule
{
    People *p1=nil;
    if(Sections==YES)
    {
    p1 = (People *)[favoriteList objectAtIndex:Row];
    }
    else
    {
    p1=(People *)[phonebookList objectAtIndex:Row];
    }
    NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,album.conPeopleRule];
    [request setPredicate:pre];
    NSError *error = nil;
    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
    PeopleRuleDetail *p=[A objectAtIndex:0];
    p.opcode=rule;
    [dataSource.coreData saveContext];
    
}
-(void)insert:(NSInteger)Row rule:(NSString *)rule
{
    People *p1=nil;
    if(Sections==YES)
    {
    p1 = (People *)[favoriteList objectAtIndex:Row];
    }
    else
    {
    p1 = (People *)[phonebookList objectAtIndex:Row];
    }
    NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
    PeopleRuleDetail *prd1=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
    //prd1.firstName=p1.firstName;
    //prd1.lastName=p1.lastName;
    prd1.conPeople=p1;
    [p1 addConPeopleRuleDetailObject:prd1];
    prd1.opcode=rule;   
    prd1.conPeopleRule=album.conPeopleRule;
    [album.conPeopleRule addConPeopleRuleDetailObject:prd1];
    [dataSource.coreData saveContext];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section!=0)
    {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button1 = [self getStateButton];
    if (cell.accessoryView==nil) {
        cell.accessoryView = button1;
        
    }else{
        cell.accessoryView = nil;
    }
    
    for (UIButton *button2 in cell.contentView.subviews) {
        
        if ([button2 isKindOfClass:[UIButton class]]) {
            if ([button2.currentImage isEqual:unselectImg]) {
                [button2 setImage:selectImg forState:UIControlStateNormal]; 
               NSString *rule=@"INCLUDE";
               // NSInteger p=indexPath.section;
                 if(indexPath.section==1)
                 {
                     [nameList addObject:[favoriteList objectAtIndex:indexPath.row]];
                     Sections=YES;
                 }
                else if(indexPath.section==2)
                {
                    [nameList addObject:[phonebookList objectAtIndex:indexPath.row]];
                    Sections=NO;
                }
               [self insert:indexPath.row rule:rule];
                
            }
            
            
            else
            {
                People *p1=nil;
                [button2 setImage:unselectImg forState:UIControlStateNormal];
                if(indexPath.section==1)
                {
                [nameList removeObject:[favoriteList objectAtIndex:indexPath.row]];
                 p1 = (People *)[favoriteList objectAtIndex:indexPath.row];
                }
                else if(indexPath.section==2)
                {
                    [nameList removeObject:[phonebookList objectAtIndex:indexPath.row]];
                    p1 = (People *)[phonebookList objectAtIndex:indexPath.row];
                }
                NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                [request setEntity:entity];
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,album.conPeopleRule];
                [request setPredicate:pre];
                NSError *error = nil;
                NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
                PeopleRuleDetail *p=[A objectAtIndex:0];
                [album.conPeopleRule removeConPeopleRuleDetailObject:p];
                [dataSource.coreData saveContext];
            }
        }
    }
    } 
    
}
-(UIButton *)getStateButton
{
    
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
    NSIndexPath *index = [table indexPathForCell:cell];
    if(index.section==1)
    {
        Sections=YES;
    }
    else if(index.section==2)
    {
        Sections=NO;
    }

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
    //   if(bum==nil)
    //   {
    //       [self album];
    //   }
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *index = [table indexPathForCell:cell];
    NSInteger Row=index.row;
    
    if ([button.currentImage isEqual:selectImg]) {
        [button setImage:unselectImg forState:UIControlStateNormal];
         //       NSIndexPath *index = [listTable indexPathForCell:cell];
        //        [selectedIndexPaths removeObject:index];
        cell.accessoryView = nil;
        //         [button setImage:unselectImg forState:UIControlStateNormal];
        
        People *p1 =nil;
        if(index.section==1)
        {
        p1=(People *)[favoriteList objectAtIndex:Row];
        }
        else if(index.section==2)
        {
            p1=(People *)[phonebookList objectAtIndex:Row];
        }
        NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entity];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,album.conPeopleRule];
        [request setPredicate:pre];
        NSError *error = nil;
        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
        PeopleRuleDetail *p=[A objectAtIndex:0];
        [album.conPeopleRule removeConPeopleRuleDetailObject:p];
        [dataSource.coreData saveContext];    }
    else{
        [button setImage:selectImg forState:UIControlStateNormal];
        cell.accessoryView = [self getStateButton];
        if(index.section==1)
        {
            [nameList addObject:[favoriteList objectAtIndex:Row]];
            Sections=YES;
        }
        else if(index.section==2)
        {
            [nameList addObject:[phonebookList objectAtIndex:Row]];
            Sections=NO;
        }
        NSString *rule=@"INCLUDE";
        [self insert:Row rule:rule];
    }
    //   
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return 0;
}
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[self dismissModalViewControllerAnimated:YES];
}

@end
