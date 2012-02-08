//
//  EventRule.h
//  PhotoApp
//
//  Created by  on 12-2-8.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Event;

@interface EventRule : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * opCode;
@property (nonatomic, retain) Album *conAlbum;
@property (nonatomic, retain) Event *conEvent;

@end
