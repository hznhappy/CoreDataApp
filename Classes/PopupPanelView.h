//
//  PopupPanelView.h
//  PhotoApp
//
//  Created by apple on 11-10-9.
//  Copyright 2011年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class Asset;
@class AlbumDataSource;

@interface PopupPanelView :UIView{
	CGRect rectForOpen;
	CGRect rectForClose;
    Asset *ass;
	BOOL isOpen;
    NSMutableArray *list;
    AlbumDataSource *dataSource;
    UIScrollView *myscroll;
}
@property BOOL isOpen;
@property CGRect rectForOpen;
@property CGRect rectForClose;
@property (nonatomic,strong)NSMutableArray *list;
@property (nonatomic,strong)UIScrollView *myscroll;
- (id)initWithFrame:(CGRect)frame andAsset:(Asset *)asset;
-(void)buttonPressed:(UIButton *)button;
-(void)viewOpen;
-(void)viewClose;
-(void)Buttons;
-(void)selectTagPeople;
@end
