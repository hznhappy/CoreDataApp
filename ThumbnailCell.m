//
//  AssetCell.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "ThumbnailCell.h"
#import "Asset.h"
#import "PhotoAppDelegate.h"
@implementation ThumbnailCell
@synthesize selectionDelegate;
@synthesize rowNumber;
-(void)displayThumbnails:(NSArray *)array count:(NSUInteger)count action:(BOOL)act
{
    PhotoAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CGRect frame = CGRectMake(4, 2, 75, 75);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSUInteger i = 0;i <count; i++) {
        if (i < [array count]) {
            NSInteger row = (self.rowNumber*count)+i;
            Asset *dbAsset = [array objectAtIndex:i];
            NSString *dbUrl = dbAsset.url;
            NSURL *url = [NSURL URLWithString:dbUrl];
            ALAsset *asset = [appDelegate.dataSource getAsset:dbAsset.url];
            ThumbnailImageView *thumImageView = [[ThumbnailImageView alloc]initWithAsset:asset index:row];
            thumImageView.frame = frame;
            thumImageView.delegate = self;
            [self addSubview:thumImageView];
            frame.origin.x = frame.origin.x + frame.size.width + 4;
            if ([dbAsset.videoType boolValue]) 
            {
                NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                 forKey:AVURLAssetPreferPreciseDurationAndTimingKey];           
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts]; 
                
                minute = 0, second = 0; 
                second = urlAsset.duration.value / urlAsset.duration.timescale;
                if (second >= 60) {
                    int index = second / 60;
                    minute = index;
                    second = second - index*60;                        
                }    
                [thumImageView addSubview:[self addVideoOverlay]];
                
            }
            if([dbAsset.numPeopleTag intValue] != 0&&!act)
            {   
                NSString *numStr = [NSString stringWithFormat:@"%@",dbAsset.numPeopleTag];
                [thumImageView addSubview:[self addTagnumberOverlay:numStr]];
            }


        }
        
    }
}


-(UIView *)addTagnumberOverlay:(NSString *)number
{
    UIView *tagBg =[[UIView alloc]initWithFrame:CGRectMake(3, 3, 25, 25)];
    CGPoint tagBgCenter = tagBg.center;
    tagBg.layer.cornerRadius = 25 / 2.0;
    tagBg.center = tagBgCenter;
    
    UIView *tagCount = [[UIView alloc]initWithFrame:CGRectMake(2.6, 2.2, 20, 20)];
    tagCount.backgroundColor = [UIColor colorWithRed:182/255.0 green:0 blue:0 alpha:1];
    CGPoint saveCenter = tagCount.center;
    tagCount.layer.cornerRadius = 20 / 2.0;
    tagCount.center = saveCenter;
    UILabel *count= [[UILabel alloc]initWithFrame:CGRectMake(3, 4, 13, 12)];
    count.backgroundColor = [UIColor colorWithRed:182/255.0 green:0 blue:0 alpha:1];
    count.textColor = [UIColor whiteColor];
    count.textAlignment = UITextAlignmentCenter;
    count.font = [UIFont boldSystemFontOfSize:11];
    count.text = number;
    [tagCount addSubview:count];
    [tagBg addSubview:tagCount];
    return tagBg;
    
}
-(UIView *)addVideoOverlay{
    UIView *video =[[UIView alloc]initWithFrame:CGRectMake(0, 54, 74, 16)];
    UILabel *length=[[UILabel alloc]initWithFrame:CGRectMake(40, 3, 44, 10)];
    UIImageView *tu=[[UIImageView alloc]initWithFrame:CGRectMake(6, 4,15, 8)];
    //  tu= [UIButton buttonWithType:UIButtonTypeCustom]; 
    UIImage *picture = [UIImage imageNamed:@"VED.png"];
    // set the image for the button
    [tu setImage:picture];
    [video addSubview:tu];
    
    
    [length setBackgroundColor:[UIColor clearColor]];
    length.alpha=0.8;
    NSString *a=[NSString stringWithFormat:@"%d",minute];
    NSString *b=[NSString stringWithFormat:@"%d",second];
    length.text=a;
    length.text=[length.text stringByAppendingString:@":"];
    length.text=[length.text stringByAppendingString:b];
    length.textColor = [UIColor whiteColor];
    length.textAlignment = UITextAlignmentLeft;
    length.font = [UIFont boldSystemFontOfSize:12.0];
    [video addSubview:length];
    
    [video setBackgroundColor:[UIColor grayColor]];
    video.alpha=0.9;
    length.alpha = 1.0;
    tu.alpha = 1.0;
    return video;

}

-(UIImageView *)addTagOverlayWhenSelected
{
    CGRect viewFrames = CGRectMake(0, 0, 75, 75);
    UIImageView *overlayView = [[UIImageView alloc]initWithFrame:viewFrames];
    [overlayView setImage:[UIImage imageNamed:@"selectOverlay.png"]];
    return overlayView;
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
