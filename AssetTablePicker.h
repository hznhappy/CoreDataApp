//
//  AssetTablePicker.h
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailCell.h"
#import "Event.h"

@class TagSelector;
@class Album;
@class AlbumDataSource;

@interface AssetTablePicker : UIViewController<ThumbnailCellSelectionDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIView *timeSelectionsView;
    UIView *personView;
    UITableView *table;
    UIToolbar *viewBar;
    UIToolbar *tagBar;
    //UIBarButtonItem *save;
    //UIBarButtonItem *reset;
    UIBarButtonItem *cancel;
    UIBarButtonItem *lock;
	UIAlertView *alert1;
    UITextField *passWord;
    UIBarButtonItem *personButton;
    
	NSMutableArray *crwAssets;
    NSMutableArray *tagRow;
    NSMutableArray *UrlList;
    NSMutableArray *assertList;
    NSMutableArray *AddAssertList;
    NSMutableArray *inAssert;
    NSMutableArray *photoArray;
    NSMutableArray *videoArray;
    BOOL personPt;
    NSArray *allTableData;
    NSArray *photoTableData;
    NSArray *videoTableData;
    NSInteger timeSelectionAll;
    NSInteger timeSelectionPhoto;
    NSInteger timeSelectionVideo;
  
    BOOL mode;
    BOOL load;
    BOOL done;
    BOOL as;
    BOOL action;
    BOOL lockMode;
    BOOL firstLoad;
    BOOL protecteds;
    BOOL photoType;
    BOOL videoType;
    BOOL timeBtPressed;
    BOOL isEvent;
    BOOL isFavorite;
    
    UIButton *name;
    UIImage *green;
    UIImage *red;
    UIImageView *greenImageView;
    UIImageView *redImagView;
    AlbumDataSource *dataSource;
    UITextField *passWord2;
  
   

    UIInterfaceOrientation oritation;
    UIInterfaceOrientation previousOrigaton;
    NSInteger lastRow;
    NSUInteger selectedRow;
    NSInteger photoCount;
    NSInteger videoCount;
    NSInteger portraitIndex;
    NSInteger landscapeIndex;
    NSString *side;
    NSString *ta;
    TagSelector *tagSelector;
    Album *album;
    Event *event;
}
@property (nonatomic,strong)IBOutlet UITableView *table;
@property (nonatomic,strong)IBOutlet UIToolbar *viewBar;
@property (nonatomic,strong)IBOutlet UIToolbar *tagBar;
//@property (nonatomic,strong)IBOutlet UIBarButtonItem *save;
//@property (nonatomic,strong)IBOutlet UIBarButtonItem *reset;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *lock;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *personButton;
@property (nonatomic,strong)NSMutableArray *tagRow;
@property (nonatomic,strong)NSMutableArray *operations;
@property (nonatomic,strong) NSMutableArray *crwAssets;
@property (nonatomic,strong) NSMutableArray *UrlList;
@property (nonatomic,strong)NSMutableArray *likeAssets;
@property (nonatomic,strong)NSMutableArray *AddAssertList;
@property (nonatomic,strong)NSMutableArray *assertList;
@property (nonatomic,strong)NSString *side;
@property (nonatomic,strong)NSString *ta;
//@property (nonatomic,strong)NSNumber *val;
@property (nonatomic,strong)Album *album;
@property (nonatomic,assign)BOOL action;
@property (nonatomic,assign)BOOL lockMode;
@property (nonatomic,assign)BOOL firstLoad;
-(IBAction)playPhotos;
-(IBAction)lockButtonPressed;
-(IBAction)saveTags;
-(IBAction)resetTags;
-(void)selectFromFavoriteNames;
-(void)selectFromAllNames;
-(IBAction)NoBodyButton;
-(IBAction)protectButton;
-(IBAction)personpressed;
-(IBAction)Eventpressed;
-(IBAction)myfavorite;
-(void)EditPhotoTag:(NSNotification *)note;
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation;
-(void)countPhotosAndVideosCounts;
-(void)releasePersonPt;
-(CGRect)setTheTimeSelectionsViewFrame:(CGFloat)y;
-(void)configureTimeSelectionView;
-(void)showTimeSelections;
-(NSString *)configurateLastRowPhotoCount:(NSInteger)pCount VideoCount:(NSInteger)vCount;
-(void)setTimeSelectionWithIndex:(NSInteger)index;
@end