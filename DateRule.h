//
//  DateRule.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface DateRule : NSManagedObject

@property (nonatomic, strong) NSString * opCode;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * stopDate;
@property (nonatomic, strong) Album *conAlbum;

@end
