//
//  resetView.h
//  PhotoApp
//
//  Created by  on 12-3-2.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumDataSource.h"
#import "TagSelector.h"
@class PhotoAppDelegate;
@interface resetView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *table;
    NSMutableArray *resetList;
    NSMutableArray *locate;
    UIImage *selectImg;
    UIImage *unselectImg;
    UIBarButtonItem *chooseButton;
    BOOL choose;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    NSMutableArray *needreset;
    TagSelector *tagSelector;
}
@property(nonatomic,strong)IBOutlet UITableView *table;
-(void)reset:(NSMutableArray *)resetList1;
-(void)resetAll;
@end
