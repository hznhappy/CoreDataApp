//
//  PhotoViewController.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PhotoViewController.h"
#import "PopupPanelView.h"
#import "tagManagementController.h"
#import "PhotoImageView.h"
#import "AssetRef.h"



@interface PhotoViewController (Private)
- (void)loadScrollViewWithPage:(NSInteger)page;
- (void)layoutScrollViewSubviews;
- (void)setupScrollViewContentSize;
- (void)enqueuePhotoViewAtIndex:(NSInteger)theIndex;
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (NSInteger)centerPhotoIndex;
- (void)setupToolbar;
- (void)setViewState;
- (void)autosizePopoverToImageSize:(CGSize)imageSize photoImageView:(PhotoImageView*)photoImageView;
@end

@implementation PhotoViewController
//@synthesize listid;
@synthesize ppv;
@synthesize scrollView=_scrollView;
@synthesize photoSource; 
@synthesize photoViews=_photoViews;
@synthesize _pageIndex;
@synthesize fullScreenPhotos;
@synthesize video;

- (id)initWithPhotoSource:(NSArray *)aSource currentPage:(NSInteger)page{
	if ((self = [super init])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"PhotoViewToggleBars" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewDidFinishLoading:) name:@"PhotoDidFinishLoading" object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;		
		photoSource = [aSource retain];
        self._pageIndex = page;
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < [self.photoSource count]; i++) {
            [temp addObject:[NSNull null]];
        }
        self.fullScreenPhotos = temp;
        [temp release];
	}
    NSString *pageIndex = [NSString stringWithFormat:@"%d",_pageIndex];
	[self performSelectorOnMainThread:@selector(readPhotoFromALAssets:) withObject:pageIndex waitUntilDone:NO];

    return self;
}
-(void)play:(CGRect)framek
{
        
    playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    playButton.frame =framek;
    [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *picture = [UIImage imageNamed:@"LO.png"];
    // set the image for the button
    [playButton setBackgroundImage:picture forState:UIControlStateNormal];
    [playButton setImage:picture forState:UIControlStateNormal];
    [self.scrollView addSubview:playButton];


}

-(void)readPhotoFromALAssets:(NSString *)pageIndex{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSInteger index = [pageIndex integerValue];
    for (NSInteger i = index-2; i<index+3; i++) {
        if (i >= 0 && i < [self.photoSource count]) {
            UIImage *fullImage = [self.fullScreenPhotos objectAtIndex:i];
            if ((NSNull *)fullImage == [NSNull null] ) {
                ALAsset *asset = [self.photoSource objectAtIndex:i];
               UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation]fullScreenImage]];
               
               // ALAssetRepresentation *rep = [asset defaultRepresentation];
               // NSLog(@"ALAssetRepresentation:%@",rep);
               // NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);//在Caches目录下创建文件,此目录下文件不会在应用退出删除
              //  NSString *videoPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:kFileName] retain];
                // NSString *videoPath = [NSString dataFilePath:[NSString stringWithFormat:@"%@.MOV", kFileName]];
               // NSOutputStream *outPutStream = [NSOutputStream outputStreamToFileAtPath:videoPath append:NO];
               // [outPutStream open];
                
              /*  NSUInteger bufferSize = 1024*100;
                unsigned char buf[bufferSize];
                NSUInteger writeSize = 0;
                NSUInteger videoSize = [rep size];
                NSError *err = nil;
                while(videoSize != 0)
                {
                    NSUInteger readSize = (bufferSize < videoSize)?bufferSize:videoSize;
                    [rep getBytes:buf fromOffset: writeSize
                           length:readSize error:&err];
                   // [outPutStream write:buf maxLength:readSize];
                    
                    videoSize -= readSize;
                    writeSize += readSize;
                }
                //[outPutStream close];

                */
              //  MPMoviePlayerViewController *moviePlayerVC =[[MPMoviePlayerViewController alloc] initWithContentURL:[[asset defaultRepresentation] url]];
                
            [self.fullScreenPhotos replaceObjectAtIndex:i withObject:image];
                
            }
        }
    }
    
    [pool release];
}

#pragma mark -
#pragma mark View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    VI=NO;
    self.hidesBottomBarWhenPushed = YES;
    self.wantsFullScreenLayout = YES;
	self.view.backgroundColor = [UIColor blackColor];
    
	if (!_scrollView) {
		
		_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
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
		[self.view addSubview:_scrollView];
        
	}
    NSMutableArray *views = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < [self.photoSource count]; i++) {
		[views addObject:[NSNull null]];
	}
   NSMutableArray *array=[[NSMutableArray alloc]init];
    self.video=array;
	self.photoViews = views;
    [views release];   
    [array release];
    editing=NO;
    NSString *u=NSLocalizedString(@"Edit", @"title");
    edit=[[UIBarButtonItem alloc]initWithTitle:u style:UIBarButtonItemStyleBordered target:self action:@selector(edit)];
   	self.navigationItem.rightBarButtonItem=edit;
    
    ppv = [[PopupPanelView alloc] initWithFrame:CGRectMake(0, 62, 320, 375)];
    ALAsset *asset = [self.photoSource objectAtIndex:_pageIndex];
    NSString *currentPageUrl=[[[asset defaultRepresentation]url]description];
    ppv.url = currentPageUrl;
    [ppv Buttons];
    [self.view addSubview:ppv];
    ppv.hidden=YES;
    
}
-(void)playVideo
{
    ALAsset *realasset =[self.photoSource objectAtIndex:_pageIndex];
       NSLog(@"alasset:%@",realasset);
    ALAssetRepresentation *ref = [realasset defaultRepresentation];
    NSURL *url = [ref url];
    NSLog(@"%@ is the url ",url);
    /* MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
     [[player view] setFrame:[self.view bounds]]; // Frame must match parent view
     [self.view addSubview:[player view]];
     [player play];
     [player release];*/
    
    
    
    MPMoviePlayerController* theMovie=[[MPMoviePlayerController alloc] initWithContentURL:url]; 
    [[theMovie view] setFrame:[self.view bounds]]; // Frame must match parent view
    [self.view addSubview:[theMovie view]];
    //  theMovie.scalingMode =  MPMovieControlModeDefault;
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
 MPMoviePlayerController* theMovie=[aNotification object]; 
 [[NSNotificationCenter defaultCenter] removeObserver:self 
 name:MPMoviePlayerPlaybackDidFinishNotification 
 object:theMovie]; 
 // Release the movie instance created in playMovieAtURL
 [theMovie release]; 
 }
 
 
 


//}


-(void)viewDidAppear:(BOOL)animated{
    [self moveToPhotoAtIndex:_pageIndex animated:NO];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
	[self setupToolbar];
	[self setupScrollViewContentSize];
}

- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
	[super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];		
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _rotating = YES;
    NSInteger count = 0;
    for (PhotoImageView *view in self.photoViews){
        if ([view isKindOfClass:[PhotoImageView class]]) {
            if (count != _pageIndex) {
                [view setHidden:YES];
            }
        }
        count++;
    }
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    for (PhotoImageView *view in self.photoViews){
        if ([view isKindOfClass:[PhotoImageView class]]) {
            [view rotateToOrientation:toInterfaceOrientation];
        }
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self setupScrollViewContentSize];
    [self moveToPhotoAtIndex:_pageIndex animated:NO];
    [self.scrollView scrollRectToVisible:((PhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).frame animated:YES];
    
    //  unhide side views
    for (PhotoImageView *view in self.photoViews){
        if ([view isKindOfClass:[PhotoImageView class]]) {
            [view setHidden:NO];
        }
    }
    _rotating = NO;
    
}
-(void)edit
{
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
    if (editing)
    {  ppv.hidden=NO;
        
        ppv.alpha=0.4;
        
        [self.view addSubview:ppv];
        edit.style = UIBarButtonItemStyleBordered;
        edit.title = a;
        [ppv viewClose];
    }
    else{
        ppv.hidden=NO;
        edit.style = UIBarButtonItemStyleDone;
        edit.title = b;
        [ppv viewOpen];
    }
    editing = !editing;
    
    
}

- (void)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setupToolbar {
	UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonHit:)];
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	if ([self.photoSource count] > 1) {
		
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

- (NSInteger)currentPhotoIndex{
	
	return _pageIndex;
	
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

- (void)photoViewDidFinishLoading:(NSNotification*)notification{
	if (notification == nil) return;
	UIImage *image = [self.fullScreenPhotos objectAtIndex:[self centerPhotoIndex]];
	if ([[[notification object] objectForKey:@"photo"] isEqual:image]) {
		if ([[[notification object] objectForKey:@"failed"] boolValue]) {
			if (_barsHidden) {
				[self setBarsHidden:NO animated:YES];
			}
		} 
		[self setViewState];
	}
}

- (NSInteger)centerPhotoIndex{
	
	CGFloat pageWidth = self.scrollView.frame.size.width;
	return floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
}

- (void)moveForward:(id)sender{
    
   	[self moveToPhotoAtIndex:[self centerPhotoIndex]+1 animated:NO];
    NSString *pageIndex = [NSString stringWithFormat:@"%d",_pageIndex];
	[self performSelectorOnMainThread:@selector(readPhotoFromALAssets:) withObject:pageIndex waitUntilDone:NO];
}

- (void)moveBack:(id)sender{
    
	[self moveToPhotoAtIndex:[self centerPhotoIndex]-1 animated:NO];
    NSString *pageIndex = [NSString stringWithFormat:@"%d",_pageIndex];
	[self performSelectorOnMainThread:@selector(readPhotoFromALAssets:) withObject:pageIndex waitUntilDone:NO];
}

- (void)setViewState {	
	
	if (_leftButton) {
		_leftButton.enabled = !(_pageIndex-1 < 0);
	}
	
	if (_rightButton) {
		_rightButton.enabled = !(_pageIndex+1 >= [self.photoSource count]);
	}
	
	if (_actionButton) {
        
        _actionButton.enabled = YES;
	}
	
	if ([self.photoSource count] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", _pageIndex+1, [self.photoSource count]];
	} else {
		self.title = @"";
	}
	
	
}
- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated {
    ALAsset *asset = [self.photoSource objectAtIndex:index];
    NSString *currentPageUrl=[[[asset defaultRepresentation]url]description];
    ppv.url = currentPageUrl;
    [ppv Buttons];
	NSAssert(index < [self.photoSource count] && index >= 0, @"Photo index passed out of bounds");
   	_pageIndex = index;
    
	[self setViewState];
	[self enqueuePhotoViewAtIndex:index];
    
	[self loadScrollViewWithPage:index-1];
    VI=YES;
	[self loadScrollViewWithPage:index];
    VI=NO;
	[self loadScrollViewWithPage:index+1];
	
	[self.scrollView scrollRectToVisible:((PhotoImageView*)[self.photoViews objectAtIndex:index]).frame animated:animated];
	
	
	if (index + 1 < [self.photoSource count] && (NSNull*)[self.photoViews objectAtIndex:index+1] != [NSNull null]) {
		[((PhotoImageView*)[self.photoViews objectAtIndex:index+1]) killScrollViewZoom];
	} 
	if (index - 1 >= 0 && (NSNull*)[self.photoViews objectAtIndex:index-1] != [NSNull null]) {
		[((PhotoImageView*)[self.photoViews objectAtIndex:index-1]) killScrollViewZoom];
	} 	
}

- (void)layoutScrollViewSubviews{
	NSInteger _index = [self currentPhotoIndex];
	for (NSInteger page = _index -1; page < _index+2; page++) {
		if (page >= 0 && page < [self.photoSource count]){
			
			CGFloat originX = self.scrollView.bounds.size.width * page;
			
			if (page < _index) {
				originX -= PV_IMAGE_GAP;
			} 
			if (page > _index) {
				originX += PV_IMAGE_GAP;
			}
			
			if ([self.photoViews objectAtIndex:page] == [NSNull null] || !((UIView*)[self.photoViews objectAtIndex:page]).superview){
                [self loadScrollViewWithPage:page];
			}
			
			PhotoImageView *_photoView = (PhotoImageView*)[self.photoViews objectAtIndex:page];
			CGRect newframe = CGRectMake(originX, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
			
			if (!CGRectEqualToRect(_photoView.frame, newframe)) {	
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.1];
				_photoView.frame = newframe;
				[UIView commitAnimations];
                
			}
			
		}
	}
	
}

- (void)setupScrollViewContentSize{
    
	CGSize contentSize = self.view.bounds.size;
	contentSize.width = (contentSize.width * [self.photoSource count]);
	
	if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize)) {
		self.scrollView.contentSize = contentSize;
	}
	
    
}

- (void)enqueuePhotoViewAtIndex:(NSInteger)theIndex{
	
	NSInteger count = 0;
	for (PhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[PhotoImageView class]]) {
			if (count > theIndex+1 || count < theIndex-1) {
				[view prepareForReusue];
				[view removeFromSuperview];
			} else {
				view.tag = 0;
			}
			
		} 
		count++;
	}	
}

- (PhotoImageView*)dequeuePhotoView{
	
	NSInteger count = 0;
	for (PhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[PhotoImageView class]]) {
			if (view.superview == nil) {
				view.tag = count;
				return view;
			}
		}
		count ++;
	}	
	return nil;
	
}

- (void)loadScrollViewWithPage:(NSInteger)page{
    
    if (page < 0) return;
    if (page >= [self.photoSource count]) return;
	
	PhotoImageView *photoView = [self.photoViews objectAtIndex:page];
	if ((NSNull*)photoView == [NSNull null]) {
		
		photoView = [self dequeuePhotoView];
		if (photoView != nil) {
			[self.photoViews exchangeObjectAtIndex:photoView.tag withObjectAtIndex:page];
			photoView = [self.photoViews objectAtIndex:page];
		}
		
	}
	
	if (photoView == nil || (NSNull*)photoView == [NSNull null]) {
		
		photoView = [[PhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
		[self.photoViews replaceObjectAtIndex:page withObject:photoView];
		[photoView release];
		
	} 
    UIImage *photo = [self.fullScreenPhotos objectAtIndex:page];
    if ((NSNull *)photo == [NSNull null]) {
        return;
    }
    [photoView setPhoto:[self.fullScreenPhotos objectAtIndex:page]];
    
    if (photoView.superview == nil) {
		[self.scrollView addSubview:photoView];
	}
     
	CGRect frame = self.scrollView.frame;
	NSInteger centerPageIndex = _pageIndex;
	CGFloat xOrigin = (frame.size.width * page);
	if (page > centerPageIndex) {
		xOrigin = (frame.size.width * page) + PV_IMAGE_GAP;
	} else if (page < centerPageIndex) {
		xOrigin = (frame.size.width * page) - PV_IMAGE_GAP;
	}
	
	frame.origin.x = xOrigin;
	frame.origin.y = 0;
	photoView.frame = frame;
    if(VI==YES)
    {
    ALAsset *realasset =[self.photoSource objectAtIndex:page];
    NSLog(@"alasset:%@",realasset);
    if ([[realasset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
    {  
        
        NSString *p=[NSString stringWithFormat:@"%d",page];
                [self.video addObject:p];
        CGRect frame1 =frame;
        frame1.origin.x =xOrigin+130;
        frame1.origin.y = 210;
        frame1.size.height=60;
        frame1.size.width=60;
        [self play:frame1];
    }
    }
        
       
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	NSInteger _index = [self centerPhotoIndex];
    
	if (_index >= [self.photoSource count] || _index < 0 || (NSNull *)[self.fullScreenPhotos objectAtIndex:_index] == [NSNull null]) {
		return;
	}
	
	if (_pageIndex != _index && !_rotating) {
//        ALAsset *asset = [self.photoSource objectAtIndex:_index];
//        NSString *currentPageUrl=[[[asset defaultRepresentation]url]description];
//        ppv.url = currentPageUrl;
//        [ppv Buttons];
		[self setBarsHidden:YES animated:YES];
		_pageIndex = _index;
        
        NSString *pageIndex = [NSString stringWithFormat:@"%d",_pageIndex];
        [self performSelectorInBackground:@selector(readPhotoFromALAssets:) withObject:pageIndex];
        [self setViewState];
		
		if (![scrollView isTracking]) {
			[self layoutScrollViewSubviews];
		}
		
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSInteger _index = [self centerPhotoIndex];
	if (_index >= [self.photoSource count] || _index < 0) {
		return;
	}	
    [self moveToPhotoAtIndex:_index animated:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
	[self layoutScrollViewSubviews];
}


#pragma mark -
#pragma mark Actions
- (void)markPhoto{
    [self edit];
    
}

- (void)copyPhoto{
	
	[[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(((PhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image) forPasteboardType:@"public.png"];
	
}

- (void)emailPhoto{
	
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"Shared Photo"];
	[mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((PhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
	mailViewController.mailComposeDelegate = self;
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
	
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
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		[self markPhoto];
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
		[self copyPhoto];	
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
		[self emailPhoto];	
	}
}

#pragma mark -
#pragma mark timer method

-(void)fireTimer:(NSString *)animateStyle{
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(playPhoto) userInfo:animateStyle repeats:YES];
}
-(void)playPhoto{
    _pageIndex+=1;
    NSString *pageIndex = [NSString stringWithFormat:@"%d",_pageIndex];
	[self performSelectorOnMainThread:@selector(readPhotoFromALAssets:) withObject:pageIndex waitUntilDone:NO];    [self setBarsHidden:YES animated:YES];
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
    NSInteger _index = self._pageIndex;
	if (_index >= [self.photoSource count] || _index < 0) {
        _pageIndex = 0;
        [self moveToPhotoAtIndex:_pageIndex animated:NO];
    }else{
        [self moveToPhotoAtIndex:_pageIndex animated:NO];
    }
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
    [fullScreenPhotos release];
	[_photoViews release];
	[photoSource release];
	[_scrollView release];
    [super dealloc];
}


@end