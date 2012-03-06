//
//  Setting.h
//  PhotoApp
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Setting : NSManagedObject

@property (nonatomic, retain) NSString * iconSize;
@property (nonatomic, retain) NSString * albumIcon;
@property (nonatomic, retain) NSNumber * lockMode;
@property (nonatomic, retain) NSString * dateInfo;

@end
