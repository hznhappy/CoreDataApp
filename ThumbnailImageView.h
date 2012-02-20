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
    int minute;
    int second;
    BOOL copyMenuShow;
    id<ThumbnailSelectionDelegate>__unsafe_unretained delegate;
}
@property(nonatomic,assign)NSUInteger thumbnailIndex;
@property(nonatomic,unsafe_unretained)id<ThumbnailSelectionDelegate>delegate;
-(ThumbnailImageView *)initWithAsset:(Asset*)asset index:(NSUInteger)index action:(BOOL)act;
-(UIView *)addTagnumberOverlay:(NSString *)numbe;
-(UIView *)addVideoOverlay;
-(void)setSelectedView;
-(void)clearSelection;
-(void)cancelCopyMenu;
@end
