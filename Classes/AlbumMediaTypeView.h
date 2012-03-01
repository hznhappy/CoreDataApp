//
//  AlbumMediaTypeView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
@class PhotoAppDelegate;
@interface AlbumMediaTypeView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
     NSMutableArray *type;
    UIImage *selectImg;
    UIImage *unselectImg;
    Album *album;
    NSString *chooseType;
}
@property(nonatomic,strong)Album *album;
@property(nonatomic,strong)NSString *chooseType;

@end
