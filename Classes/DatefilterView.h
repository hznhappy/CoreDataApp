//
//  DatefilterView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "AlbumDataSource.h"
#import "DateRule.h"
@class PhotoAppDelegate;
@interface DatefilterView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *dateList;
    Album *album;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    DateRule *daterule;
}
@property(nonatomic,retain)Album *album;
@end
