//
//  PhotoViewController.h
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PopupPanelView.h"
#import <MediaPlayer/MediaPlayer.h>
#define PADDING 20

@class PhotoImageView;
@class Playlist;;
@class TagSelector;
@class AssetTablePicker;
@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
@private
	
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	UIScrollView *_scrollView;	
    Playlist *playlist;
	NSUInteger currentPageIndex;
    NSUInteger pageIndexBeforeRotation;
                                                   
	BOOL _rotating;
	BOOL _barsHidden;
	BOOL performingLayout;
    BOOL lockMode;
    
    UIView *personView;
	UIBarButtonItem *_actionButton;
    UIBarButtonItem *playPhotoButton;
    UIBarButtonItem *tag;
    UIBarButtonItem *cancel;
    UILabel *tagCount;
    
    BOOL personPt;
    BOOL editing;
    BOOL tagShow;
    BOOL playingPhoto;
    BOOL playingVideo;
    BOOL playingFromSelfPage;
    PopupPanelView *ppv;
    TagSelector *tagSelector;
    AssetTablePicker *__unsafe_unretained assetTablePicker;
                                                        
    NSTimer *controlVisibilityTimer;
    NSTimer *timer;	
    UIButton *playButton;

    MPMoviePlayerController* theMovie;
    UIView *assetInfoView;
    UIButton *likeButton;
    NSString *playPhotoTransition;
}
@property (nonatomic,strong) Playlist *playlist;
@property(nonatomic,assign) AssetTablePicker *assetTablePicker;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,assign) NSUInteger currentPageIndex;
@property(nonatomic,strong)NSString *playPhotoTransition;
@property(nonatomic,assign)BOOL lockMode;
//init
- (id)init;
-(id)initWithBool:(BOOL)play;
- (void)performLayout;

//paging
-(void)updatePages;
- (void)configurePage:(PhotoImageView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (PhotoImageView *)dequeueRecycledPage;
- (PhotoImageView *)pageDisplayedAtIndex:(NSUInteger)index;

//frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
-(CGRect)frameForTagOverlay;
//control
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)hideControlsAfterDelay;
- (void)cancelControlHiding;

//PlayVideo and play photos
-(void)cancelPlayPhotoTimer;
-(void)fireTimer;
-(void)playVideo:(id)sender;
-(void)playVideo;
-(UIButton *)configurePlayButton:(CGRect)framek;

//PhotoInfo method
-(void)showPhotoInfo:(PhotoImageView *)page;
-(void)addPhotoInfoView:(PhotoImageView *)page;

//LikeTag
-(void)showLikeButton:(PhotoImageView *)page;
-(void)likeButtonPressed:(id)sender;
-(void)addTagPeople;
-(void)setTagToolBar;

-(void)numtag;
//Edit
-(void)releasePersonPt;
@end

