//
//  OnDeviceAssets.m
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 18/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OnDeviceAssets.h"


@implementation OnDeviceAssets
@synthesize deviceAssetsList,stopOperation,library,finishRefresh;


-(void)main{
    NSLog(@"4");
    @try {
        if ([self isCancelled]) {
            stopOperation=YES;
            return;
        }
        
        [self refreshData];
        
        if ([self isCancelled]) {
            stopOperation=YES;
            return;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@ and urls is %d",exception,[self.deviceAssetsList count]);
    }
    
}

-(id)init {
    NSLog(@"3");
    self=[super init];
    deviceAssetsList=[[NSMutableDictionary alloc]init] ;
    library=[[ALAssetsLibrary alloc]init];
    stopOperation=NO;
    finishRefresh=NO;
    return  self;
}

-(BOOL) getStatus{
    return finishRefresh;

}
-(ALAsset*) getAsset:(NSString *)l {
    return (ALAsset*)[deviceAssetsList objectForKey:l];
}

-(void) refreshData {
    self.stopOperation=NO;  
    self.finishRefresh=NO;
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if([self isCancelled] ){
            self.stopOperation=YES;
            return ;
        }
        if (group == nil) 
        {
            self.stopOperation=YES;
            self.finishRefresh=YES;
            return;
        }
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             if ([self isCancelled]) {
                 self.stopOperation=YES;
                 return;
             }
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
    while (finishRefresh==NO) ;
}
-(BOOL)isFinished{
    if (self.stopOperation) {
        return YES;
    }else{
        return [super isFinished];
    }
}


@end
