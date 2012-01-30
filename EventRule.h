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

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * opCode;
@property (nonatomic, strong) Album *conAlbum;
@property (nonatomic, strong) Event *conEvent;

@end
