//
//  AssetRule.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Asset;

@interface AssetRule : NSManagedObject

@property (nonatomic, retain) NSString * opCode;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Album *conAllbum;
@property (nonatomic, retain) Asset *conAsset;

@end
