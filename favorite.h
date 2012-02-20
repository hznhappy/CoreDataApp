//
//  favorite.h
//  PhotoApp
//
//  Created by  on 12-2-16.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "People.h"

@interface favorite : NSObject
{
    NSString *firstname;
    NSString *lastname;
    NSMutableArray * assetsList;
    NSInteger num;
    People *people;
    
}
@property(nonatomic,strong) NSString *firstname;
@property(nonatomic,strong)NSString *lastname;
@property(nonatomic,strong) NSMutableArray * assetsList;
@property(nonatomic,strong)People *people;
@property(nonatomic,assign)NSInteger num;
@end
