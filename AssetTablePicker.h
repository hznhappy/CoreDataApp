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
    
    NSNumber *val;
    UITextField *passWord2;
  
   

    UIInterfaceOrientation oritation;
    UIInterfaceOrientation previousOrigaton;

    NSUInteger selectedRow;
    TagSelector *tagSelector;
}
@property (nonatomic,retain)IBOutlet UITableView *table;
@property (nonatomic,retain)IBOutlet UIToolbar *viewBar;
@property (nonatomic,retain)IBOutlet UIToolbar *tagBar;
@property (nonatomic,retain)IBOutlet UIBarButtonItem *save;
@property (nonatomic,retain)IBOutlet UIBarButtonItem *reset;
@property (nonatomic,retain)IBOutlet UIBarButtonItem *lock;

@property (nonatomic,retain)NSMutableArray *tagRow;
@property (nonatomic,retain)NSMutableArray *operations;
@property (nonatomic,retain) NSMutableArray *crwAssets;
@property (nonatomic,retain) NSMutableArray *UrlList;
@property (nonatomic,retain)NSNumber *val;
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