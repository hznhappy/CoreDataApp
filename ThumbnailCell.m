//
//  AssetCell.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "ThumbnailCell.h"
#import "Asset.h"

@implementation ThumbnailCell
@synthesize selectionDelegate;
@synthesize rowNumber,sectionNumber;
-(void)displayThumbnails:(NSArray *)array beginIndex:(NSInteger)index count:(NSUInteger)count action:(BOOL)act size:(NSInteger)size
{
    CGRect frame = CGRectMake(4, 2, size-4, size-4);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSUInteger i = 0;i <count; i++) {
        if (i < [array count]) {
            Asset *dbAsset = [array objectAtIndex:i];
            
            ThumbnailImageView *thumImageView = [[ThumbnailImageView alloc]initWithFrame:frame Asset:dbAsset index:index action:act];
            thumImageView.delegate = self;
            [self addSubview:thumImageView];
            frame.origin.x = frame.origin.x + frame.size.width + 4;
            index += 1;
        }        
    }
}

-(UIImageView *)addTagOverlayWhenSelected
{
    CGRect viewFrames = CGRectMake(0, 0, 75, 75);
    UIImageView *overlayView = [[UIImageView alloc]initWithFrame:viewFrames];
    [overlayView setImage:[UIImage imageNamed:@"selectOverlay.png"]];
    return overlayView;
}
-(void)removeTag:(NSString *)selectedRow
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ThumbnailImageView class]] && [selectedRow isEqualToString:[NSString stringWithFormat:@"%d",((ThumbnailImageView *)view).thumbnailIndex]]) {
            for (UIView *vi in view.subviews) {
                if ([vi isKindOfClass:[UIImageView class]] ) {
                    if ([((UIImageView *)vi).image isEqual:[UIImage imageNamed:@"selectOverlay.png"]]) {
                        [vi removeFromSuperview];
                    }
                }
            }
            
        }
    }

}

-(void)checkTagSelection:(NSString *)selectedRow{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ThumbnailImageView class]] && [selectedRow isEqualToString:[NSString stringWithFormat:@"%d",((ThumbnailImageView *)view).thumbnailIndex]]) {
            
            [(ThumbnailImageView *)view addSubview:[self addTagOverlayWhenSelected]];
            
            
        }
    }
}

-(void)clearSelection{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ThumbnailImageView class]]) {
            [(ThumbnailImageView *)view clearSelection];
        }
    }
}
#pragma mark -
#pragma mark delegate methods;
-(void)thumbnailImageViewSelected:(ThumbnailImageView *)thumbnailImageView{
    [selectionDelegate selectedThumbnailCell:self selectedAtIndex:thumbnailImageView.thumbnailIndex];
}

@end
