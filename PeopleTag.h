//
//  PeopleTag.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset, People;

@interface PeopleTag : NSManagedObject

@property (nonatomic, retain) Asset *conAsset;
@property (nonatomic, retain) People *conPeople;

@end
