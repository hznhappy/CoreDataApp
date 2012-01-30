//
//  PeopleRuleDetail.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class People, PeopleRule;

@interface PeopleRuleDetail : NSManagedObject

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * opcode;
@property (nonatomic, strong) People *conPeople;
@property (nonatomic, strong) PeopleRule *conPeopleRule;

@end
