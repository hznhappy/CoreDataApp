//
//  SettingController.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationBarDelegate>
{
    UITableView *table;
}
@property(nonatomic,strong)IBOutlet UITableView *table;

@end
