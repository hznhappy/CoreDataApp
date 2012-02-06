//
//  Album.h
//  PhotoApp
//
//  Created by  on 12-2-6.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssetRule, DateRule, EventRule, PeopleRule;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * byCondition;
@property (nonatomic, retain) NSNumber * maxAsset;
@property (nonatomic, retain) NSString * music;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * transitType;
@property (nonatomic, retain) NSString * sortKey;
@property (nonatomic, retain) NSSet *conAssetRule;
@property (nonatomic, retain) DateRule *conDateRule;
@property (nonatomic, retain) NSSet *conEventRule;
@property (nonatomic, retain) PeopleRule *conPeopleRule;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addConAssetRuleObject:(AssetRule *)value;
- (void)removeConAssetRuleObject:(AssetRule *)value;
- (void)addConAssetRule:(NSSet *)values;
- (void)removeConAssetRule:(NSSet *)values;

- (void)addConEventRuleObject:(EventRule *)value;
- (void)removeConEventRuleObject:(EventRule *)value;
- (void)addConEventRule:(NSSet *)values;
- (void)removeConEventRule:(NSSet *)values;

@end
