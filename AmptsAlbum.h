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
    NSInteger num;
    NSMutableArray * assetsList;
    BOOL isDirty;
}

@property (nonatomic,retain) NSManagedObjectID *alblumId;
@property (nonatomic,retain) NSMutableArray * assetsList;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,assign)  NSInteger num;
@property (nonatomic,assign) BOOL isDirty;
@end
