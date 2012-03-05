//
//  SettingController.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "resetView.h"

@interface SettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationBarDelegate>
{
    UITableView *table;
    UITableViewCell *iconsizeCell;
    UITableViewCell *albumiconCell;
    UITableViewCell *lockmodeCell;
    UITableViewCell *dateCell;
    UITableViewCell *resetCell;
    UITableViewCell *versionCell;
    UIButton *iconsizeButton;
    UIButton *albumiconButton;
    UIButton *dateButton;
    resetView *re;
}
@property(nonatomic,strong)IBOutlet UITableView *table;
@property(nonatomic,strong)IBOutlet UITableViewCell *iconsizeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *albumiconCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *lockmodeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *dateCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *resetCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *versionCell;
-(UIButton *)iconsizeButton;
-(UIButton *)albumiconButton;
-(UIButton *)dateButton;
@end
