//
//  ThumbnailImageView.m
//  PhotoApp
//
//  Created by  on 12-1-4.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "ThumbnailImageView.h"
#import "ThumbnailCell.h"
#import "AssetTablePicker.h"
#import "Asset.h"
#import "PhotoAppDelegate.h"
@implementation ThumbnailImageView
@synthesize thumbnailIndex;
@synthesize delegate;

-(ThumbnailImageView *)initWithAsset:(Asset*)asset index:(NSUInteger)index action:(BOOL)act{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.thumbnailIndex = index;
        copyMenuShow = NO;
        tagSign = act;
        [self performSelectorInBackground:@selector(asynLoadThumbnailWithAsset:) withObject:asset];
    }
    return self;
}

-(void)asynLoadThumbnailWithAsset:(Asset *)asset{
    PhotoAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *dbUrl = asset.url;
    NSURL *url = [NSURL URLWithString:dbUrl];
    ALAsset *as = [appDelegate.dataSource getAsset:dbUrl];
    CGImageRef ref = [as thumbnail];
    UIImage *img = [UIImage imageWithCGImage:ref];
    [self performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
    thumbnail = img;//[UIImage imageWithCGImage:ref];
    if ([asset.videoType boolValue]) 
    {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        
        CMTime duration = playerItem.duration;
        int durationSeconds = (int)ceilf(CMTimeGetSeconds(duration));
        int hours = durationSeconds / (60 * 60);
        int minutes = (durationSeconds / 60) % 60;
        int seconds = durationSeconds % 60;
        NSString *formattedTimeString = nil;
        if ( hours > 0 ) {
            formattedTimeString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
        } else {
            formattedTimeString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        }

        //[self addSubview:[self addVideoOverlay:durationSeconds]];
        [self performSelectorOnMainThread:@selector(addVideoOverlay:) withObject:formattedTimeString waitUntilDone:NO];
        
    }
    if([asset.numPeopleTag intValue] != 0&&!tagSign)
    {   
        NSString *numStr = [NSString stringWithFormat:@"%@",asset.numPeopleTag];
        //[self addSubview:[self addTagnumberOverlay:numStr]];
        [self performSelectorOnMainThread:@selector(addTagnumberOverlay:) withObject:numStr waitUntilDone:NO];
    }
    
    // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearSelection) name:@"clearSelection" object:nil];

}
#pragma mark -
#pragma mark OverLay method
-(void)addTagnumberOverlay:(NSString *)number
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
    [self addSubview:tagBg];
    //return tagBg;
    
}
-(void)addVideoOverlay:(NSString *)second{
   
    UIView *video =[[UIView alloc]initWithFrame:CGRectMake(0, 54, 75, 16)];
    UILabel *length=[[UILabel alloc]initWithFrame:CGRectMake(40, 3, 45, 10)];
    UIImageView *tu=[[UIImageView alloc]initWithFrame:CGRectMake(6, 4,15, 8)];
    UIImage *picture = [UIImage imageNamed:@"VED.png"];
    [tu setImage:picture];
    [video addSubview:tu];
    
    [length setBackgroundColor:[UIColor clearColor]];
    length.alpha=0.8;
    length.text = second;
    length.textColor = [UIColor whiteColor];
    length.textAlignment = UITextAlignmentLeft;
    length.font = [UIFont boldSystemFontOfSize:12.0];
    [video addSubview:length];
    
    [video setBackgroundColor:[UIColor grayColor]];
    video.alpha=0.9;
    length.alpha = 1.0;
    tu.alpha = 1.0;
    [self addSubview:video];
    //return video;
    
}

#pragma mark -
#pragma mark Touch handling
- (void)showCopyMenu {
   // NSLog(@"I'm tryin' Ringo, I'm tryin' reeeeal hard.");
    // bring up editing menu.
    copyMenuShow = YES;
    [self becomeFirstResponder];
    if (theMenu) {
        theMenu = nil;
    }
    theMenu = [UIMenuController sharedMenuController];
    CGRect selectionRect = [self bounds];
    selectionRect.origin.y += 30;
    [theMenu setTargetRect:selectionRect inView:self];
    [theMenu setMenuVisible:YES animated:YES]; 
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{   
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:)){
        return YES;
    }
    else if (action == @selector(paste:))
        return NO;
    else if (action == @selector(select:) || action == @selector(selectAll:)) 
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

-(void)copy:(id)sender{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:thumbnail];//self.image];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (data) {
        [pasteBoard setData:data forPasteboardType:@"thumbnail"];
    }
    [self clearSelection];
}
- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

-(void)cancelCopyMenu{
    if (theMenu.isMenuVisible) {
        theMenu.menuVisible = NO;
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (ThumbnailCell *cell in ((UITableView *)self.superview.superview).visibleCells) {
        [cell clearSelection];
    }
   
    
    if (((AssetTablePicker *)[self.superview.superview.superview nextResponder]).action) {
        [self performSelector:@selector(showCopyMenu) withObject:nil afterDelay:0.8f];
        [self setSelectedView];
        [self addSubview:highlightView];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    if (!copyMenuShow) {
        [self cancelCopyMenu];
        [delegate thumbnailImageViewSelected:self];
    }else{
        copyMenuShow = NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    [self cancelCopyMenu];
    [highlightView removeFromSuperview];
}

#pragma mark -
#pragma mark Helper mehtods;
- (void)clearSelection {
    if (highlightView.superview != nil) {
        [highlightView removeFromSuperview];
    }
    
}


-(void)setSelectedView{
    if (!highlightView) {
        UIImage *image = [UIImage imageNamed:@"ThumbnailHighlight.png"];
        highlightView = [[UIImageView alloc]initWithImage:image];
        highlightView.alpha = 0.5;
    }
    
}
@end
