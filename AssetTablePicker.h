//
//  AssetTablePicker.h
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailCell.h"

@class TagSelector;



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
        
    BOOL ME;
    BOOL PASS;
    BOOL mode;
    BOOL load;
    BOOL done;
    BOOL action;
    BOOL lockMode;
    NSNumber *val;
    UITextField *passWord2;
  
   

    UIInterfaceOrientation oritation;
    UIInterfaceOrientation previousOrigaton;

    NSUInteger selectedRow;
    TagSelector *tagSelector;
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
-(IBAction)actionButtonPressed;
-(IBAction)playPhotos;
-(IBAction)lockButtonPressed;
-(IBAction)saveTags;
-(IBAction)resetTags;
-(IBAction)selectFromFavoriteNames;
-(IBAction)selectFromAllNames;
-(void)viewPhotos:(id)sender;
-(void)EditPhotoTag;
@end