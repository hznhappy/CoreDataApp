//
//  ThumbnailImageView.h
//  PhotoApp
//
//  Created by  on 12-1-4.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class ThumbnailImageView;
@class Asset;
@protocol ThumbnailSelectionDelegate <NSObject>
-(void)thumbnailImageViewSelected:(ThumbnailImageView *)thumbnailImageView;
@end

@interface ThumbnailImageView : UIImageView{
    UIImageView *highlightView;
    UIMenuController *theMenu;
    NSUInteger thumbnailIndex;
    UIImage *thumbnail;
    BOOL copyMenuShow;
    BOOL tagSign;
    id<ThumbnailSelectionDelegate>__unsafe_unretained delegate;
}
@property(nonatomic,assign)NSUInteger thumbnailIndex;
@property(nonatomic,unsafe_unretained)id<ThumbnailSelectionDelegate>delegate;
-(ThumbnailImageView *)initWithFrame:(CGRect)frame Asset:(Asset*)asset index:(NSUInteger)index action:(BOOL)act;
-(void)LoadThumbnailWithAsset:(Asset *)asset;
-(void)addTagnumberOverlay:(NSString *)numbe;
-(void)addEventOverlay;
-(void)addVideoOverlay:(NSString *)second;
-(void)setSelectedView;
-(void)clearSelection;
-(void)cancelCopyMenu;
@end
