//
//  EventRule.h
//  PhotoApp
//
//  Created by apple on 1/19/12.
//  Copyright (c) 2012 chinarewards. All rights reserved.
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
