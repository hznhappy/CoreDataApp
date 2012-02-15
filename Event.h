//
//  Event.h
//  PhotoApp
//
//  Created by apple on 2/15/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
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
