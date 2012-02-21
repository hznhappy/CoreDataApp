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
@synthesize rowNumber;
-(void)displayThumbnails:(NSArray *)array count:(NSUInteger)count action:(BOOL)act
{
    
    CGRect frame = CGRectMake(4, 2, 75, 75);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSUInteger i = 0;i <count; i++) {
        if (i < [array count]) {
            NSInteger row = (self.rowNumber*count)+i;
            Asset *dbAsset = [array objectAtIndex:i];
            
            ThumbnailImageView *thumImageView = [[ThumbnailImageView alloc]initWithAsset:dbAsset index:row action:act];
            thumImageView.frame = frame;
            thumImageView.delegate = self;
            [self addSubview:thumImageView];
            frame.origin.x = frame.origin.x + frame.size.width + 4;
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
                NSLog(@"vi:%@",vi);
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
