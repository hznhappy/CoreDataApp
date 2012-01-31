//
//  PhotoViewController.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PhotoViewController.h"
#import "PopupPanelView.h"
#import "TagManagementController.h"
#import "PhotoImageView.h"
#import "PhotoScrollView.h"
#import "CropView.h"
#import "Playlist.h"
#import "Asset.h"
#import "TagSelector.h"
#import "PhotoAppDelegate.h"

@interface PhotoViewController (Private)

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)setPhotoInfoHidden:(BOOL)hidden;
-(void)setLikeButtonHidden:(BOOL)hidden;
- (NSInteger)centerPhotoIndex;
- (void)setupToolbar;
-(void)setCropConstrainToolBar;
- (void)setupEditToolbar;
- (void)updateNavigation;
@end

//@implementation UIImage (Crop)
//
//- (UIImage *)crop:(CGRect)rect {
//    
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    
//    if (scale>1.0) {        
//        rect = CGRectMake(rect.origin.x*scale , rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);        
//    }
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
//    UIImage *result = [UIImage imageWithCGImage:imageRef]; 
//    CGImageRelease(imageRef);
//    return result;
//}
//
//@end

@implementation PhotoViewController


@synthesize ppv;
@synthesize scrollView=_scrollView;
@synthesize currentPageIndex;
@synthesize cropView;
@synthesize playlist;
@synthesize lockMode;
#pragma mark -
#pragma mark init method

- (id)init{
	if ((self = [super init])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"PhotoViewToggleBars" object:nil];
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;		
        recycledPages = [[NSMutableSet alloc] init];
        visiblePages  = [[NSMutableSet alloc] init];
        Playlist *tempPlaylist = [[Playlist alloc]init];
        self.playlist = tempPlaylist;
        playingPhoto = NO;
    }
    
    return self;
}

-(id)initWithBool:(BOOL)play{
    if ((self = [super init])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"PhotoViewToggleBars" object:nil];
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;		
        recycledPages = [[NSMutableSet alloc] init];
        visiblePages  = [[NSMutableSet alloc] init];
        Playlist *tempPlaylist = [[Playlist alloc]init];
        self.playlist = tempPlaylist;
        playingPhoto = YES;
    }
    
    return self;
}

- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
	self.scrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	self.scrollView.contentSize = [self contentSizeForPagingScrollView];
	for (PhotoImageView *page in visiblePages) {
        page.frame = [self frameForPageAtIndex:page.index];
    }
    
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.scrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
    CGRect buttonFram = [self frameForPageAtIndex:currentPageIndex];
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    NSString *strUrl = asset.url;
    ALAsset *as = [self.playlist.assets objectForKey:strUrl];
    if ([[as valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        CGRect frame1 =buttonFram;
        frame1.origin.x =buttonFram.origin.x + buttonFram.size.width/2 - 30;
        frame1.origin.y = buttonFram.origin.y + buttonFram.size.height/2 - 20;
        frame1.size.height=60;
        frame1.size.width=60;
        playButton.frame = frame1;
        if (theMovie != nil && theMovie.view.superview != nil) {
            PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
            CGRect videoFrame = [photoView.scrollView convertRect:photoView.imageView.frame toView:self.view];
            [[theMovie view] setFrame:videoFrame];
        }
    }

	performingLayout = NO;
    
}


#pragma mark -
#pragma mark View Controller Methods

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
	[self setupToolbar];
    [self updateNavigation];
	
    
}

- (void)viewWillDisappear:(BOOL)animated{

	[super viewWillDisappear:animated];
    [theMovie stop];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [self.navigationController setToolbarHidden:YES animated:YES];		
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    self.wantsFullScreenLayout = YES;
	self.view.backgroundColor = [UIColor blackColor];
    tagSelector = [[TagSelector alloc]initWithViewController:self];
	if (!_scrollView) {
		
		_scrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
		_scrollView.delegate=self;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_scrollView.multipleTouchEnabled=YES;
		_scrollView.scrollEnabled=YES;
		_scrollView.directionalLockEnabled=YES;
		_scrollView.canCancelContentTouches=YES;
		_scrollView.delaysContentTouches=YES;
		_scrollView.clipsToBounds=YES;
		_scrollView.alwaysBounceHorizontal=YES;
		_scrollView.bounces=YES;
		_scrollView.pagingEnabled=YES;
		_scrollView.showsVerticalScrollIndicator=NO;
		_scrollView.showsHorizontalScrollIndicator=NO;
		_scrollView.backgroundColor = self.view.backgroundColor;
        _scrollView.contentSize = [self contentSizeForPagingScrollView];
        _scrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
		[self.view addSubview:_scrollView];
        
	}

    likeAssets = [[NSMutableArray alloc]init];
    tagShow = NO;
    editing=NO;
    croping = NO;
    NSString *u=NSLocalizedString(@"Edit", @"title");
    NSString *save = NSLocalizedString(@"Save", @"title");
    if (!lockMode) {
        edit=[[UIBarButtonItem alloc]initWithTitle:u style:UIBarButtonItemStyleBordered target:self action:@selector(edit)];
        saveItem=[[UIBarButtonItem alloc]initWithTitle:save style:UIBarButtonItemStyleDone target:self action:@selector(savePhoto)];
        
        self.navigationItem.rightBarButtonItem=edit;
    }
       
    [self updatePages];
    
}


#pragma mark -
#pragma mark Pagging Methods

-(void)updatePages{
    // Calculate which pages are visible
    CGRect visibleBounds = self.scrollView.bounds;
    int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > self.playlist.storeAssets.count - 1) iFirstIndex = self.playlist.storeAssets.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > self.playlist.storeAssets.count - 1) iLastIndex = self.playlist.storeAssets.count - 1;

    
    // Recycle no-longer-visible pages 
    for (PhotoImageView *page in visiblePages) {
        if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			/*NSLog(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}

    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
   for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            PhotoImageView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[PhotoImageView alloc] init];
                page.playlist = self.playlist;
            }
            [self.scrollView addSubview:page];
            [self configurePage:page forIndex:index];
            [visiblePages addObject:page];
        }
    }    
    
}

- (void)configurePage:(PhotoImageView *)page forIndex:(NSUInteger)index{
    CGRect rect = [self frameForPageAtIndex:index];
    page.index = index;
    page.imageView.image = nil;
    page.frame = rect;
    [page loadIndex:index];
    Asset *asset = [self.playlist.storeAssets objectAtIndex:index];
    NSString *strUrl = asset.url;
    ALAsset *as = [self.playlist.assets objectForKey:strUrl];
    if ([[as valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        CGRect frame1 =rect;
        frame1.origin.x =rect.origin.x + rect.size.width/2 - 30;
        frame1.origin.y = rect.origin.y + rect.size.height/2 - 20;
        frame1.size.height=60;
        frame1.size.width=60;
        [self play:frame1];
        if (playingPhoto) {
            [self playVideo];
            [timer invalidate];
        }
    }
    
    if (!playingPhoto) {
        [self showPhotoInfo];
    }
    
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index{
    BOOL foundPage = NO;
    for (PhotoImageView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (PhotoImageView *)pageDisplayedAtIndex:(NSUInteger)index {
	PhotoImageView *thePage = nil;
	for (PhotoImageView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; 
            break;
		}
	}
	return thePage;
}


- (PhotoImageView *)dequeueRecycledPage{
    PhotoImageView *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

#pragma mark -
#pragma mark Frame Methods
- (CGRect)frameForPagingScrollView{
   // NSLog(@"view bounds is %@",NSStringFromCGRect(self.view.bounds));
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

 - (CGRect)frameForPageAtIndex:(NSUInteger)index{
     CGRect bounds = self.scrollView.bounds;
     CGRect pageFrame = bounds;
     pageFrame.size.width -= (2 * PADDING);
     pageFrame.origin.x = (bounds.size.width * index) + PADDING;
     return pageFrame;

 }

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = self.scrollView.bounds;
    //NSLog(@"%@ is scrollView BOUNDS",NSStringFromCGSize(bounds.size));
    return CGSizeMake(bounds.size.width * self.playlist.storeAssets.count, bounds.size.height);
}


- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = self.scrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
   // NSLog(@"contentOffeset is %f",newOffset);
	return CGPointMake(newOffset, 0);
}

#pragma mark -
#pragma mark Control Methods
- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < self.playlist.storeAssets.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		self.scrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)hideControls { [self setBarsHidden:!_barsHidden animated:YES]; }

#pragma mark -
#pragma mark PhotoInfo and likeButton method
-(void)showPhotoInfo{
    
    if (assetInfoView || assetInfoView.superview != nil) {
        [assetInfoView removeFromSuperview];
        assetInfoView = nil;
    }
    if (likeButton || likeButton.superview != nil) {
        [likeButton removeFromSuperview];
        likeButton = nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPhotoInfoView) object:nil];
    [self performSelector:@selector(addPhotoInfoView) withObject:nil afterDelay:2];
    if (lockMode) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLikeButton) object:nil];
        [self performSelector:@selector(showLikeButton) withObject:nil afterDelay:2];
    }
    
}

-(void)addPhotoInfoView{
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    assetInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 1/2 , 130, 120)];
    [assetInfoView.layer setCornerRadius:10.0];
    [assetInfoView setClipsToBounds:YES]; 
    if (!lockMode) {
        UILabel *likeCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, 120, 25)];
        likeCount.backgroundColor = [UIColor clearColor];
        likeCount.text = [NSString stringWithFormat:@"LIKE COUNT:%@",[asset.numOfLike description]];
        likeCount.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        likeCount.font = [UIFont boldSystemFontOfSize:14];
        
        UILabel *tagCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 120, 25)];
        tagCount.backgroundColor = [UIColor clearColor];
        tagCount.text = [NSString stringWithFormat:@"TAG COUNT:%@",[asset.numPeopleTag description]];
        tagCount.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        tagCount.font = [UIFont boldSystemFontOfSize:14];
        [assetInfoView addSubview:likeCount];
        [assetInfoView addSubview:tagCount];
    }
    UILabel *date = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 25)];
    
    date.backgroundColor = [UIColor clearColor];
    NSString *dateStr = [asset.date description];
    if (dateStr.length == 0 || dateStr == nil) {
        date.text = [NSString stringWithFormat:@"DATE: "];
        date.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        date.font = [UIFont boldSystemFontOfSize:14];
    }else{
        date.text = [NSString stringWithFormat:@"DATE:%@",dateStr];
        date.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        date.font = [UIFont systemFontOfSize:14];
    }
    
    [assetInfoView setBackgroundColor:[UIColor clearColor]];
    //assetInfoView.alpha = 0.4;
    [assetInfoView addSubview:date];
    
    [self.view addSubview:assetInfoView];
}

-(void)showLikeButton{
    likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect mainScreen = self.view.frame;
    likeButton.frame = CGRectMake(mainScreen.size.width*4/5, mainScreen.size.height*3/4, 50, 50);
    
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    if ([likeAssets containsObject:asset]) {
        [likeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    }else{
        [likeButton setImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
    }
    
    [likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likeButton];
}
-(void)likeButtonPressed:(id)sender
{
    UIButton *like = (UIButton *)sender;
     Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    if ([like.imageView.image isEqual:[UIImage imageNamed:@"unlike.png"]]) {
        [likeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [likeAssets addObject:asset];
        asset.numOfLike = [NSNumber numberWithInt:[asset.numOfLike intValue]+1];
    }else{
        [like setImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
        [likeAssets removeObject:asset];
        asset.numOfLike = [NSNumber numberWithInt:[asset.numOfLike intValue]-1];
    }
    PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.dataSource.coreData saveContext];
}

#pragma mark -
#pragma mark PlayVideo Methods

-(void)play:(CGRect)framek
{
    if (playButton && playButton.superview != nil) {
        [playButton removeFromSuperview];
        playButton = nil;
    }
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    UIImage *picture = [UIImage imageNamed:@"ji.png"];
    // set the image for the button
    [playButton setBackgroundImage:picture forState:UIControlStateNormal];
    [playButton setBackgroundColor:[UIColor clearColor]];
    playButton.frame =framek;
    [self.scrollView addSubview:playButton];
}


-(void)playVideo
{
    playButton.hidden = YES;
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    NSString *strUrl = asset.url;
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    if (theMovie != nil && theMovie.view.superview != nil) {
        [theMovie.view removeFromSuperview];
        theMovie = nil;
    }
    theMovie=[[MPMoviePlayerController alloc] initWithContentURL:url]; 
    //  NSTimeInterval duration = theMovie.duration;
    //  NSLog(@"LENGTH:%f",theMovie.duration);
    PhotoImageView *_imageView = [self pageDisplayedAtIndex:currentPageIndex];
    CGRect videoFrame = CGRectMake(0, 0, _imageView.imageView.frame.size.width, _imageView.imageView.frame.size.height);
    [[theMovie view] setFrame:videoFrame]; // Frame must match parent view
    [_imageView.imageView addSubview:[theMovie view]];
    //theMovie.scalingMode =  MPMovieControlModeDefault;
    // theMovie.scalingMode=MPMovieScalingModeAspectFill; 
    theMovie.scalingMode=MPMovieMediaTypeMaskAudio;
    theMovie.controlStyle = MPMovieControlModeHidden;
    //theMovie.scalingMode = MPMovieScalingModeFill;
    //   UIImage *imageSel = [theMovie thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    // Register for the playback finished notification. 
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(myMovieFinishedCallback:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:theMovie]; 
    
    // Movie playback is asynchronous, so this method returns immediately. 
    [theMovie play];  
    
    
    
    
}
// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification 
{
    playButton.hidden = NO;
    MPMoviePlayerController* theMovie2=[aNotification object]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:theMovie2]; 
    [theMovie.view removeFromSuperview];
    theMovie = nil;
    if (playingPhoto) {
        [timer fire];
    }
}

#pragma mark - 
#pragma mark Rotate orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _rotating = YES;
    pageIndexBeforeRotation = currentPageIndex;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    currentPageIndex = pageIndexBeforeRotation;
    [UIView animateWithDuration:0.4 animations:^{
        assetInfoView.frame =CGRectMake(0, self.view.frame.size.height *1/2, 130, 120);
    }];
    [self performLayout];
	[self hideControlsAfterDelay];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
   
    _rotating = NO;
}

#pragma mark -
#pragma mark setUp ToolBar Methods
- (void)setupToolbar {
 
	UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonHit:)];
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	if ([self.playlist.storeAssets count] > 1) {
		
		UIBarButtonItem *fixedCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		fixedCenter.width = 80.0f;
		UIBarButtonItem *fixedLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		fixedLeft.width = 40.0f;
		
        
		
		UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] 
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self action:@selector(moveBack:)];
        
		UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right.png"] 
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(moveForward:)];
        if (!lockMode) {
            [self setToolbarItems:[NSArray arrayWithObjects:fixedLeft, flex, left, fixedCenter, right, flex, action, nil]];
        }else{
            [self setToolbarItems:[NSArray arrayWithObjects:fixedLeft, flex, left, fixedCenter, right, flex, nil]];
        }
		
		
		_rightButton = right;
		_leftButton = left;
		
		
	} else {
        if (!lockMode) {
            [self setToolbarItems:[NSArray arrayWithObjects:flex, action, nil]];
        }
		
	}
	
	_actionButton=action;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	
}

- (void)setupEditToolbar{
    [self setToolbarItems:nil];
    UIBarButtonItem *rotate = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"rotate.png"] 
                                                              style:UIBarButtonItemStylePlain 
                                                             target:self 
                                                             action:@selector(rotatePhoto)];
    
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *tag = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"tag.png"] 
                                                           style:UIBarButtonItemStylePlain 
                                                          target:self 
                                                          action:@selector(markPhoto)];
    
    UIBarButtonItem *crop = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"crop.png"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self 
                                                           action:@selector(cropPhoto)];
    [self setToolbarItems:[NSArray arrayWithObjects:rotate,flex,tag,flex,crop, nil]];
    
}

-(void)setCropConstrainToolBar{
    [self setToolbarItems:nil];
    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(edit)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = cancell;
    
    UIBarButtonItem *constrain = [[UIBarButtonItem alloc]initWithTitle:@"Constrain" style:UIBarButtonItemStyleBordered target:self action:@selector(cropConstrain)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    constrain.width = 100;
    [self setToolbarItems:[NSArray arrayWithObjects:flex,constrain,flex, nil]];
}

-(void)setTagToolBar{
    [self setToolbarItems:nil];
    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(edit)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = cancell;
    
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(callContactsView)];
    UIBarButtonItem *favorites = [[UIBarButtonItem alloc]initWithTitle:@"Favourites" style:UIBarButtonItemStyleBordered target:self action:@selector(callFavouriteView)];
    UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Events" style:UIBarButtonItemStyleBordered target:self action:@selector(callEventsView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:flex,contacts,flex,favorites,flex,events,flex, nil]];
     
}

#pragma mark -
#pragma mark EditMethods
-(void)edit
{
    self.navigationItem.rightBarButtonItem = saveItem;
    saveItem.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
    self.navigationItem.leftBarButtonItem = cancell;
    [self setupEditToolbar];
    editing = YES;
    if (!self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = YES;
    }
    if (cropView.superview !=nil) {
        [cropView removeFromSuperview];
    }
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView != nil) {
        if (photoView.alpha!=1.0) {
            photoView.alpha = 1.0;
        }
    }

    if (ppv.isOpen) {
        [ppv viewClose];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPhotoInfoView) object:nil];
    assetInfoView.hidden = YES;
}

-(void)cancelEdit{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = edit;
    [self setupToolbar];
    self.navigationItem.hidesBackButton = NO;
    editing = NO;
    if (cropView.superview!=nil) {
        [cropView removeFromSuperview];
    } 
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView != nil) {
        if (photoView.alpha!=1.0) {
            photoView.alpha = 1.0;
        }
    }
    if (!self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = YES;
    }
    if (assetInfoView.hidden) {
        assetInfoView.hidden = NO;
    }
}


-(void)cropConstrain{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil 
                                                      delegate:self 
                                             cancelButtonTitle:@"Cancel" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"Original",@"Square",@"3 x 2",@"4 x 3",@"4 x 6",@"5 x 7",@"8 x 10",@"16 x 9", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

-(void)rotatePhoto{
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem *cropItem=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveCropPhoto:)];
        self.navigationItem.rightBarButtonItem = cropItem;
    }
    
    if (!self.navigationItem.rightBarButtonItem.enabled) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    self.navigationItem.rightBarButtonItem.title = @"Save";
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView != nil) {
        
        [photoView rotatePhoto];
        [self.cropView setCropView];
    }
}

-(void)callContactsView{
    [tagSelector selectTagNameFromContacts];
}

-(void)callFavouriteView{
    [tagSelector selectTagNameFromFavorites];
}

-(void)callEventsView{
    
}

- (void)markPhoto{
    [self setTagToolBar];
    if (ppv) {
        ppv = nil;
    }
    Asset *asset=[self.playlist.storeAssets objectAtIndex:currentPageIndex];
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat ppvHeigh = CGRectGetMinY(self.navigationController.toolbar.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    ppv = [[PopupPanelView alloc] initWithFrame:CGRectMake(0, originY, self.view.bounds.size.width, ppvHeigh) andAsset:asset];
    [ppv Buttons];
    [ppv viewClose];
    
    ppv.alpha = 0.4;
    [self.view addSubview:ppv];
    [ppv viewOpen];
   
    
}

-(void)addTagPeople{
    [tagSelector saveTagAsset:[self.playlist.storeAssets objectAtIndex:currentPageIndex]];
    [ppv Buttons];
}

-(void)cropPhoto{
    
    if (!self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = YES;
    }else{
        self.scrollView.scrollEnabled = NO;
    }
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView != nil) {
        if (cropView.superview!=nil) {
            self.navigationItem.rightBarButtonItem = nil;
            [cropView removeFromSuperview];
            photoView.alpha = 1.0;
            self.navigationItem.rightBarButtonItem = saveItem;
            saveItem.enabled = NO;
            croping = NO;
        }else{
            self.navigationItem.rightBarButtonItem = nil;
            UIBarButtonItem *cropItem=[[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleDone target:self action:@selector(setCropPhoto:)];
            self.navigationItem.rightBarButtonItem = cropItem;
            [self setCropConstrainToolBar];
            photoView.alpha = 0.4;
            CropView *temCV = [[CropView alloc]initWithFrame:CGRectMake(110, 190, 100, 100) ImageView:photoView superView:self.view];//CGRectMake(110, 190, 100, 100)
            temCV.backgroundColor = [UIColor clearColor];
            self.cropView = temCV;
            
            [self.view addSubview:cropView];
            croping = YES;
        }
    }
    
}

-(void)setCropPhoto:(id)sender{
    self.navigationItem.rightBarButtonItem = saveItem;
    if (!saveItem.enabled) {
        saveItem.enabled = YES;
    }
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView != nil ) {
        photoView.alpha =1.0;
        photoView.fullScreen= self.cropView.cropImage;
        photoView.imageView.image = self.cropView.cropImage;
    }
    [cropView removeFromSuperview];
}

-(void)savePhoto{
    if (!self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = YES;
    }
    saveItem.enabled = NO;
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (photoView == nil) {
        return;
    }else{
        [photoView savePhoto];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"The photo have save to PhotoAlbum!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

#pragma mark -
#pragma mark Bar Methods

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated{
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
	if (hidden&&_barsHidden) return;
    [self setStatusBarHidden:hidden animated:animated];
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
    [self.navigationController setToolbarHidden:hidden animated:animated];
    [self setPhotoInfoHidden:hidden];
    [self setLikeButtonHidden:hidden];
	_barsHidden=hidden;
	
}

-(void)setPhotoInfoHidden:(BOOL)hidden{
    if (hidden && assetInfoView.superview != nil && assetInfoView != nil) {
        [UIView animateWithDuration:0.4 animations:^{
            assetInfoView.alpha = 0;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            assetInfoView.alpha = 1;
        }];
    }

}

-(void)setLikeButtonHidden:(BOOL)hidden{
    if (hidden && likeButton.superview != nil && likeButton != nil) {
        [UIView animateWithDuration:0.4 animations:^{
            likeButton.hidden = YES;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            likeButton.hidden = NO;
        }];
    }

}

- (void)toggleBarsNotification:(NSNotification*)notification{
	[self setBarsHidden:!_barsHidden animated:YES];
}

#pragma mark -
#pragma mark Photo View Methods


- (NSInteger)centerPhotoIndex{
	
	CGFloat pageWidth = self.scrollView.frame.size.width;
	return floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
}

- (void)moveForward:(id)sender{
    
    [self jumpToPageAtIndex:currentPageIndex+1];

}

- (void)moveBack:(id)sender{
    
    [self jumpToPageAtIndex:currentPageIndex-1];
}

- (void)updateNavigation {	
	
	if (_leftButton) {
        
		_leftButton.enabled = (currentPageIndex > 0);
	}
	
	if (_rightButton) {
		_rightButton.enabled = (currentPageIndex < [self.playlist.storeAssets count]-1);
	}
	
	if (_actionButton) {
        
        _actionButton.enabled = YES;
	}
	
	if ([self.playlist.storeAssets count] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex+1, [self.playlist.storeAssets count]];
	} else {
		self.title = @"";
	}
	
	
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (performingLayout || _rotating) return;
    if (theMovie != nil && theMovie.view.superview != nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
        [theMovie.view removeFromSuperview];
        theMovie = nil;
    }
    [self updatePages];
    // Calculate current page
    CGRect visibleBounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));    if (index < 0) index = 0;
	if (index > self.playlist.storeAssets.count - 1) index = self.playlist.storeAssets.count - 1;
    if (index != currentPageIndex) {
        currentPageIndex = index;
    }
	
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setBarsHidden:YES animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self updateNavigation];
}


#pragma mark -
#pragma mark Actions

- (void)copyPhoto{
	
	[[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image) forPasteboardType:@"public.png"];
	
}

- (void)emailPhoto{
	/*MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc]init];
     messageController.messageComposeDelegate = self;
     messageController.recipients = [NSArray arrayWithObject:@"23234567"];  
     messageController.body = @"iPhone OS4";
     [self presentModalViewController:messageController animated:YES];
     [messageController release];*/
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"Shared Photo"];
	[mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
	mailViewController.mailComposeDelegate = self;
	
	[self presentModalViewController:mailViewController animated:YES];
	
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result) {
		case MFMailComposeResultSent: ; break;
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	
}


#pragma mark -
#pragma mark UIActionSheet Methods

- (IBAction)actionButtonHit:(id)sender{
	
	UIActionSheet *actionSheet;
	NSString *a=NSLocalizedString(@"Cancel", @"title");
    NSString *b=NSLocalizedString(@"Mark", @"title");
    NSString *c=NSLocalizedString(@"Copy", @"title");
    NSString *d=NSLocalizedString(@"Email", @"title");
	if ([MFMailComposeViewController canSendMail]) {		
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:a destructiveButtonTitle:nil otherButtonTitles:b,c, d, nil];
		
	} else {
		
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:b, c, nil];
		
	}
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	
	[actionSheet showInView:self.view];
	[self setBarsHidden:YES animated:YES];
	
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	[self setBarsHidden:NO animated:YES];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} 
    if (editing) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            NSLog(@"first");
            [self.cropView setFrame:CGRectMake(110, 190, 100, 100)];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            CGRect rect = self.cropView.frame;
            CGPoint center = self.cropView.center;
            rect.size.width *= 2;
            rect.size.height *= 2;
            self.cropView.frame = CGRectMake(center.x-rect.size.width/2, center.y-rect.size.height/2, rect.size.width, rect.size.height);	
            [self.cropView setCropView];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
           // CGFloat maxSize = MAX(self.cropView.frame.size.width, self.cropView.frame.size.height);
            
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 3){
            
        }else if (buttonIndex == actionSheet.firstOtherButtonIndex + 4){

        }else if (buttonIndex == actionSheet.firstOtherButtonIndex + 5){

        }else if (buttonIndex == actionSheet.firstOtherButtonIndex + 6){

        }else if (buttonIndex == actionSheet.firstOtherButtonIndex + 7){

        }else if (buttonIndex == actionSheet.firstOtherButtonIndex + 8){

        }
        
    }else{
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self markPhoto];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            [self copyPhoto];	
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
            [self emailPhoto];	
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 3){
            [self cropPhoto];
        }
    }
}

#pragma mark -
#pragma mark timer method

-(void)fireTimer:(NSString *)animateStyle{
    timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playPhoto) userInfo:animateStyle repeats:YES];
}
-(void)playPhoto{
    currentPageIndex+=1;
    NSInteger _index = self.currentPageIndex;
    if (_index >= [self.playlist.storeAssets count] || _index < 0) {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }

    [self setBarsHidden:YES animated:YES];
    NSString *animateStyle = [timer userInfo];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.subtype = kCATransitionFromRight;
    if ([animateStyle isEqualToString:@"Fade"]) {
        animation.type = kCATransitionFade;
    }
    else if([animateStyle isEqualToString:@"Reveal"]) {
        animation.type = kCATransitionReveal;
    }
    else if([animateStyle isEqualToString:@"Push"]) {
        animation.type = kCATransitionPush;
    }
    else if([animateStyle isEqualToString:@"MoveIn"]) {
        animation.type = kCATransitionMoveIn;
    }
    else{
        animation.type = animateStyle;
    }
    [self.scrollView.layer addAnimation:animation forKey:@"animation"];
    [self jumpToPageAtIndex:currentPageIndex];
   }

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
	timer = nil;
	_scrollView=nil;
	
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end