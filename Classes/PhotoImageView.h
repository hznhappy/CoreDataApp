//
//  PhotoImageView.h
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//
@class PhotoScrollView;
@class DisplayPhotoView;

#include <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
@class Playlist;
@interface PhotoImageView : UIView <UIScrollViewDelegate>{
@private
	PhotoScrollView *_scrollView;
	UIImage *_photo;
	UIImageView *_imageView;
	UIActivityIndicatorView *_activityView;
    
    Playlist       *playlist;
    
	NSUInteger     index;
    NSOperationQueue *q;
    
    UIImage *fuzzy;
    UIImage *fullScreen;
	BOOL _loading;
	CGFloat _beginRadians;
}
@property (assign) NSUInteger index;
@property (nonatomic, retain) Playlist *playlist;
@property (nonatomic, retain) UIImage *fuzzy;
@property (nonatomic, retain) UIImage *fullScreen;
@property(nonatomic,readonly) UIImage *photo;
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) PhotoScrollView *scrollView;


- (void)loadIndex: (NSUInteger) _index;
- (void)doLoadIndex: (NSUInteger) _index;
- (void)doLoadIndexStr: (NSString*) _index;
- (void)doLoadImage: (UIImage *) image checkIndex: (NSUInteger) _index;
- (void)setPhoto:(UIImage *)aPhoto;
-(void)setClearPhoto;
- (void)displayImageFailure;
- (void)rotatePhoto;
-(void)savePhoto;
- (void)killScrollViewZoom;
- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
@end


@interface UIImage (UIImage_Extensions)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;
