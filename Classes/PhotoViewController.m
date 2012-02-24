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
#import "Playlist.h"
#import "Asset.h"
#import "TagSelector.h"
#import "PhotoAppDelegate.h"
#import "AssetTablePicker.h"

@interface PhotoViewController (Private)

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)setPhotoInfoHidden:(BOOL)hidden;
-(void)setLikeButtonHidden:(BOOL)hidden;
- (void)setupToolbar;
- (void)setupEditToolbar;
-(void)setNavigationBarItem;
- (void)updateNavigation;
-(void)updateToolBar;
- (void)updateSubviewsWhenScroll;
@end

@implementation PhotoViewController


@synthesize ppv;
@synthesize scrollView=_scrollView;
@synthesize currentPageIndex;
@synthesize playlist;
@synthesize lockMode;
@synthesize assetTablePicker;
@synthesize playPhotoTransition;
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
        playingFromSelfPage = NO;
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
        playingFromSelfPage = NO;
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
        if (page.scrollView.zoomScale>1.0) {
            [page killScrollViewZoom];
        }
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
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if ([[as valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        CGRect frame1 =buttonFram;
        frame1.origin.x = buttonFram.size.width/2 - 30;
        frame1.origin.y = buttonFram.size.height/2 - 20;
        frame1.size.height=60;
        frame1.size.width=60;
        for (UIView *view in photoView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view setFrame:frame1];
            }
        }

       // playButton.frame = frame1;
        if (theMovie != nil && theMovie.view.superview != nil) {
            //CGRect videoFrame = [photoView.scrollView convertRect:photoView.imageView.frame toView:self.view];
            theMovie.view.frame = photoView.imageView.frame;
            //[[theMovie view] setFrame:photoView.imageView.frame];//CGRectMake(0, 0, photoView.imageView.frame.size.width, photoView.imageView.frame.size.height)];
        }
    }
    if (assetInfoView != nil && assetInfoView.superview != nil) {
        
        assetInfoView.frame =CGRectMake(photoView.frame.origin.x, photoView.frame.size.height *1/2, 130, 120);
    }
    if (ppv.isOpen) {
        ppv.frame = [self frameForTagOverlay];
    }
	performingLayout = NO;
    
}


#pragma mark -
#pragma mark View Controller Methods

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self performLayout];
	[self setupToolbar];
    [self updateNavigation];
}

-(void)viewDidAppear:(BOOL)animated{

}
- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    [theMovie stop];
    [self cancelPlayPhotoTimer];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack. 
        tagSelector = nil;
        [self cancelControlHiding];
        [[NSNotificationCenter defaultCenter] removeObserver:tagSelector];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadTableData" object:nil];
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
    tagShow = NO;
    editing=NO;
    playingVideo = NO;
    
    [self setNavigationBarItem];
    
    if (lockMode) {
        PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
        [self performSelector:@selector(showLikeButton:) withObject:page afterDelay:1.0];
    }
    [self updatePages];
    [self hideControlsAfterDelay];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetCropView) name:@"resetCropView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateToolBar) name:@"changeLockModeInDetailView" object:nil];
    
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
    for (UIView *view in page.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    CGRect rect = [self frameForPageAtIndex:index];
    page.index = index;
    page.imageView.image = nil;
    page.frame = rect;
    if (!playingPhoto) {
        [page loadIndex:index];
    }else{
        [page setClearImage];
    }
    Asset *asset = [self.playlist.storeAssets objectAtIndex:index];
    NSString *strUrl = asset.url;
    ALAsset *as = [self.playlist.assets objectForKey:strUrl];
    if ([[as valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        CGRect frame1 =rect;
        frame1.origin.x = rect.size.width/2 - 30;
        frame1.origin.y = rect.size.height/2 - 20;
        frame1.size.height=60;
        frame1.size.width=60;
        if (playingPhoto) {
            [self performSelector:@selector(playVideo) withObject:nil afterDelay:1];
            [self cancelPlayPhotoTimer];
        }else{
            [page addSubview:[self configurePlayButton:frame1]];
            
        }
    }
    //NSLog(@"self.scrollview.bounds is %@",NSStringFromCGRect(self.scrollView.bounds));
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
    //NSLog(@"view bounds is %@",NSStringFromCGRect(self.view.bounds));
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
-(void)showPhotoInfo:(PhotoImageView *)page{
    
    if (assetInfoView || assetInfoView.superview != nil) {
        [assetInfoView removeFromSuperview];
        assetInfoView = nil;
    }
    [self performSelector:@selector(addPhotoInfoView:) withObject:page];
    if (lockMode) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLikeButton:) object:page];
        [self performSelector:@selector(showLikeButton:) withObject:page];
    }
    
}

-(void)addPhotoInfoView:(PhotoImageView *)page{
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    assetInfoView = [[UIView alloc]initWithFrame:CGRectMake(page.frame.origin.x, page.frame.size.height * 1/2 , 130, 120)];
    assetInfoView.userInteractionEnabled = NO;
    [assetInfoView.layer setCornerRadius:10.0];
    [assetInfoView setClipsToBounds:YES];
    if (!lockMode) {
        UILabel *likeCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 25)];
        likeCount.backgroundColor = [UIColor clearColor];
        likeCount.text = [NSString stringWithFormat:@"LIKE COUNT:%@",[asset.numOfLike description]];
        likeCount.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        likeCount.font = [UIFont boldSystemFontOfSize:14];
        
        tagCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, 120, 25)];
        tagCount.backgroundColor = [UIColor clearColor];
        tagCount.text = [NSString stringWithFormat:@"TAG COUNT:%@",[asset.numPeopleTag description]];
        tagCount.textColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:24/255.0 alpha:1.0];
        tagCount.font = [UIFont boldSystemFontOfSize:14];
        [assetInfoView addSubview:likeCount];
        [assetInfoView addSubview:tagCount];
    }
    UILabel *date = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 160, 25)];
    
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
    [assetInfoView addSubview:date];
    [self.scrollView addSubview:assetInfoView];
}
-(void)numtag
{   Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    tagCount.text = [NSString stringWithFormat:@"TAG COUNT:%@",[asset.numPeopleTag description]];
}
-(void)showLikeButton:(PhotoImageView *)page{
    if (likeButton || likeButton.superview != nil) {
        [likeButton removeFromSuperview];
        likeButton = nil;
    }
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    likeButton.layer.cornerRadius = 10.0;
    likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect mainScreen = page.frame;
    likeButton.frame = CGRectMake(mainScreen.size.width*4/5, mainScreen.size.height*3/4, 50, 50);
    
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    if ([self.assetTablePicker.likeAssets containsObject:asset]) {
        [likeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    }else{
        [likeButton setImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
    }
    
    [likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [page addSubview:likeButton];
}

-(void)likeButtonPressed:(id)sender
{
    UIButton *like = (UIButton *)sender;
     Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    if ([like.imageView.image isEqual:[UIImage imageNamed:@"unlike.png"]]) {
        [likeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [self.assetTablePicker.likeAssets addObject:asset];
        asset.numOfLike = [NSNumber numberWithInt:[asset.numOfLike intValue]+1];
    }else{
        [like setImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
        [self.assetTablePicker.likeAssets removeObject:asset];
        asset.numOfLike = [NSNumber numberWithInt:[asset.numOfLike intValue]-1];
    }
    PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.dataSource.coreData saveContext];
}

#pragma mark -
#pragma mark PlayVideo Methods

-(UIButton *)configurePlayButton:(CGRect)framek
{
//    if (playButton && playButton.superview != nil) {
//        [playButton removeFromSuperview];
//        playButton = nil;
//    }
    UIButton *playButtons = [UIButton buttonWithType:UIButtonTypeCustom];
    //playButton = playButtons;
    [playButtons addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *picture = [UIImage imageNamed:@"ji.png"];
    // set the image for the button
    [playButtons setBackgroundImage:picture forState:UIControlStateNormal];
    [playButtons setBackgroundColor:[UIColor clearColor]];
    playButtons.frame =framek;
    //[self.scrollView addSubview:playButton];
    return playButtons;
}


-(void)playVideo:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self cancelControlHiding];
    [self setBarsHidden:YES animated:YES];
    button.hidden = YES;
    playButton = button;
    [self playVideo];
}

-(void)playVideo{
    PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
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
    page.playingVideo = YES;
    page.moviePlayer = theMovie;
    page.imageView.hidden = YES;
//    CGRect videoFrame = CGRectMake(0, 0, _imageView.imageView.frame.size.width, _imageView.imageView.frame.size.height);
//    [[theMovie view] setFrame:videoFrame]; // Frame must match parent view
//    [_imageView.imageView addSubview:[theMovie view]];

    theMovie.view.frame = page.imageView.frame;
    [page.scrollView addSubview:theMovie.view];
    theMovie.scalingMode = MPMovieMediaTypeMaskVideo;//MPMovieScalingModeAspectFit;
    theMovie.controlStyle = MPMovieControlStyleEmbedded;
   // [theMovie setFullscreen:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(myMovieFinishedCallback:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:theMovie]; 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(myMovieDidExitFullscreen:) 
                                                 name:MPMoviePlayerDidExitFullscreenNotification 
                                               object:nil]; 
    // Movie playback is asynchronous, so this method returns immediately. 
    [theMovie play];  
    playingVideo = YES;

}
- (void)myMovieDidExitFullscreen:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification 
                                                  object:nil];
    
    [theMovie.view removeFromSuperview];
    theMovie = nil;
    if (playingPhoto) {
        [self fireTimer];
    }
    PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
    page.playingVideo = NO;
    page.scrollView.zoomScale = 1.0;
    page.imageView.hidden = NO;
    playingVideo = NO;
    playButton.hidden = NO;
}
// When the movie is finish,release the controller. 
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
        [self fireTimer];
    }
    PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
    page.playingVideo = NO;
    page.scrollView.zoomScale = 1.0;
    page.imageView.hidden = NO;
    playingVideo = NO;
}

#pragma mark - 
#pragma mark Rotate orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _rotating = YES;
    pageIndexBeforeRotation = currentPageIndex;
    if (_barsHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    currentPageIndex = pageIndexBeforeRotation;
    [self performLayout];
    if (_barsHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
	//[self hideControlsAfterDelay];
   // NSLog(@"scroll frame is %@ and bounds %@  and contentsize %@",NSStringFromCGRect(self.scrollView.frame),NSStringFromCGRect(self.scrollView.bounds),NSStringFromCGSize(self.scrollView.contentSize));
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
    if (theMovie != nil && theMovie.view.superview != nil) {
        [UIView animateWithDuration:0.2 animations:^{
            theMovie.view.frame = photoView.imageView.frame;
        }];
    }
   //[self performLayout];
    _rotating = NO;
}

#pragma mark -
#pragma mark setUp ToolBar Methods
-(void)setNavigationBarItem{
    NSString *tagStr=NSLocalizedString(@"Tag", @"title");
    // NSString *u=NSLocalizedString(@"Edit", @"title");
    NSString *cancelStr = NSLocalizedString(@"Done", @"title");
    if (!lockMode) {
        if (!tag) {
            tag=[[UIBarButtonItem alloc]initWithTitle:tagStr style:UIBarButtonItemStyleBordered target:self action:@selector(markPhoto)];
            cancel=[[UIBarButtonItem alloc]initWithTitle:cancelStr style:UIBarButtonItemStyleDone target:self action:@selector(cancelEdit)];
        }
        self.navigationItem.rightBarButtonItem=tag;
    }else
        self.navigationItem.rightBarButtonItem = nil;

}
- (void)setupToolbar {
    [self setToolbarItems:nil];
	UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonHit:)];
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *playPhoto = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPhotoFromSelfPage:)];
    UIBarButtonItem *lock = nil;
    if (self.assetTablePicker.album != nil) {
        if (lockMode)
            lock = [[UIBarButtonItem alloc]initWithTitle:@"UnLock" style:UIBarButtonItemStylePlain target:self action:@selector(lockButtonPressed:)];
        else
            lock = [[UIBarButtonItem alloc]initWithTitle:@"Lock" style:UIBarButtonItemStylePlain target:self action:@selector(lockButtonPressed:)];
    }
    
    //UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPhotoOrVideo)];
    if (!lockMode) {
        [self setToolbarItems:[NSArray arrayWithObjects:action,flex, playPhoto, flex, lock,nil]];
    }else{
        [self setToolbarItems:[NSArray arrayWithObjects:flex, lock, nil]];
    }
    playPhotoButton = playPhoto;
	_actionButton = action;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	
}

-(void)setTagToolBar{
    [self setToolbarItems:nil];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = cancel;
     NSString *a=NSLocalizedString(@"Contacts", @"title");
     NSString *b=NSLocalizedString(@"Favourites", @"title");
    // NSString *c=NSLocalizedString(@"Events", @"title");
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleBordered target:self action:@selector(callContactsView)];
    UIBarButtonItem *favorites = [[UIBarButtonItem alloc]initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(callFavouriteView)];
   // UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:c style:UIBarButtonItemStyleBordered target:self action:@selector(callEventsView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:contacts,flex,favorites, nil]];
}

-(void)lockButtonPressed:(id)sender{
    if (assetInfoView != nil && assetInfoView.superview != nil) {
        [assetInfoView removeFromSuperview];
        assetInfoView = nil;
    }
    if (likeButton != nil && likeButton.superview != nil) {
        [likeButton removeFromSuperview];
        likeButton = nil;
    }
    [self.assetTablePicker lockButtonPressed];
    if (!lockMode) {
        [self updateToolBar];
    }
   
}

-(void)updateToolBar{
    if (self.assetTablePicker.lockMode) {
        lockMode = YES;
    }else{
        lockMode = NO;
    }
    [self setupToolbar];
    [self setNavigationBarItem];
}
#pragma mark -
#pragma mark EditMethods
//-(void)edit
//{
//    self.navigationItem.rightBarButtonItem = saveItem;
//    saveItem.enabled = NO;
//    self.navigationItem.hidesBackButton = YES;
//    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit)];
//    self.navigationItem.leftBarButtonItem = cancell;
//    [self setupEditToolbar];
//    editing = YES;
//    if (self.scrollView.scrollEnabled) {
//        self.scrollView.scrollEnabled = NO;
//    }
//    if (cropView.superview !=nil) {
//        [cropView removeFromSuperview];
//    }
//    PhotoImageView *photoView = [self pageDisplayedAtIndex:currentPageIndex];
//    if (photoView != nil) {
//        if (photoView.alpha!=1.0) {
//            photoView.alpha = 1.0;
//        }
//    }
//
//    if (ppv.isOpen) {
//        [ppv viewClose];
//    }
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPhotoInfoView) object:nil];
//    assetInfoView.hidden = YES;
//}

-(void)cancelEdit{
    [self setupToolbar];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = tag;
    self.navigationItem.hidesBackButton = NO;
    editing = NO;
    if (!self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = YES;
    }
    if (assetInfoView.hidden) {
        assetInfoView.hidden = NO;
    }
    if ([ppv isOpen]) {
        [ppv viewClose];
    }
    [self hideControlsAfterDelay];
}
-(void)callContactsView{
    tagSelector.add=@"YES";
    [tagSelector selectTagNameFromContacts];
}

-(void)callFavouriteView{
    tagSelector.add=@"YES";
    [tagSelector selectTagNameFromFavorites];
}
                                  
- (void)markPhoto{
    editing = YES;
    [self setTagToolBar];
    if (ppv) {
        ppv = nil;
    }
    Asset *asset=[self.playlist.storeAssets objectAtIndex:currentPageIndex];
    ppv = [[PopupPanelView alloc] initWithFrame:[self frameForTagOverlay] andAsset:asset];
    [ppv Buttons];
    [ppv viewClose];
    
    ppv.alpha = 0.4;
    [self.view addSubview:ppv];
    [ppv viewOpen];
    [self cancelControlHiding];
   
    
}

-(CGRect)frameForTagOverlay{
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat ppvHeigh = CGRectGetMinY(self.navigationController.toolbar.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGRect rect = CGRectMake(0, originY, self.view.bounds.size.width, ppvHeigh);
    return rect;
}

-(void)addTagPeople{
    
    [tagSelector saveTagAsset:[self.playlist.storeAssets objectAtIndex:currentPageIndex]];
    [ppv Buttons];
}


#pragma mark -
#pragma mark Bar Methods
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
	if (hidden&&_barsHidden) return;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    if (hidden) {
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 0;
            self.navigationController.toolbar.alpha = 0;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 1;
            self.navigationController.toolbar.alpha = 1;
        }];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect frame = self.navigationController.navigationBar.frame;
        frame.origin.y = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
        self.navigationController.navigationBar.frame = frame;
    }
    [self setPhotoInfoHidden:hidden];
    [self setLikeButtonHidden:hidden];
    if (!playingPhoto && !playingVideo &&!hidden && assetInfoView == nil && assetInfoView.superview == nil) {
        PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
        [self showPhotoInfo:page];
    }
    [self cancelControlHiding];
    if (!hidden) {
        [self hideControlsAfterDelay];
    }
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
   
    if (!playingVideo) {
        [self setBarsHidden:!_barsHidden animated:YES];
        [self cancelPlayPhotoTimer];
    }
	
}

#pragma mark -
#pragma mark Photo View Methods                                  
- (void)updateNavigation {	
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
    //NSLog(@"scroll frame is %@ and bounds %@  and contentsize %@",NSStringFromCGRect(self.scrollView.frame),NSStringFromCGRect(self.scrollView.bounds),NSStringFromCGSize(self.scrollView.contentSize));
    [self updatePages];
    // Calculate current page
    CGRect visibleBounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));    if (index < 0) index = 0;
	if (index > self.playlist.storeAssets.count - 1) index = self.playlist.storeAssets.count - 1;
    if (index != currentPageIndex) {
        [self updateSubviewsWhenScroll];
        currentPageIndex = index;
        if (lockMode) {
            PhotoImageView *page = [self pageDisplayedAtIndex:currentPageIndex];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLikeButton:) object:page];
            [self performSelector:@selector(showLikeButton:) withObject:page afterDelay:1.0];
        }

    }

}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setBarsHidden:YES animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self updateNavigation];
}

- (void)updateSubviewsWhenScroll{
    if (theMovie != nil && theMovie.view.superview != nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
        [theMovie.view removeFromSuperview];
        theMovie = nil;
    }
    if (assetInfoView != nil && assetInfoView.superview != nil) {
        [assetInfoView removeFromSuperview];
        assetInfoView = nil;
    }
    if (likeButton != nil && likeButton.superview != nil) {
        [likeButton removeFromSuperview];
        likeButton = nil;
    }
    if ([ppv isOpen]) {
        [ppv viewClose];
        [self cancelEdit];
    }
}
#pragma mark -
#pragma mark Actions

-(void)messagePhoto{
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc]init];
     messageController.messageComposeDelegate = self;
//     messageController.recipients = [NSArray arrayWithObject:@"23234567"];  
//     messageController.body = @"iPhone OS4";
    NSData *data = UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image);
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    messageController.body = string;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     [self presentModalViewController:messageController animated:YES];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
    NSString *mailError = nil;
    switch (result)
    {
        case MessageComposeResultCancelled:
                
            break;
        case MessageComposeResultSent:
            
            break;
        case MessageComposeResultFailed:mailError = @"Send messages failed,please try again...";
            
            break;
        default:
        
            break;
    }
    if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)emailPhoto{
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:@"Shared Photo"];
        [mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
        mailViewController.mailComposeDelegate = self;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self presentModalViewController:mailViewController animated:YES];
	
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
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

#pragma mark -
#pragma mark UIActionSheet Methods

- (IBAction)actionButtonHit:(id)sender{
	
	UIActionSheet *actionSheet;
    NSString *a=NSLocalizedString(@"Email", @"title");
    NSString *b=NSLocalizedString(@"Message", @"title");
   // NSString *d=NSLocalizedString(@"Copy", @"title");
    NSString *e=NSLocalizedString(@"Cancel", @"title");
	if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:a,b, nil];
		
	} 
    else if([MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) {		
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:a, nil];
		
	}else if(![MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:b, nil];
		
    }
    else {
		
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:nil];
		
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
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self emailPhoto];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            [self messagePhoto];	
        } 
    } 
    else if([MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) {		
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self emailPhoto];
        } 
    }else if(![MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self messagePhoto];
        }
    }
}

#pragma mark -
#pragma mark timer method
-(void)cancelPlayPhotoTimer{
    if (timer) {
		[timer invalidate];
		timer = nil;
	}
    playingPhoto = NO;
}

-(void)playPhotoFromSelfPage:(id)sender{
    NSLog(@"PLAYING");
    if (!playingPhoto) {
        playingFromSelfPage = YES;
    }
    [self fireTimer];
}
-(void)fireTimer{
    NSLog(@"fireTimer");
    [self cancelPlayPhotoTimer];
    playingPhoto = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playPhoto) userInfo:playPhotoTransition repeats:YES];
}
-(void)playPhoto{
    NSLog(@"play photo");
    if (!_barsHidden) {
        [self setBarsHidden:YES animated:YES];
    }
    currentPageIndex += 1;
    NSInteger _index = self.currentPageIndex;
    if (_index >= [self.playlist.storeAssets count] || _index < 0) {
        if (timer) {
            [timer invalidate];
            timer = nil;
            [self setBarsHidden:NO animated:YES];
            if (!playingFromSelfPage) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            return;
        }
    }
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
    //NSLog(@"the count is %d and the current is %d ",self.playlist.storeAssets.count,currentPageIndex);
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
@end