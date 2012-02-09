//
//  PhotoImageView.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//
#define ZOOM_VIEW_TAG 0x101
#import "PhotoImageView.h"
#import "PhotoScrollView.h"
#import "Playlist.h"
#import <QuartzCore/QuartzCore.h>

@interface RotateGesture : UIRotationGestureRecognizer {}
@end

@implementation RotateGesture
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)gesture{
	return NO;
}
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
	return YES;
}
@end


@interface PhotoImageView (Private)
- (void)layoutScrollViewAnimated:(BOOL)animated;
@end

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation UIImage (UIImage_Extensions)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end

@implementation PhotoImageView 

@synthesize imageView=_imageView;
@synthesize scrollView=_scrollView;
@synthesize index;
@synthesize fuzzy,fullScreen;
@synthesize playlist;
@synthesize moviePlayer;
@synthesize playingVideo;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.opaque = YES;
		playingVideo = NO;
		PhotoScrollView *scrollView = [[PhotoScrollView alloc] initWithFrame:self.bounds];
		scrollView.backgroundColor = [UIColor blackColor];
		scrollView.opaque = YES;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		_scrollView = scrollView;

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = nil;
        imageView.clearsContextBeforeDrawing = YES;
		[_scrollView addSubview:imageView];
		_imageView = imageView;

		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
       // [activityView startAnimating];
		activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 15.0f, (CGRectGetHeight(self.frame)/2) - 15.0f , 30.0f, 30.0f);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:activityView];
		_activityView = activityView;
		
		RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
		[self addGestureRecognizer:gesture];
		
	}
    return self;
}




- (void)layoutSubviews{
	[super layoutSubviews];
		
	if (_scrollView.zoomScale == 1.0f) {
		[self layoutScrollViewAnimated:YES];
	}
	
}

- (void)loadIndex: (NSUInteger) _index {
    //NSLog(@"Asset Loading");
    // set the tag for async operation result check
     //[_activityView startAnimating];
    self.tag = _index;
    // reset our zoomScale to 1.0 before doing any further calculations
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = nil;
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        [self doLoadImage: nil checkIndex: _index];
    //    });
    [self performSelectorInBackground:@selector(doLoadIndexStr:) withObject:[NSString stringWithFormat:@"%d", _index]];
}

- (void)doLoadIndex: (NSUInteger) _index {
  //  NSLog(@"doLoadIndex: %d", _index);
    
    self.fullScreen = nil;
    self.fuzzy = [self.playlist fuzzyImageAtIndex:_index forFullScreenImage:^(UIImage *img) {
        //NSLog(@"======== FullScreen Loaded ===========");
        self.fullScreen = img;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doLoadImage: nil checkIndex: _index];
        });
    }];  
    [self doLoadImage: nil checkIndex: _index];
}

- (void)doLoadIndexStr: (NSString*) _index {
    [self doLoadIndex: [_index integerValue]];
}

- (void)doLoadImage: (UIImage *) image checkIndex: (NSUInteger) _index {
    
    if (self.tag != _index) {
        NSLog(@"Skipping non-matched image loading process: %d", _index);
        return;
    }
    
    if (image == nil) {
        self.imageView.image = fullScreen != nil ? fullScreen : fuzzy;
    } else {
        self.imageView.image = image;
    }
     //[_activityView stopAnimating];
    [self layoutScrollViewAnimated:NO];
    //    self.contentSize = [self.imageView.image size];
    //    
    ////    NSLog(@"Content Size: %fx%f", self.contentSize.width, self.contentSize.height);
    //    if (self.contentSize.width > 0 && self.contentSize.height > 0) {
    //        [self setMaxMinZoomScalesForCurrentBounds];
    //        self.zoomScale = self.minimumZoomScale;
    ////        NSLog(@"Minimum Zoom Scale: %f", self.minimumZoomScale);
    //    }
    //
}


-(void)rotatePhoto{

    UIImage *image = [self.fullScreen imageRotatedByDegrees:90];
    self.fullScreen = image;
    self.imageView.image = self.fullScreen;
    [self layoutScrollViewAnimated:NO];

}

-(void)savePhoto{
    UIImageWriteToSavedPhotosAlbum(self.fullScreen, nil, nil, nil);

}

#pragma mark -
#pragma mark Parent Controller Fading
- (void)resetBackgroundColors{
	
	self.backgroundColor = [UIColor blackColor];
	self.superview.backgroundColor = self.backgroundColor;
	self.superview.superview.backgroundColor = self.backgroundColor;

}


#pragma mark -
#pragma mark Layout
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation{

	if (self.scrollView.zoomScale > 1.0f) {
		
		CGFloat height, width;
		height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
	} else {
		
		[self layoutScrollViewAnimated:NO];
	}
}

- (void)layoutScrollViewAnimated:(BOOL)animated{

//	if (animated) {
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:0.0001];
//	}
    if (CGSizeEqualToSize(self.imageView.image.size, CGSizeZero)) {
        return;
    }
    if (self.scrollView.zoomScale == 1) {
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = YES;
    }

	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
	
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
	self.imageView.frame = self.scrollView.bounds;
//	if (animated) {
//		[UIView commitAnimations];
//	}
    NSLog(@"image size is %@",NSStringFromCGSize(self.imageView.image.size));
}


#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)killZoomAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	
	if([finished boolValue]){
		
		[self.scrollView setZoomScale:1.0f animated:NO];
		self.imageView.frame = self.scrollView.bounds;
		[self layoutScrollViewAnimated:NO];
		
	}
	
}

- (void)killScrollViewZoom{
	if (CGSizeEqualToSize(self.imageView.image.size, CGSizeZero)) {
        return;
    }

	if (!self.scrollView.zoomScale > 1.0f) return;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(killZoomAnimationDidStop:finished:context:)];
	[UIView setAnimationDelegate:self];
    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
		
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
		
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;

	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.imageView.frame = self.scrollView.bounds;
	[UIView commitAnimations];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (playingVideo) {
        return moviePlayer.view;
    }else{
        return self.imageView;
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.zoomScale > 1.0f) {				
		CGFloat height, width;	
		
		if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
		} else {
			width = CGRectGetMaxX(self.imageView.frame);
			
        }
		
		if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
		} else {
			height = CGRectGetMaxY(self.imageView.frame);
			
			if (self.imageView.frame.origin.y < 0.0f) {
			} else {
			}
		}
        
		CGRect frame = self.scrollView.frame;
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		if (!CGRectEqualToRect(frame, self.scrollView.frame)) {		
			
			CGFloat offsetY, offsetX;
            
			if (frame.origin.y < self.scrollView.frame.origin.y) {
				offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
			} else {				
				offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
			}
			
			if (frame.origin.x < self.scrollView.frame.origin.x) {
				offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
			} else {				
				offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
			}
            
			if (offsetY < 0) offsetY = 0;
			if (offsetX < 0) offsetX = 0;
			
			self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
		}
	} else {
		[self layoutScrollViewAnimated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"resetCropView" object:nil];

	}
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeCropView" object:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeCropView" object:nil];
}

#pragma mark -
#pragma mark RotateGesture

- (void)rotate:(UIRotationGestureRecognizer*)gesture{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		
		[self.layer removeAllAnimations];
		_beginRadians = gesture.rotation;
		self.layer.transform = CATransform3DMakeRotation(_beginRadians, 0.0f, 0.0f, 1.0f);
		
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
		
		self.layer.transform = CATransform3DMakeRotation((_beginRadians + gesture.rotation), 0.0f, 0.0f, 1.0f);

	} else {
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		animation.duration = 0.3f;
		animation.removedOnCompletion = NO;
		animation.fillMode = kCAFillModeForwards;
		animation.delegate = self;
		[animation setValue:[NSNumber numberWithInt:202] forKey:@"AnimationType"];
		[self.layer addAnimation:animation forKey:@"RotateAnimation"];
		
	} 

	
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	if (flag) {
		
		if ([[anim valueForKey:@"AnimationType"] integerValue] == 101) {
			
			[self resetBackgroundColors];
			
		} else if ([[anim valueForKey:@"AnimationType"] integerValue] == 202) {
			
			self.layer.transform = CATransform3DIdentity;
			
		}
	}
	
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
		
	[[NSNotificationCenter defaultCenter] removeObserver:self];
		
}


@end
