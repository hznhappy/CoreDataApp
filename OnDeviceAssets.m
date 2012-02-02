//
//  OnDeviceAssets.m
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 18/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OnDeviceAssets.h"


@implementation OnDeviceAssets
@synthesize deviceAssetsList,library;



-(id)init {
    self=[super init];
    deviceAssetsList=[[NSMutableDictionary alloc]init] ;
    library=[[ALAssetsLibrary alloc]init];
    [self refreshData];
    return  self;
}


-(ALAsset*) getAsset:(NSString *)l {
    return (ALAsset*)[deviceAssetsList objectForKey:l];
}

-(void) refreshData {
   
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
       
        if (group == nil) 
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fetchAssetsFinished" object:nil];
            return;
        }
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             
             if(result == nil) 
             { 
                 return;
             }
             
             NSString *u= [[[result defaultRepresentation]url]description];
             // XXX fixme
             [self.deviceAssetsList setObject:result forKey:u];
            // NSLog(@"%@", [[result defaultRepresentation]metadata]);   
         }];
        //NSLog(@"asssetUrl:%@",self.assetsUrlOrdering);
        //[self.assetGroups addObject:group];
        
        
    };
    
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        
        NSLog(@"error happen when enumberatoring group,error: %@ ",[error description]);                 
    };	

    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator 
                         failureBlock:assetGroupEnumberatorFailure];
}



@end
