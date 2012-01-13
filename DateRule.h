//
//  DateRule.h
//  PhotoApp
//
//  Created by apple on 1/10/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
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
