//
//  People.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PeopleRuleDetail, PeopleTag;

@interface People : NSManagedObject

@property (nonatomic, retain) NSNumber * addressBookId;
@property (nonatomic, retain) NSNumber * colorCode;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * inAddressBook;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * listSeq;
@property (nonatomic, retain) NSSet *conPeopleRuleDetail;
@property (nonatomic, retain) NSSet *conPeopleTag;
@end

@interface People (CoreDataGeneratedAccessors)

- (void)addConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)removeConPeopleRuleDetailObject:(PeopleRuleDetail *)value;
- (void)addConPeopleRuleDetail:(NSSet *)values;
- (void)removeConPeopleRuleDetail:(NSSet *)values;

- (void)addConPeopleTagObject:(PeopleTag *)value;
- (void)removeConPeopleTagObject:(PeopleTag *)value;
- (void)addConPeopleTag:(NSSet *)values;
- (void)removeConPeopleTag:(NSSet *)values;

@end
