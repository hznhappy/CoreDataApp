//
//  Asset.h
//  PhotoApp
//
//  Created by apple on 2/24/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssetRule, Event, PeopleTag;

@interface Asset : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isprotected;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * nobody;
@property (nonatomic, retain) NSNumber * numOfLike;
@property (nonatomic, retain) NSNumber * numPeopleTag;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * videoType;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSSet *conAssetRule;
@property (nonatomic, retain) Event *conEvent;
@property (nonatomic, retain) NSSet *conPeopleTag;
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
