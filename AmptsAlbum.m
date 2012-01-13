//
//  AmptsAlbum.m
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 16/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AmptsAlbum.h"


@implementation AmptsAlbum
@synthesize name,num,alblumId,isDirty,assetsList;




-(id) init {
    self=[super init];
    assetsList=[[NSMutableArray alloc]init];
    isDirty=NO;
    return self;
}

@end
