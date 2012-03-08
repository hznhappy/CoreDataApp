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
    NSMutableArray *locate;
    UIImage *selectImg;
    UIImage *unselectImg;
    UITableView *table;
    Album *album;
    NSString *chooseType;
}
@property(nonatomic,strong)Album *album;
@property(nonatomic,strong)NSString *chooseType;
@property(nonatomic,strong)IBOutlet UITableView *table;

@end
