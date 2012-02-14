//
//  AssetTablePicker.h
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailCell.h"

@class TagSelector;
@class Album;


@interface AssetTablePicker : UIViewController<ThumbnailCellSelectionDelegate,UITableViewDelegate,UITableViewDataSource>
{

    UITableView *table;
    UIToolbar *viewBar;
    UIToolbar *tagBar;
    UIBarButtonItem *save;
    UIBarButtonItem *reset;
    UIBarButtonItem *cancel;
    UIBarButtonItem *lock;
	UIAlertView *alert1;
    UITextField *passWord;

	NSMutableArray *crwAssets;
    NSMutableArray *tagRow;
    NSMutableArray *UrlList;
    NSMutableArray *assertList;
    NSMutableArray *inAssert;
  
    BOOL mode;
    BOOL load;
    BOOL done;
    BOOL as;
    BOOL action;
    BOOL lockMode;
  
    
  
 
    NSNumber *val;
    UITextField *passWord2;
  
   

    UIInterfaceOrientation oritation;
    UIInterfaceOrientation previousOrigaton;
    NSInteger lastRow;
    NSUInteger selectedRow;
    TagSelector *tagSelector;
    Album *album;
}
@property (nonatomic,strong)IBOutlet UITableView *table;
@property (nonatomic,strong)IBOutlet UIToolbar *viewBar;
@property (nonatomic,strong)IBOutlet UIToolbar *tagBar;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *save;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *reset;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *lock;

@property (nonatomic,strong)NSMutableArray *tagRow;
@property (nonatomic,strong)NSMutableArray *operations;
@property (nonatomic,strong) NSMutableArray *crwAssets;
@property (nonatomic,strong) NSMutableArray *UrlList;
@property (nonatomic,strong)NSNumber *val;
@property (nonatomic,strong)Album *album;
-(IBAction)actionButtonPressed;
-(IBAction)playPhotos;
-(IBAction)lockButtonPressed;
-(IBAction)saveTags;
-(IBAction)resetTags;
-(IBAction)selectFromFavoriteNames;
-(IBAction)selectFromAllNames;
-(void)EditPhotoTag;
//-(void)resetTableContentInset;
@end