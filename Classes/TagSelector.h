//
//  TagSelector.h
//  PhotoApp
//
//  Created by apple on 1/20/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class Asset;
@class People;
@class AlbumDataSource;

@interface TagSelector : NSObject <ABPeoplePickerNavigationControllerDelegate>
{
    
    UIViewController *viewController;
    AlbumDataSource *dataSource;
    People *mypeople;
    NSString *add;
    NSMutableArray *peopleList;
}
@property (nonatomic, strong)People *mypeople;
@property (nonatomic, strong)NSString *add;
@property (nonatomic, strong)NSMutableArray *peopleList;
-(TagSelector *)initWithViewController:(UIViewController *)controller;
-(void)selectTagNameFromContacts;
-(void)selectTagNameFromFavorites;
-(People *)tagPeople;
-(void)saveTagAsset:(Asset *)asset;
-(void)save:(Asset *)asset;
-(void)saveTag:(Asset *)asset people:(People *)pe;
-(void)resetToolBar;
-(void)addTagName;
-(BOOL)tag:(Asset *)asset;
-(void)deleteTag:(Asset *)asset;
-(void)deleteNobody:(Asset *)asset;
-(BOOL)deletePeople:(Asset *)asset people:(People *)pe;
-(BOOL)selectAssert:(Asset *)asset;

@end
