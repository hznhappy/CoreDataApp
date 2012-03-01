//
//  personfilterView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AlbumDataSource.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PeopleRule.h"
#import "Album.h"
#define INCLUDE     @"INCLUDE"
#define EXCLUDE  @"Exclude"
@class PhotoAppDelegate;

@interface personfilterView : UIViewController<UITableViewDelegate,UITableViewDataSource,ABPeoplePickerNavigationControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *favoriteList;
    NSMutableArray *phonebookList;
    NSMutableArray *Title;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    PeopleRule *pr1;
    Album *album;
    UIImage *selectImg;
    UIImage *unselectImg;
    UIButton *stateButton;
    UITableView *table;
    NSMutableArray *nameList;
}

@property(nonatomic,strong)IBOutlet UITableView *table;
@property(nonatomic,strong)Album *album;
-(UIButton *)getStateButton;
@end
