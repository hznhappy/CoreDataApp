//
//  TagSelector.m
//  PhotoApp
//
//  Created by apple on 1/20/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import "TagSelector.h"
#import "AlbumDataSource.h"
#import "PeopleTag.h"
#import "PhotoAppDelegate.h"
#import "People.h"
#import "TagManagementController.h"
#import "Asset.h"
#import "PhotoViewController.h"
#import "PeopleTag.h"
#import "favorite.h"
@implementation TagSelector
//@dynamic mypeople;
@synthesize mypeople;
@synthesize add;
@synthesize peopleList;
-(TagSelector *)initWithViewController:(UIViewController *)controller{
  
    peopleList=[[NSMutableArray alloc]init];
    self = [super init];
    if (self) {
        PhotoAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        dataSource = appDelegate.dataSource;
        viewController = controller;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addTagPeople:) name:@"addTagPeople" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetToolBar) name:@"resetToolBar" object:nil];
    }
    return self;
}

-(void)addTagPeople:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    peopleList=[dic objectForKey:@"people"];
  //  mypeople=[dic objectForKey:@"people"];
    if([add isEqualToString:@"YES"])
    { 
        [self addTagName];
        [self resetToolBar];
    }
    else if([add isEqualToString:@"NO"])
    {
        add=nil;
    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:peopleList,@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1]; 
    }
}
-(BOOL)tag:(Asset *)asset
{
    if([peopleList count]!=0)
    {

    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    if([list count]>0)
    {NSMutableArray *pet=[[NSMutableArray alloc]init];
        for (int i=0; i<[list count]; i++)
    {
        PeopleTag *peopleTag =[list objectAtIndex:i];
        [pet addObject:peopleTag.conPeople];
    }
        for(People *p in peopleList)
        {
        if(![pet containsObject:p])
        {
                return NO;
            }
        }
        return YES;
        /*for (int i=0; i<[list count]; i++)
        {
            PeopleTag *peopleTag =[list objectAtIndex:i];
            // if([peopleList count]>1)
             //{
                 for(int i=0;i<[peopleList count];i++)
                 {NSLog(@"1");
                     if(![peopleTag.conPeople isEqual:[peopleList objectAtIndex:i]])
                     {
                         NSLog(@"2");
                         return NO;
                     }
                 }
                 return YES;
            NSLog(@"3");*/
            // }
            /*else
            {
            if([peopleTag.conPeople isEqual:[peopleList objectAtIndex:0]])
            {
                return YES;
            }
            }*/
        // }
    }
    
    }
   
    return NO;
}
-(void)deleteTag:(Asset *)asset
{
    for(People *pe in peopleList)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
        NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
        for (int i=0; i<[list count]; i++) {
            PeopleTag *peopleTag =[list objectAtIndex:i];
            if([peopleTag.conPeople isEqual:pe])
            { 
                [pe removeConPeopleTagObject:peopleTag];
                [asset removeConPeopleTagObject:peopleTag];
                asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]-1];
                [dataSource.coreData.managedObjectContext deleteObject:peopleTag];
                
                
            }
        }
        
    }
    [dataSource.coreData saveContext];
    
}
-(People *)tagPeople{
    
    return mypeople;
}
-(void)selectTagNameFromContacts{
   // NSLog(@"")
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate = self;
    [viewController presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)selectTagNameFromFavorites{
    TagManagementController *nameController = [[TagManagementController alloc]init];
    nameController.bo=[NSString stringWithFormat:@"yes"];
    [nameController table];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:nameController];
    [viewController presentModalViewController:navController animated:YES];
}

-(void)saveTagAsset:(Asset *)asset{
    
    
    favorite *fi=[dataSource.favoriteList objectAtIndex:0];
    People *p1=fi.people;
    if([peopleList containsObject:p1])
    {
        BOOL b=[self selectAssert:asset];
        if(b==YES)
        {
            
        }
        else
        {    
            if([peopleList count]>1)
            {
            }
            else
            {
                for(People *po in peopleList)
                {
                    BOOL b=[self deletePeople:asset people:po];
                    if(b==NO)
                    {
                        
                        [self save:asset];
                        [(PhotoViewController *)viewController numtag];
                    }
                    
                }

            }
        }
    }
    else
    {
        for(People *po in peopleList)
        {
            BOOL b=[self deletePeople:asset people:po];
            if(b==NO)
            {
            
            [self save:asset];
            [(PhotoViewController *)viewController numtag];
        }
  
    }
    }
}
-(BOOL)deletePeople:(Asset *)asset people:(People *)pe
{ 
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    if([list count]>0)
    {NSMutableArray *pet=[[NSMutableArray alloc]init];
        for (int i=0; i<[list count]; i++)
        {
            PeopleTag *peopleTag =[list objectAtIndex:i];
            [pet addObject:peopleTag.conPeople];
        }
        
        if([pet containsObject:pe])
        {
            return YES;
        }
    }
   


     return NO;
}
-(void)deleteNobody:(Asset *)asset
{
    favorite *fi=[dataSource.favoriteList objectAtIndex:0];
    People *p1=fi.people;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople== %@",p1];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    for(int i=0;i<[list count];i++)
    {
        PeopleTag *peopleTag =[list objectAtIndex:i];
        if(peopleTag.conAsset==asset)
        {
        [p1 removeConPeopleTagObject:peopleTag];
        [asset removeConPeopleTagObject:peopleTag];
        asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]-1]; 
        break;
        }
    }
    

}
-(void)save:(Asset *)asset
{
    
    if([asset.nobody boolValue])
    {
        NSLog(@"nobody");
        [self deleteNobody:asset];
    }
    if([peopleList count]>1)
    {
        for(People *pe in peopleList)
        {
            BOOL add1=[self deletePeople:asset people:pe];
            if(add1==NO)
            {
                [self saveTag:asset people:pe];
            }
        }
    }
   
    else
    {
    for(People *pe in peopleList)
    {
      [self saveTag:asset people:pe];
    }
    }
    [dataSource.coreData saveContext];

}
-(void)saveTag:(Asset *)asset people:(People *)pe
{

    if(pe.addressBookId==[NSNumber numberWithInt:-1])
    {
        asset.nobody=[NSNumber numberWithBool: YES];
    }
    asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]+1];
    PeopleTag  *peopleTag= [NSEntityDescription insertNewObjectForEntityForName:@"PeopleTag" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
    peopleTag.conAsset = asset;
    [asset addConPeopleTagObject:peopleTag];
    peopleTag.conPeople = pe;
    [pe addConPeopleTagObject:peopleTag];

    
}
-(BOOL)selectAssert:(Asset *)asset
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    if([list count]>0)
    {
        return YES;
    }
    return NO;
}
#pragma mark -
#pragma mark People picker delegate
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    [peopleList removeAllObjects];
    mypeople=nil;
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    ABRecordID recId = ABRecordGetRecordID(person);
    
    NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"addressBookId == %@",[NSNumber numberWithInteger:recId]];
    [request setPredicate:pre];
    
    NSError *error = nil;
    NSArray *array = [managedObjectsContext executeFetchRequest:request error:&error];
    if (array != nil && [array count] && error == nil) {
        mypeople = [array objectAtIndex:0];
    }else{
        mypeople = [NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:managedObjectsContext];
        mypeople.firstName = firstName;
        mypeople.lastName = lastName;
        mypeople.addressBookId = [NSNumber numberWithInteger:recId];
        mypeople.inAddressBook=[NSNumber numberWithBool:YES];
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [viewController dismissModalViewControllerAnimated:YES];
    if([add isEqualToString:@"YES"])
    {
        [peopleList addObject:mypeople];
        [self addTagName];
        [self resetToolBar];
    }
    else
    {
        add=nil;
       /* NSString *people=nil;
        if(mypeople.firstName==nil)
        {
            people=[NSString stringWithFormat:@"%@",mypeople.lastName];
        }
        else if(mypeople.lastName==nil)
        {
            people=[NSString stringWithFormat:@"%@",mypeople.firstName];
            
        }
        else
        {
            people=[NSString stringWithFormat:@"%@ %@",mypeople.firstName,mypeople.lastName];
        }*/
        [peopleList addObject:mypeople];

    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:peopleList,@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1];
    }

    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [viewController dismissModalViewControllerAnimated:YES];
    [self resetToolBar];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

-(void)addTagName{
    if ([viewController isKindOfClass:[PhotoViewController class]]) { 
        [(PhotoViewController *)viewController addTagPeople];
    }
}
#pragma mark -
#pragma mark reset ToolBar
-(void)resetToolBar{
    if ([viewController isKindOfClass:[PhotoViewController class]]) {
        [(PhotoViewController *)viewController setTagToolBar];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
