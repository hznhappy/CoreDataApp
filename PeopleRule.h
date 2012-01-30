//
//  PeopleRule.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, PeopleRuleDetail;

@interface PeopleRule : NSManagedObject

@property (nonatomic, strong) NSNumber * allOrAny;
@property (nonatomic, strong) Album *conAlbum;
@property (nonatomic, strong) NSSet *conPeopleRuleDetail;
@end

@interface PeopleRule (CoreDataGeneratedAccessors)

- (void)addConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)removeConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)addConPeopleRuleDetail:(NSSet *)values;
- (void)removeConPeopleRuleDetail:(NSSet *)values;
@end
