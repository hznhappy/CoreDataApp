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

@implementation TagSelector
//@dynamic mypeople;
@synthesize mypeople;
-(TagSelector *)initWithViewController:(UIViewController *)controller{
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
    mypeople=[dic objectForKey:@"people"];
    [self addTagName];
    [self resetToolBar];
    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1];
}
-(BOOL)tag:(Asset *)asset
{
     NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    if([list count]>0)
    {
        for (int i=0; i<[list count]; i++) {
            PeopleTag *peopleTag =[list objectAtIndex:i];
            if([peopleTag.conPeople isEqual:mypeople])
            {
                return YES;
            }
        }
    }
   
    return NO;
}
-(void)deleteTag:(Asset *)asset
{
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",asset];
    NSArray *list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    for (int i=0; i<[list count]; i++) {
        PeopleTag *peopleTag =[list objectAtIndex:i];
        if([peopleTag.conPeople isEqual:mypeople])
        {
            [mypeople removeConPeopleTagObject:peopleTag];
            [asset removeConPeopleTagObject:peopleTag];
            asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]-1];
        }
    }
    [dataSource.coreData saveContext];

    
    
}
-(People *)tagPeople{
    
    return mypeople;
}
-(void)selectTagNameFromContacts{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate = self;
    [viewController presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)selectTagNameFromFavorites{
    TagManagementController *nameController = [[TagManagementController alloc]init];
    nameController.bo=[NSString stringWithFormat:@"yes"];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:nameController];
    [viewController presentModalViewController:navController animated:YES];
}

-(void)saveTagAsset:(Asset *)asset{
    asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]+1];
    PeopleTag  *peopleTag= [NSEntityDescription insertNewObjectForEntityForName:@"PeopleTag" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
    peopleTag.conAsset = asset;
    [asset addConPeopleTagObject:peopleTag];
    peopleTag.conPeople = mypeople;
    [mypeople addConPeopleTagObject:peopleTag];
    [dataSource.coreData saveContext];
}
#pragma mark -
#pragma mark People picker delegate
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    
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
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [viewController dismissModalViewControllerAnimated:YES];
    if ([viewController isKindOfClass:[PhotoViewController class]]) {
        [self addTagName];
        [self resetToolBar];
    }
    
    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1];
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
