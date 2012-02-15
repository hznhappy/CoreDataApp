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
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
@class Playlist;
@interface PhotoImageView : UIView <UIScrollViewDelegate>{
@private
	PhotoScrollView *__unsafe_unretained _scrollView;
	UIImageView *_imageView;
	UIActivityIndicatorView *_activityView;
    
    Playlist       *playlist;
    
	NSUInteger     index;
    //NSOperationQueue *q;
    
    UIImage *fuzzy;
    UIImage *fullScreen;
	//BOOL _loading;
	CGFloat _beginRadians;
    MPMoviePlayerController *moviePlayer;
    BOOL playingVideo;
}
@property (assign) NSUInteger index;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, strong) UIImage *fuzzy;
@property (nonatomic, strong) UIImage *fullScreen;
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,readonly) PhotoScrollView *scrollView;
@property (nonatomic,strong)MPMoviePlayerController *moviePlayer;
@property (nonatomic,assign)BOOL playingVideo;
- (void)loadIndex: (NSUInteger) _index;
- (void)doLoadIndex: (NSUInteger) _index;
- (void)doLoadIndexStr: (NSString*) _index;
- (void)doLoadImage: (UIImage *) image checkIndex: (NSUInteger) _index;
- (void)showCopyMenu:(NSSet*)touch;
-(void)setClearImage;
- (void)rotatePhoto;
-(void)savePhoto;
- (void)killScrollViewZoom;
- (void)layoutScrollViewAnimated;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
@end


@interface UIImage (UIImage_Extensions)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;
