//
//  backgroundUpdate.h
//  PhotoApp
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Assetslibrary/Assetslibrary.h>

@interface backgroundUpdate : NSObject
{
NSMutableDictionary *deviceAssetsList;
NSMutableArray *urls;
NSMutableDictionary *devicePeopleList;

ALAssetsLibrary * library;

}
@property (nonatomic,strong)NSMutableDictionary *  deviceAssetsList;
@property (nonatomic,strong)NSMutableDictionary *  devicePeopleList;
@property (nonatomic,strong) ALAssetsLibrary * library;
@property (nonatomic,strong)NSMutableArray *urls;

-(ALAsset *) getAsset:(NSString *) l;
-(void) refreshData;

@end
