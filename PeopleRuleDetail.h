//
//  PeopleRuleDetail.h
//  PhotoApp
//
//  Created by apple on 1/10/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class People, PeopleRule;

@interface PeopleRuleDetail : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * opcode;
@property (nonatomic, retain) People *conPeople;
@property (nonatomic, retain) PeopleRule *conPeopleRule;

@end
