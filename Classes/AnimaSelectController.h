//
//  AnimaSelectController.h
//  PhotoApp
//
//  Created by Andy on 11/4/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBOperation.h"

@interface AnimaSelectController : UIViewController<UITableViewDelegate,UITableViewDataSource>
 {
    NSMutableArray *animaArray;
     NSString *tranStyle;
     DBOperation *database;
     NSMutableArray *Trans_list;
     NSString *play_id;
     NSString *Text;
}
@property(nonatomic,strong)NSMutableArray *animaArray;
@property(nonatomic,strong)NSString *tranStyle;
@property(nonatomic,strong)NSMutableArray *Trans_list;
@property(nonatomic,strong)NSString *play_id;
@property(nonatomic,strong) NSString *Text;
-(void)creatTable;
@end
