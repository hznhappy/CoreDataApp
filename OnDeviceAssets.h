//
//  OnDeviceAssets.h
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 18/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Assetslibrary/Assetslibrary.h>

@interface OnDeviceAssets : NSOperation {
    NSMutableDictionary *deviceAssetsList;
    BOOL stopOperation;
    BOOL finishRefresh;
    ALAssetsLibrary * library;
    
}
@property (nonatomic,retain)NSMutableDictionary *  deviceAssetsList;
@property (nonatomic,assign)BOOL stopOperation;
@property(nonatomic,assign) BOOL finishRefresh;
@property (nonatomic,retain) ALAssetsLibrary * library;
-(ALAsset *) getAsset:(NSString *) l;
-(BOOL) getStatus;
-(void) refreshData;

@end
