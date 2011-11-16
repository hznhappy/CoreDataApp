//
//  AssetTablePicker.h
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Thumbnail.h"
#import "sqlite3.h"
#import "DBOperation.h"
#define TAG @"TAG"


@interface AssetTablePicker : UIViewController<UIScrollViewDelegate,UINavigationControllerDelegate,ABPeoplePickerNavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView *table;
    UIToolbar *viewBar;
    UIToolbar *tagBar;
    UIBarButtonItem *save;
    UIBarButtonItem *reset;
    UIBarButtonItem *cancel;
    NSString *selectName;

	ALAssetsGroup *assetGroup;
	
	NSMutableArray *crwAssets;
    NSMutableArray *assetArrays;
	NSMutableArray *urlsArray;
    NSMutableArray *selectUrls;
    NSMutableArray *dateArray;
	
    DBOperation *dataBase;
	Thumbnail *thuView;
    BOOL mode;
    NSString *UserId;
    NSString *UserName;
    NSMutableArray *UrlList;
}
@property (nonatomic,retain)IBOutlet UITableView *table;
@property (nonatomic,retain)IBOutlet UIToolbar *viewBar;
@property (nonatomic,retain)IBOutlet UIToolbar *tagBar;
@property (nonatomic,retain)IBOutlet UIBarButtonItem *save;
@property (nonatomic,retain)IBOutlet UIBarButtonItem *reset;
@property(nonatomic,retain)NSString *UserId;
@property(nonatomic,retain)NSString *UserName;
@property (nonatomic,assign) ALAssetsGroup  *assetGroup;

@property (nonatomic,retain) DBOperation *dataBase;

@property (nonatomic,retain) NSMutableArray *crwAssets;
@property (nonatomic,retain) NSMutableArray *assetArrays;
@property (nonatomic,retain) NSMutableArray *urlsArray;
@property (nonatomic,retain) NSMutableArray *selectUrls;
@property (nonatomic,retain) NSMutableArray *dateArry;
@property (nonatomic,retain) NSMutableArray *UrlList;
-(IBAction)actionButtonPressed;
-(IBAction)playPhotos;
-(IBAction)lockButtonPressed;
-(IBAction)saveTags;
-(IBAction)resetTags;
-(IBAction)selectFromFavoriteNames;
-(IBAction)selectFromAllNames;
-(void)loadPhotos;
-(void)setPhotoTag;
-(void)AddUrl:(NSNotification *)note;
-(void)RemoveUrl:(NSNotification *)note;
-(void)AddUser:(NSNotification *)note;
-(void)creatTable;
@end