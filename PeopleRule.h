//
//  PeopleRule.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, PeopleRuleDetail;

@interface PeopleRule : NSManagedObject

@property (nonatomic, retain) NSNumber * allOrAny;
@property (nonatomic, retain) Album *conAlbum;
@property (nonatomic, retain) NSSet *conPeopleRuleDetail;
@end

@interface PeopleRule (CoreDataGeneratedAccessors)

- (void)addConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)removeConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)addConPeopleRuleDetail:(NSSet *)values;
- (void)removeConPeopleRuleDetail:(NSSet *)values;

@end
