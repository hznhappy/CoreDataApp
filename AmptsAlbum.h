//
//  AmptsAlbum.h
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 16/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AmptsAlbum : NSObject {
    NSManagedObjectID * albumId;
    NSString * name;
    NSString * object;
    NSInteger num;
    NSMutableArray * assetsList;
    BOOL isDirty;
}

@property (nonatomic,strong) NSManagedObjectID *alblumId;
@property (nonatomic,strong) NSMutableArray * assetsList;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * object;
@property (nonatomic,assign)  NSInteger num;
@property (nonatomic,assign) BOOL isDirty;
@end
