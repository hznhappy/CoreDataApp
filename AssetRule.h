//
//  AssetRule.h
//  PhotoApp
//
//  Created by apple on 2/15/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
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
