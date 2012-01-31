//
//  AnimaSelectController.h
//  PhotoApp
//
//  Created by Andy on 11/4/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@interface AnimaSelectController : UIViewController<UITableViewDelegate,UITableViewDataSource>
 {
    NSMutableArray *animaArray;
     NSString *tranStyle;
     NSMutableArray *Trans_list;
     Album *album;
     NSString *Text;
}
@property(nonatomic,strong)NSMutableArray *animaArray;
@property(nonatomic,strong)NSString *tranStyle;
@property(nonatomic,strong)NSMutableArray *Trans_list;
@property(nonatomic,strong)Album *album;
@property(nonatomic,strong) NSString *Text;

@end
