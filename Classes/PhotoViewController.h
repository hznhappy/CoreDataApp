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
@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate,
                                                    MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
@private
	NSMutableArray *_photoViews;
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	UIScrollView *_scrollView;	
    Playlist *playlist;
	NSUInteger currentPageIndex;
                                                        
	BOOL _rotating;
	BOOL _barsHidden;
	
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
	UIBarButtonItem *_actionButton;
    UIBarButtonItem *edit;
    UIBarButtonItem *saveItem;

	CropView *cropView;
    BOOL editing;
    BOOL tagShow;
    BOOL croping;

    PopupPanelView *ppv;
    NSTimer *controlVisibilityTimer;
    NSTimer *timer;	
    UIButton *playButton;
    NSMutableArray *video;
    BOOL VI;

    MPMoviePlayerController* theMovie;
    UIView *favorite;
    
    UIImageView *bubbleImageView;
}
@property (nonatomic, retain) Playlist *playlist;
@property(nonatomic,retain)PopupPanelView *ppv;
@property(nonatomic,retain)NSMutableArray *video;
@property(nonatomic,retain) NSArray *photoSource;
@property(nonatomic,retain) NSMutableArray *photoViews;

@property(nonatomic,retain)CropView *cropView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,assign) NSUInteger currentPageIndex;

//init
- (id)init;

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

//LikeTag
-(void)favorite:(NSString *)inter;
-(void)CFG;
-(void)likeButtonPressed;
-(void)button2Pressed;

@end

@interface UIImage (Crop)

- (UIImage *)crop:(CGRect)rect;
@end