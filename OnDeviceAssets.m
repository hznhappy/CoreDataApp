//
//  OnDeviceAssets.m
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 18/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OnDeviceAssets.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"

@implementation OnDeviceAssets
@synthesize deviceAssetsList,library;
@synthesize devicePeopleList;
@synthesize urls;
@synthesize photoCount;
@synthesize videoCount;

-(id)init {
    self=[super init];
    if (self) {
        deviceAssetsList=[[NSMutableDictionary alloc]init] ;
        devicePeopleList=[[NSMutableDictionary alloc]init];
        library=[[ALAssetsLibrary alloc]init];
        urls = [[NSMutableArray alloc]init];
        photoCount = 0;
        videoCount = 0;
        [self refreshData];
    }
  
    return  self;
}


-(ALAsset*) getAsset:(NSString *)l {
    return (ALAsset*)[deviceAssetsList objectForKey:l];
}

-(void) refreshData {
   /* ABAddressBookRef addressBook = ABAddressBookCreate();
    
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        ABRecordID recId = ABRecordGetRecordID(person);
        NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        //NSNumber *fid=[NSNumber numberWithInt:recId];
        NSString *fid1=[NSString stringWithFormat:@"%d",recId];
        NSLog(@"FID:%@",fid1);
        NSMutableArray *A=[[NSMutableArray alloc]initWithObjects:personName,lastname,nil];
        [self.devicePeopleList setObject:A forKey:fid1];
        
        
    }

   */
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
             if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ) {
                 videoCount += 1;
             }else{
                 photoCount += 1;
             }
             NSString *u= [[[result defaultRepresentation]url]description];
             [urls addObject:u];
             // XXX fixme
             //[self.deviceAssetsList setObject:result forKey:u];
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
