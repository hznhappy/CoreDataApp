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
        copyMenuShow = NO;
       // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearSelection) name:@"clearSelection" object:nil];
    }
    return self;
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
    // do i even need to show a selection? There's really no point for my implementation...
    // doing it any way to see if it helps the "not showing up" problem...
    CGRect selectionRect = [self bounds];
    selectionRect.origin.y += 30;
    [theMenu setTargetRect:selectionRect inView:self];
    [theMenu setMenuVisible:YES animated:YES]; // <-- doesn't show up...
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
    if (!copyMenuShow) {
        [self cancelCopyMenu];
        [delegate thumbnailImageViewSelected:self];
    }else{
        copyMenuShow = NO;
    }
    NSLog(@"touchEnd");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    [self cancelCopyMenu];
    [highlightView removeFromSuperview];
    NSLog(@"cancel");
}

-(void)cancelCopyMenu{
    if (theMenu.isMenuVisible) {
        theMenu.menuVisible = NO;
    }
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
