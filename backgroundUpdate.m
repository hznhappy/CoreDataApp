//
//  backgroundUpdate.m
//  PhotoApp
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "backgroundUpdate.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
//#import "Asset.h"


@implementation backgroundUpdate
@synthesize deviceAssetsList,library;
@synthesize devicePeopleList;
@synthesize urls;

-(id)init {
    self=[super init];
    if (self) {
        deviceAssetsList=[[NSMutableDictionary alloc]init] ;
        devicePeopleList=[[NSMutableDictionary alloc]init];
        library=[[ALAssetsLibrary alloc]init];
        urls = [[NSMutableArray alloc]init];
        [self refreshData];
    }
    NSLog(@"D");
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
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fetchAssets" object:nil];
            NSLog(@"COUT:%d",[deviceAssetsList count]);
            return;
        }
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             
             if(result == nil) 
             { 
                 return;
             }
             NSString *u= [[[result defaultRepresentation]url]description];
             [urls addObject:u];
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
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator 
                         failureBlock:assetGroupEnumberatorFailure];
}



@end
