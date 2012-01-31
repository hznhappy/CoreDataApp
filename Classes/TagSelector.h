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
}
@property (nonatomic, strong)People *mypeople;
-(TagSelector *)initWithViewController:(UIViewController *)controller;
-(void)selectTagNameFromContacts;
-(void)selectTagNameFromFavorites;
-(People *)tagPeople;
-(void)saveTagAsset:(Asset *)asset;
-(void)resetToolBar;
-(void)addTagName;
-(BOOL)tag:(Asset *)asset;
-(void)deleteTag:(Asset *)asset;
@end
