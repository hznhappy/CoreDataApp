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
    NSInteger sectinNumber;
    NSInteger thumnailsize;
    id<ThumbnailCellSelectionDelegate>__unsafe_unretained selectionDelegate;
}

@property (nonatomic, assign) NSUInteger rowNumber;
@property (nonatomic, assign) NSInteger sectionNumber;
@property (nonatomic, unsafe_unretained) id<ThumbnailCellSelectionDelegate> selectionDelegate;


-(void)displayThumbnails:(NSArray *)array beginIndex:(NSInteger)index count:(NSUInteger)count action:(BOOL)act size:(NSInteger)size;

-(UIImageView *)addTagOverlayWhenSelected;
-(void)checkTagSelection:(NSString *)selectedRow;
-(void)removeTag:(NSString *)selectedRow;
//-(void)addnum;
-(void)clearSelection;
@end
