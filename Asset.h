//
//  Asset.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssetRule, Event, PeopleTag;

@interface Asset : NSManagedObject

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * numOfLike;
@property (nonatomic, strong) NSNumber * numPeopleTag;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSSet *conAssetRule;
@property (nonatomic, strong) Event *conEvent;
@property (nonatomic, strong) NSSet *conPeopleTag;
@end

@interface Asset (CoreDataGeneratedAccessors)

- (void)addConAssetRuleObject:(AssetRule *)value;
- (void)removeConAssetRuleObject:(AssetRule *)value;
- (void)addConAssetRule:(NSSet *)values;
- (void)removeConAssetRule:(NSSet *)values;
- (void)addConPeopleTagObject:(PeopleTag *)value;
- (void)removeConPeopleTagObject:(PeopleTag *)value;
- (void)addConPeopleTag:(NSSet *)values;
- (void)removeConPeopleTag:(NSSet *)values;
@end
