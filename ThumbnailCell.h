//
//  AssetCell.h
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ThumbnailImageView.h"

@class ThumbnailCell;

@protocol ThumbnailCellSelectionDelegate <NSObject>

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index;

@end 

@interface ThumbnailCell : UITableViewCell<ThumbnailSelectionDelegate>
{
    NSUInteger rowNumber;
    int minute;
    int second;
    id<ThumbnailCellSelectionDelegate>__unsafe_unretained selectionDelegate;
}

@property (nonatomic, assign) NSUInteger rowNumber;
@property (nonatomic, unsafe_unretained) id<ThumbnailCellSelectionDelegate> selectionDelegate;


-(void)displayThumbnails:(NSArray *)array count:(NSUInteger)count action:(BOOL) act;
-(UIView *)addTagnumberOverlay:(NSString *)numbe;
-(UIImageView *)addTagOverlayWhenSelected;
-(UIView *)addVideoOverlay;
-(void)checkTagSelection:(NSString *)selectedRow;
-(void)removeTag:(NSString *)selectedRow;
//-(void)addnum;
-(void)clearSelection;
@end
