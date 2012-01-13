//
//  PeopleRule.h
//  PhotoApp
//
//  Created by apple on 1/10/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
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
