//
//  DateRule.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface DateRule : NSManagedObject

@property (nonatomic, retain) NSString * opCode;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * stopDate;
@property (nonatomic, retain) Album *conAlbum;

@end
