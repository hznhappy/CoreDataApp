//
//  Event.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset, EventRule;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *conAsset;
@property (nonatomic, retain) NSSet *conEventRule;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addConAssetObject:(Asset *)value;
- (void)removeConAssetObject:(Asset *)value;
- (void)addConAsset:(NSSet *)values;
- (void)removeConAsset:(NSSet *)values;

- (void)addConEventRuleObject:(EventRule *)value;
- (void)removeConEventRuleObject:(EventRule *)value;
- (void)addConEventRule:(NSSet *)values;
- (void)removeConEventRule:(NSSet *)values;

@end
