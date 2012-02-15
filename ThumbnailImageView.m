//
//  ThumbnailImageView.m
//  PhotoApp
//
//  Created by  on 12-1-4.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "ThumbnailImageView.h"

@implementation ThumbnailImageView
@synthesize thumbnailIndex;
@synthesize delegate;

-(ThumbnailImageView *)initWithAsset:(ALAsset*)asset index:(NSUInteger)index{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        CGImageRef ref = [asset thumbnail];
        UIImage *img = [UIImage imageWithCGImage:ref];
        [self setImage:img];
        self.thumbnailIndex = index;
    }
    return self;
}
#pragma mark -
#pragma mark Touch handling
- (void)showCopyMenu {
    NSLog(@"I'm tryin' Ringo, I'm tryin' reeeeal hard.%@",self.superview.superview.superview);
    // bring up editing menu.
    [self becomeFirstResponder];
    UIMenuController *theMenu = [UIMenuController sharedMenuController];
    // do i even need to show a selection? There's really no point for my implementation...
    // doing it any way to see if it helps the "not showing up" problem...
    CGRect selectionRect = [self frame];
    [theMenu setTargetRect:selectionRect inView:self];
    [theMenu setMenuVisible:YES animated:YES]; // <-- doesn't show up...
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{   
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:)){
        NSLog(@"comt");
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
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.image];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (data) {
        [pasteBoard setData:data forPasteboardType:@"thumbnail"];
    }
}
- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(showCopyMenu) withObject:nil afterDelay:0.8f];
    [self setSelectedView];
    [self addSubview:highlightView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    [delegate thumbnailImageViewSelected:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [highlightView removeFromSuperview];
}

#pragma mark -
#pragma mark Helper mehtods;
- (void)clearSelection {
    [highlightView removeFromSuperview];
}


-(void)setSelectedView{
    if (!highlightView) {
        UIImage *image = [UIImage imageNamed:@"ThumbnailHighlight.png"];
        highlightView = [[UIImageView alloc]initWithImage:image];
        highlightView.alpha = 0.5;
    }
    
}
@end
