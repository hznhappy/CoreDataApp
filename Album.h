//
//  Album.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssetRule, DateRule, EventRule, PeopleRule;

@interface Album : NSManagedObject

@property (nonatomic, strong) NSString * byCondition;
@property (nonatomic, strong) NSNumber * maxAsset;
@property (nonatomic, strong) NSString * music;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * sortOrder;
@property (nonatomic, strong) NSString * transitType;
@property (nonatomic, strong) NSSet *conAssetRule;
@property (nonatomic, strong) DateRule *conDateRule;
@property (nonatomic, strong) NSSet *conEventRule;
@property (nonatomic, strong) PeopleRule *conPeopleRule;
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
