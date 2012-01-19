//
//  PeopleTag.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset, People;

@interface PeopleTag : NSManagedObject

@property (nonatomic, retain) Asset *conAsset;
@property (nonatomic, retain) People *conPeople;

@end
