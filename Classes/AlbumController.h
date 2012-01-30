//
//  AlbumController.h
//  PhotoApp
//
//  Created by apple on 11-10-18.
//  Copyright 2011年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class PhotoAppDelegate;
@class AlbumDataSource;
@interface AlbumController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationBarDelegate>{
    
    IBOutlet UITableView *tableView;
    UIBarButtonItem *editButton;
    AlbumDataSource * dataSource;
    NSMutableArray *assets;
}

@property(nonatomic,strong)IBOutlet UITableView *tableView; 

-(IBAction)toggleEdit:(id)sender;
-(IBAction)toggleAdd:(id)sender;
-(void)tabled;
@end
