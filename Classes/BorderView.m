//
//  BorderView.m
//  PhotoApp
//
//  Created by apple on 1/30/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import "BorderView.h"

@implementation BorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
        
    CGContextBeginPath(context);
    //draw the border
    CGContextSetLineWidth(context, 2.0f);
    CGContextMoveToPoint(context, minX, minY);
    CGContextAddLineToPoint(context, maxX, minY);
    CGContextAddLineToPoint(context, maxX, maxY);
    CGContextAddLineToPoint(context, minX, maxY);
    CGContextAddLineToPoint(context, minX, minY);
    CGContextStrokePath(context);

}


@end
