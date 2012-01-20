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
#import "CropView.h"
#import "Playlist.h"
#import "Asset.h"
#import "TagSelector.h"


@interface PhotoViewController (Private)

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (NSInteger)centerPhotoIndex;
- (void)setupToolbar;
-(void)setCropConstrainToolBar;
- (void)setupEditToolbar;
- (void)updateNavigation;
@end

@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (scale>1.0) {        
        rect = CGRectMake(rect.origin.x*scale , rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);        
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef]; 
    CGImageRelease(imageRef);
    return result;
}

@end

@implementation PhotoViewController


@synthesize ppv;
@synthesize scrollView=_scrollView;
@synthesize photoSource; 
@synthesize photoViews=_photoViews;
@synthesize currentPageIndex;
@synthesize video;
@synthesize cropView;
@synthesize playlist;

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
        [tempPlaylist release];
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
	
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.scrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
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
    
    [timer invalidate];
    [self.navigationController setToolbarHidden:YES animated:YES];		
}

- (void)viewDidLoad {
    [super viewDidLoad];
    VI=NO;
    [self CFG];
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

    NSMutableArray *array=[[NSMutableArray alloc]init];
    self.video=array;
    [array release];
    
    tagShow = NO;
    editing=NO;
    croping = NO;
    NSString *u=NSLocalizedString(@"Edit", @"title");
    NSString *save = NSLocalizedString(@"Save", @"title");
    edit=[[UIBarButtonItem alloc]initWithTitle:u style:UIBarButtonItemStyleBordered target:self action:@selector(edit)];
    saveItem=[[UIBarButtonItem alloc]initWithTitle:save style:UIBarButtonItemStyleDone target:self action:@selector(savePhoto)];

    self.navigationItem.rightBarButtonItem=edit;
    
    [self updatePages];
    
}


#pragma mark -
#pragma mark Pagging Methods

-(void)updatePages{
    // Calculate which pages are visible
    NSLog(@"scrollView bounds is %@",NSStringFromCGRect(self.scrollView.bounds));
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
                page = [[[PhotoImageView alloc] init] autorelease];
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
    Asset *asset = [self.playlist.storeAssets objectAtIndex:index];
    NSString *strUrl = asset.url;
    ALAsset *as = [self.playlist.assets objectForKey:strUrl];
    if ([[as valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        
        NSString *p=[NSString stringWithFormat:@"%d",page];
        [self.video addObject:p];
        CGRect frame1 =rect;
        frame1.origin.x =rect.origin.x + 130;
        frame1.origin.y = 210;
        frame1.size.height=60;
        frame1.size.width=60;
        [self play:frame1];
    }
    NSLog(@"configure page is %d",index);
    page.index = index;
    page.imageView.image = nil;
    page.frame = rect;
    [page loadIndex:index];
    [self showPhotoInfo];

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
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

#pragma mark -
#pragma mark Frame Methods
- (CGRect)frameForPagingScrollView{
    NSLog(@"view bounds is %@",self.view.bounds);
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
    NSLog(@"%@ is scrollView BOUNDS",NSStringFromCGSize(bounds.size));
    return CGSizeMake(bounds.size.width * self.playlist.storeAssets.count, bounds.size.height);
}


- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = self.scrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
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
		[controlVisibilityTimer release];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
}

- (void)hideControls { [self setBarsHidden:!_barsHidden animated:YES]; }

-(void)showPhotoInfo{
    if (photoInfoTimer) {
        [photoInfoTimer invalidate];
        [photoInfoTimer release];
        photoInfoTimer = nil;
    }
    if (assetInfoView && assetInfoView.superview != nil) {
        [assetInfoView removeFromSuperview];
        [assetInfoView release];
        assetInfoView = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPhotoInfoView) object:nil];
    [self performSelector:@selector(addPhotoInfoView) withObject:nil afterDelay:2];
}

-(void)addPhotoInfoView{
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    
    assetInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.toolbar.frame.origin.y -180, 150, 120)];
    UILabel *date = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 75, 30)];
    UILabel *likeCount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 75, 30)];
    UILabel *tagCount = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 75, 30)];
    date.backgroundColor = [UIColor clearColor];
    likeCount.backgroundColor = [UIColor clearColor];
    tagCount.backgroundColor = [UIColor clearColor];
    date.text = [asset.date description];
    likeCount.text = [asset.numOfLike description];
    tagCount.text = [asset.numPeopleTag description];
    [assetInfoView setBackgroundColor:[UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0]];
    assetInfoView.alpha = 0.4;
    [assetInfoView addSubview:date];
    [assetInfoView addSubview:likeCount];
    [assetInfoView addSubview:tagCount];
    [self.view addSubview:assetInfoView];
    [date release];
    [likeCount release];
    [tagCount release];
}

#pragma mark -
#pragma mark PlayVideo Methods

-(void)play:(CGRect)framek
{
    playButton = nil;
    [playButton release];
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    UIImage *picture = [UIImage imageNamed:@"ji.png"];
    // set the image for the button
    [playButton setBackgroundImage:picture forState:UIControlStateNormal];
    [playButton setBackgroundColor:[UIColor clearColor]];
    playButton.frame =framek;
    [self.scrollView addSubview:playButton];
    
    
    
}
-(void)CFG
{
    favorite=[[UIView alloc]initWithFrame:CGRectMake(1,160,80,150)];
    [favorite setBackgroundColor:[UIColor grayColor]];
    favorite.alpha=0.6;
    
    
    UILabel *note=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, 80, 30)];
    [note setBackgroundColor:[UIColor clearColor]];
    note.numberOfLines = 10;  
    note.text = @"Do you like it?";
    
    //note.baselineAdjustment = UIBaselineAdjustmentNone; 
    //note.highlighted = YES;       
    
    //note.highlightedTextColor = [UIColor whiteColor];      
    note.textColor = [UIColor whiteColor];
    note.font = [UIFont boldSystemFontOfSize:18];
    //[note setText:@"do you like it?"];
    CGSize size = CGSizeMake(60, 1000);
    CGSize labelSize = [note.text sizeWithFont:note.font 
                             constrainedToSize:size
                                 lineBreakMode:UILineBreakModeClip];
    note.frame = CGRectMake(note.frame.origin.x, note.frame.origin.y,
                            note.frame.size.width,labelSize.height);
    [favorite addSubview:note];
    [note release];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom]; 
    button1.frame = CGRectMake(10, 80, 60, 30);
    [button1 setBackgroundColor:[UIColor clearColor]]; 
    [button1 setTitle:@"YES" forState:UIControlStateNormal];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom]; 
    button2.frame = CGRectMake(10, 115, 60, 30);
    [button2 setBackgroundColor:[UIColor clearColor]]; 
    [button2 setTitle:@"NO" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1Pressed) forControlEvents:UIControlEventTouchDown];
    [button2 addTarget:self action:@selector(button2Pressed) forControlEvents:UIControlEventTouchDown];
    [favorite addSubview:button1];
    [favorite addSubview:button2];
    //favorite.hidden=YES;
    
    
}
-(void)favorite:(NSString *)inter
{  
    if([inter integerValue]==currentPageIndex)
    {
        //favorite.hidden=NO;
        [self.view addSubview:favorite];
        // 
        
        
        [UIView animateWithDuration:0.5 
                         animations:^{
                             //myPickerView.frame = CGRectMake(0, 210, 310, 180);
                             favorite.alpha = 0.6;
                         }];
        
        
        //favorite.hidden=NO;
        
    }
    //  [favorite CommitAnimations];
}
-(void)likeButtonPressed
{
    NSLog(@"button1");
    // favorite.hidden=YES;
    [UIView animateWithDuration:0.8 
                     animations:^{
                         //myPickerView.frame = CGRectMake(0, 210, 310, 180);
                         favorite.alpha = 0;
                     }];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addfavorate" 
                                                       object:self 
                                                     userInfo:dic];
}
-(void)button2Pressed
{
    
    [UIView animateWithDuration:0.8 
                     animations:^{
                         favorite.alpha = 0;
                     }];
    
}



-(void)playVideo
{
    Asset *asset = [self.playlist.storeAssets objectAtIndex:currentPageIndex];
    NSString *strUrl = asset.url;
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    
    theMovie=[[MPMoviePlayerController alloc] initWithContentURL:url]; 
    //  NSTimeInterval duration = theMovie.duration;
    //  NSLog(@"LENGTH:%f",theMovie.duration);
    PhotoImageView *_imageView = [self pageDisplayedAtIndex:currentPageIndex];
    CGRect videoFrame = [_imageView convertRect:_imageView.imageView.frame toView:self.view];
    [[theMovie view] setFrame:videoFrame]; // Frame must match parent view
    [self.view addSubview:[theMovie view]];
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
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//   
//    [self setBarsHidden:!_barsHidden animated:YES];
//    
//    
//    
//}
// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification 
{
    MPMoviePlayerController* theMovie2=[aNotification object]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:theMovie2]; 
    // Release the movie instance created in playMovieAtURL
    //[theMovie2 release]; 
}

#pragma mark - 
#pragma mark Rotate orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _rotating = YES;

//    for (PhotoImageView *view in visiblePages){
//        if ([view isKindOfClass:[PhotoImageView class]]) {
//            if (view.index != currentPageIndex) {
//                [view setHidden:YES];
//            }
//        }
//    }

    NSLog(@"will rotate%d",currentPageIndex);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
   // currentPageIndex = pageIndexBeforeRotation;
	//[self performLayout];
	// Adjust frames and configuration of each visible page
	for (PhotoImageView *page in visiblePages) {
        [page rotateToOrientation:toInterfaceOrientation];
	}
    
	[self hideControlsAfterDelay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    self.scrollView.frame = [self frameForPagingScrollView];
    [self contentSizeForPagingScrollView];
    [self contentOffsetForPageAtIndex:currentPageIndex];
    [self updatePages];
    NSLog(@"current page is %d",currentPageIndex);
   // [self.scrollView scrollRectToVisible:((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).frame animated:YES];
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
		
		[self setToolbarItems:[NSArray arrayWithObjects:fixedLeft, flex, left, fixedCenter, right, flex, action, nil]];
		
		_rightButton = right;
		_leftButton = left;
		
		[fixedCenter release];
		[fixedLeft release];
		[right release];
		[left release];
		
	} else {
		[self setToolbarItems:[NSArray arrayWithObjects:flex, action, nil]];
	}
	
	_actionButton=action;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	[action release];
	[flex release];
	
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
    
    [rotate release];
    [flex release];
    [crop release];
    [tag release];
}

-(void)setCropConstrainToolBar{
    [self setToolbarItems:nil];
    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(edit)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = cancell;
    [cancell release];
    
    UIBarButtonItem *constrain = [[UIBarButtonItem alloc]initWithTitle:@"Constrain" style:UIBarButtonItemStyleBordered target:self action:@selector(cropConstrain)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    constrain.width = 100;
    [self setToolbarItems:[NSArray arrayWithObjects:flex,constrain,flex, nil]];
    [constrain release];
    [flex release];
}

-(void)setTagToolBar{
    [self setToolbarItems:nil];
    UIBarButtonItem *cancell = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(edit)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = cancell;
    [cancell release];
    
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(callContactsView)];
    UIBarButtonItem *favorites = [[UIBarButtonItem alloc]initWithTitle:@"Favourites" style:UIBarButtonItemStyleBordered target:self action:@selector(callFavouriteView)];
    UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Events" style:UIBarButtonItemStyleBordered target:self action:@selector(callEventsView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:flex,contacts,flex,favorites,flex,events,flex, nil]];
     
    [contacts release];
    [favorites release];
    [events release];
    [flex release];
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
    [cancell release];
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
}


-(void)cropConstrain{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil 
                                                      delegate:self 
                                             cancelButtonTitle:@"Cancel" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"Original",@"Square",@"3 x 2",@"4 x 3",@"4 x 6",@"5 x 7",@"8 x 10",@"16 x 9", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
    [sheet release];
}

-(void)rotatePhoto{
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem *cropItem=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveCropPhoto:)];
        self.navigationItem.rightBarButtonItem = cropItem;
        [cropItem release];
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
        [ppv release];
    }
    ppv = [[PopupPanelView alloc] initWithFrame:CGRectMake(0, 62, 320, 375)];
    [ppv Buttons];
    [ppv viewClose];
    NSString *currentPageUrl=((Asset *)[self.playlist.storeAssets objectAtIndex:currentPageIndex]).url;
    ppv.url = currentPageUrl;
    ppv.alpha = 0.4;
    [self.view addSubview:ppv];
    [ppv viewOpen];
   
    
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
            [cropItem release];
            [self setCropConstrainToolBar];
            photoView.alpha = 0.4;
            CGRect cropRect = [photoView.scrollView convertRect:photoView.imageView.frame toView:self.view];
//            cropRect.origin.x +=20;
//            cropRect.origin.y +=20;
//            cropRect.size.width -=40;
//            cropRect.size.height -=40;
            NSLog(@"crop rect %@",NSStringFromCGRect(cropRect));
            CropView *temCV = [[CropView alloc]initWithFrame:CGRectMake(110, 190, 100, 100) ImageView:photoView superView:self.view];//CGRectMake(110, 190, 100, 100)
            temCV.backgroundColor = [UIColor clearColor];
            self.cropView = temCV;
            [temCV release];
            
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
        //[photoView setPhoto:self.cropView.cropImage];
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
        [alert release];
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
    if (hidden) {
        [UIView animateWithDuration:0.4 
                         animations:^{
                             ppv.alpha = 0;
                         }];
        
    }else{
        [UIView animateWithDuration:0.4 
                         animations:^{
                             ppv.alpha = 0.5;
                         }];
        
    }
	_barsHidden=hidden;
	
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

/*
- (void)loadScrollViewWithPage:(NSInteger)page{
    
       if(VI==YES)
    {
        realasset =[[self.photoSource objectAtIndex:page]alasset];
        if ([[realasset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
        {  
            
            NSString *p=[NSString stringWithFormat:@"%d",page];
            [self.video addObject:p];
            CGRect frame1 =frame1;
            frame1.origin.x =xOrigin+130;
            frame1.origin.y = 210;
            frame1.size.height=60;
            frame1.size.width=60;
            [self play:frame1];
        }
    }
    NSString *p=[NSString stringWithFormat:@"%d",page];
    if(VI==YES)
    {
        [self performSelector:@selector(favorite:) withObject:p afterDelay:3];    
    }
    //[self favorite];   
    
}

*/

#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePages];
    // Calculate current page
	CGRect visibleBounds = self.scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > self.playlist.storeAssets.count - 1) index = self.playlist.storeAssets.count - 1;
	//NSUInteger previousCurrentPage = currentPageIndex;
	currentPageIndex = index;

    /* [UIView animateWithDuration:0
                     animations:^{
                         //myPickerView.frame = CGRectMake(0, 210, 310, 180);
                         favorite.alpha = 0;
                     }];
    
	NSInteger _index = [self centerPhotoIndex];
     [self updatePages];
	if (_index >= [self.playlist.urls count] || _index < 0 ){//|| (NSNull *)[self.fullScreenPhotos objectAtIndex:_index] == [NSNull null]) {
		return;
	}
	
	if (_pageIndex != _index && !_rotating) {
        ALAsset *asset = [[self.photoSource objectAtIndex:_index]alasset];
        NSString *currentPageUrl=[[[asset defaultRepresentation]url]description];
        ppv.url = currentPageUrl;
        [ppv Buttons];
		[self setBarsHidden:YES animated:YES];
		_pageIndex = _index;
        //[self moveToPhotoAtIndex:_index animated:YES];
        if (!editing) {
            [self setViewState];
        }
		
		if (![scrollView isTracking]) {
			[self layoutScrollViewSubviews];
		}
		
	}*/
   
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
	[mailViewController release];
	
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
		[alert release];
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
	
	[actionSheet release];
	
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
    if (_index >= [self.photoSource count] || _index < 0) {
        currentPageIndex = 0;
    }
    [self setBarsHidden:YES animated:YES];
    NSString *animateStyle = [timer userInfo];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
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
    
   
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"PhotoView");
}
#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
	timer = nil;
	_photoViews=nil;
	photoSource=nil;
	_scrollView=nil;
	
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [photoInfoTimer release];
    [assetInfoView release];
    if (timer) {
        [timer release];
    }
    [playlist release];
    [saveItem release];
	[_photoViews release];
	[photoSource release];
	[_scrollView release];
    [cropView release];
    [super dealloc];
}
@end