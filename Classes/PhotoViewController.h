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

@class CropView;
@class PhotoImageView;
@class Playlist;;
@class TagSelector;
@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
@private
	NSMutableArray *likeAssets;
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
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
	UIBarButtonItem *_actionButton;
    UIBarButtonItem *edit;
    UIBarButtonItem *saveItem;

	CropView *cropView;
    BOOL editing;
    BOOL tagShow;
    BOOL croping;
    BOOL playingPhoto;
    PopupPanelView *ppv;
    TagSelector *tagSelector;
                                                        
    NSTimer *controlVisibilityTimer;
    NSTimer *timer;	
    UIButton *playButton;

    MPMoviePlayerController* theMovie;
    UIView *assetInfoView;
    UIButton *likeButton;
    
}
@property (nonatomic,strong) Playlist *playlist;
@property(nonatomic,strong)PopupPanelView *ppv;

@property(nonatomic,strong)CropView *cropView;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,assign) NSUInteger currentPageIndex;
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

//control
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)hideControlsAfterDelay;
- (void)cancelControlHiding;

//PlayVideo and play photos
-(void)fireTimer:(NSString *)animateStyle;
-(void)playVideo;
-(void)play:(CGRect)framek;

//PhotoInfo method
-(void)showPhotoInfo;
-(void)addPhotoInfoView;

//LikeTag
-(void)showLikeButton;
-(void)likeButtonPressed:(id)sender;
-(void)addTagPeople;
-(void)setTagToolBar;

-(void)changeCropViewFrame;
@end

