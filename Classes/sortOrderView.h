//
//  sortOrderView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "AlbumDataSource.h"
@class PhotoAppDelegate;
@interface sortOrderView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *SortList;
    UITableViewCell *orderCell;
    UIButton *orderButton;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    Album *album;
    UITableView *table;
    NSInteger index;
   
}
@property(nonatomic,strong)IBOutlet UITableViewCell *orderCell;
@property(nonatomic,strong)IBOutlet UITableView *table;
 
@property(nonatomic,strong)Album *album;
-(UIButton *)orderButton;
@end
