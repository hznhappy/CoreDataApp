//
//  People.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PeopleRuleDetail, PeopleTag;

@interface People : NSManagedObject

@property (nonatomic, strong) NSNumber * addressBookId;
@property (nonatomic, strong) NSNumber * colorCode;
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSNumber * inAddressBook;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSNumber * listSeq;
@property (nonatomic, strong) NSSet *conPeopleRuleDetail;
@property (nonatomic, strong) NSSet *conPeopleTag;
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
