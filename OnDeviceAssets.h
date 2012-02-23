//
//  OnDeviceAssets.h
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 18/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Assetslibrary/Assetslibrary.h>

@interface OnDeviceAssets : NSObject {
    NSMutableDictionary *deviceAssetsList;
    NSMutableArray *urls;
    NSMutableDictionary *devicePeopleList;
    
    ALAssetsLibrary * library;
    NSString *re;
    
}
@property (nonatomic,strong)NSMutableDictionary *  deviceAssetsList;
@property (nonatomic,strong)NSMutableDictionary *  devicePeopleList;
@property (nonatomic,strong)ALAssetsLibrary * library;
@property (nonatomic,strong)NSMutableArray *urls;
@property (nonatomic,strong)NSString *re;

-(ALAsset *) getAsset:(NSString *) l;
-(void) refreshData;

@end
