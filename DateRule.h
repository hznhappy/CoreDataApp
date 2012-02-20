//
//  DateRule.h
//  PhotoApp
//
//  Created by apple on 2/17/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface DateRule : NSManagedObject

@property (nonatomic, retain) NSString * datePeriod;
@property (nonatomic, retain) Album *conAlbum;

@end
