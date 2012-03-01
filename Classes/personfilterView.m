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

-(void)viewDidLoad
{
    
    nameList=[[NSMutableArray alloc]init];
    favoriteList=[[NSMutableArray alloc]init];
    phonebookList=[[NSMutableArray alloc]init];
    Title=[[NSMutableArray alloc]initWithObjects:@"Favorite",@"phonebook",nil];
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
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"favorite==%@",[NSNumber numberWithBool:YES]];
    favoriteList= [dataSource simpleQuery:@"People" predicate:favor sortField:@"listSort" sortOrder:YES];
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
    NSLog(@"come back");
    [self.navigationController popViewControllerAnimated:YES]; 
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:nameList,@"name",nil];
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
        return favoriteList.count;
    }
    else
        return phonebookList.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
        name.text=[phonebookList objectAtIndex:indexPath.row];
        [cell.contentView addSubview:name];
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = indexPath.row;
        [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
        selectButton.frame = CGRectMake(10, 11, 30, 30);
        [selectButton setImage:unselectImg forState:UIControlStateNormal];
        [cell.contentView addSubview:selectButton];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    
    
    NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    // ABRecordID recId = ABRecordGetRecordID(person);
    //fid=[NSNumber numberWithInt:recId];
    //    if([self.IdList containsObject:fid])
    //    {
    //        /* NSString *b=NSLocalizedString(@"Already exists", @"button");
    //         NSString *a=NSLocalizedString(@"note", @"button");
    //         NSString *c=NSLocalizedString(@"ok", @"button");
    //         
    //         
    //         UIAlertView *alert = [[UIAlertView alloc]
    //         initWithTitle:a
    //         message:b
    //         delegate:self
    //         cancelButtonTitle:nil
    //         otherButtonTitles:c,nil];
    //         [alert show];
    //         alert.tag=0;*/
    //        
    //    }
    //    else
    //    {
    //        NSPredicate *favor=[NSPredicate predicateWithFormat:@"addressBookId==%@",fid]; 
    //        NSArray *fa1 = [datasource simpleQuery:@"People" predicate:favor sortField:nil sortOrder:YES];
    //        if([fa1 count]==0)
    //        {
    //            NSLog(@"whit out");
    //            NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[datasource.coreData managedObjectContext]]; 
    //            favorate=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[datasource.coreData managedObjectContext]];
    //            favorate.firstName=personName;
    //            favorate.lastName=lastname;
    //            favorate.addressBookId=[NSNumber numberWithInt:[fid intValue]];
    //            favorate.favorite=[NSNumber numberWithBool:YES];
    //            favorite *fe=[peopleList lastObject];
    //            favorate.listSort=[NSNumber numberWithInt:[fe.people.listSort intValue]+1];
    //            [datasource.coreData saveContext];
    //            // peopleList=[datasource addPeople:favorate];
    //            [peopleList addObjectsFromArray:[datasource addPeople:favorate]];
    //            [self.result addObject:favorate];
    //            [IdList addObject:fid];
    //            [self.tableView reloadData];
    //        }
    //        else
    //        {NSLog(@"with");
    //            People *p=(People *)[fa1 objectAtIndex:0];
    //            p.favorite=[NSNumber numberWithBool:YES];
    //            p.inAddressBook=[NSNumber numberWithBool:NO];
    //            favorite *fe=[peopleList lastObject];
    //            p.listSort=[NSNumber numberWithInt:[fe.people.listSort intValue]+1];
    //            NSLog(@"FElistSort:%@",favorate.listSort);
    //            [datasource.coreData saveContext];
    //            [self table];
    //            
    //        }
    //    }
    NSString *Name=[NSString stringWithFormat:@"%@ %@",personName,lastname];
    // NSLog(@"name:%@",lastname);
    [phonebookList addObject:Name];
    [self.table reloadData];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
    
	
}
-(void)update:(NSInteger)Row rule:(NSString *)rule
{
    People *p1 = (People *)[favoriteList objectAtIndex:Row];
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
    People *p1 = (People *)[favoriteList objectAtIndex:Row];
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
               [self insert:indexPath.row rule:rule];
                [nameList addObject:[favoriteList objectAtIndex:indexPath.row]];
            }
            
            
            else
            {
                [button2 setImage:unselectImg forState:UIControlStateNormal];
                [nameList removeObject:[favoriteList objectAtIndex:indexPath.row]];
                People *p1 = (People *)[favoriteList objectAtIndex:indexPath.row];
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
    // NSIndexPath *index = [listTable indexPathForCell:cell];
    // NSInteger Row=index.row;
    
    if ([button.currentImage isEqual:selectImg]) {
        [button setImage:unselectImg forState:UIControlStateNormal];
        //        NSIndexPath *index = [listTable indexPathForCell:cell];
        //        [selectedIndexPaths removeObject:index];
        cell.accessoryView = nil;
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
    }
    else{
        [button setImage:selectImg forState:UIControlStateNormal];
        // NSIndexPath *index = [listTable indexPathForCell:cell];
        //[selectedIndexPaths addObject:index];
        cell.accessoryView = [self getStateButton];
        //        NSString *rule=@"INCLUDE";
        //        [self insert:index.row rule:rule];
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
