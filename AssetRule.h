//
//  AssetRule.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Asset;

@interface AssetRule : NSManagedObject

@property (nonatomic, strong) NSString * opCode;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) Album *conAllbum;
@property (nonatomic, strong) Asset *conAsset;

@end
