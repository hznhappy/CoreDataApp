//
//  PeopleRuleDetail.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
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
