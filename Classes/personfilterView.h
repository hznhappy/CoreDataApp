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
    NSMutableArray *allList;
    NSMutableArray *Title;
    NSMutableArray *IdList;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    PeopleRule *pr1;
    Album *album;
    BOOL Sections;
    UIImage *selectImg;
    UIImage *unselectImg;
    UIButton *stateButton;
    UIButton *peopleRuleButton;
    UITableView *table;
    NSMutableArray *nameList;
    UITableViewCell *peopleRuleCell;
}

@property(nonatomic,strong)IBOutlet UITableView *table;
@property(nonatomic,strong)IBOutlet UITableViewCell *peopleRuleCell;
@property(nonatomic,strong)Album *album;
-(UIButton *)getStateButton;
-(UIButton *)peopleRuleButton;
-(void)tableReload;
@end
