//
//  SettingController.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "resetView.h"
#import "Setting.h"
@class PhotoAppDelegate;
@interface SettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationBarDelegate>
{
    UITableView *table;
    UITableViewCell *iconsizeCell;
    UITableViewCell *albumiconCell;
    UITableViewCell *lockmodeCell;
    UITableViewCell *dateCell;
    UITableViewCell *resetCell;
    UITableViewCell *versionCell;
    UILabel *lcon;
    UILabel *album;
    UILabel *lock;
    UILabel *date;
    UILabel *reset;
    UILabel *version;
    
    
    UISwitch *lockSW;
    
    UIButton *iconsizeButton;
    UIButton *albumiconButton;
    UIButton *dateButton;
    resetView *re;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
    Setting *setting;
}
@property(nonatomic,strong)IBOutlet UITableView *table;
@property(nonatomic,strong)IBOutlet UITableViewCell *iconsizeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *albumiconCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *lockmodeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *dateCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *resetCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *versionCell;
@property(nonatomic,strong)IBOutlet UISwitch *lockSW;
@property(nonatomic,strong)IBOutlet UILabel *lcon;
@property(nonatomic,strong)IBOutlet UILabel *album;
@property(nonatomic,strong)IBOutlet UILabel *lock;
@property(nonatomic,strong)IBOutlet UILabel *date;
@property(nonatomic,strong)IBOutlet UILabel *reset;
@property(nonatomic,strong)IBOutlet UILabel *version;
-(UIButton *)iconsizeButton;
-(UIButton *)albumiconButton;
-(UIButton *)dateButton;
-(IBAction)chooseLockMode:(id)sender;
@end
