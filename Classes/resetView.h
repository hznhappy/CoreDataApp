//
//  resetView.h
//  PhotoApp
//
//  Created by  on 12-3-2.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface resetView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *table;
    NSMutableArray *resetList;
}
@property(nonatomic,strong)IBOutlet UITableView *table;
@end
