//
//  AlbumDataSource.h
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 16/12/2011kkkkkkadjak.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmptsPhotoCoreData.h"
#import "OnDeviceAssets.h"
#import "AmptsAlbum.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
#import "DateRule.h"
#import "EventRule.h"
#import "AssetRule.h"
#import <Assetslibrary/Assetslibrary.h>
@interface AlbumDataSource : NSObject {
    AmptsPhotoCoreData * coreData;
    OnDeviceAssets * deviceAssets;
     NSMutableArray* assetsBook;
    NSOperationQueue *opQueue;

    
}
@property (nonatomic,retain) AmptsPhotoCoreData * coreData;
@property (nonatomic,retain) OnDeviceAssets * deviceAssets;
@property (nonatomic,retain) NSMutableArray * assetsBook;
@property (nonatomic,retain) NSOperationQueue * opQueue;
-(id) initWithAppName: (NSString*) app;
-(NSMutableArray* ) getAlbumList;
-(AmptsAlbum*) getAlbum:(NSUInteger) index;
-(NSInteger ) getAlbumCount;
-(ALAsset *) getAsset:(NSString *) u;
-(NSMutableArray *)simpleQuery:(NSString *)table predicate:(NSPredicate*)pre sortField:(NSString *) field sortOrder:(BOOL) asc;
-(NSPredicate *) parsePeopleRule:(PeopleRule*) rule ;
-(NSPredicate *) parsePeopleRuleDetail:(PeopleRuleDetail*) ruleDetail  ;
-(NSPredicate *) parseExcludePeopleRule:(PeopleRule*) rule ;
-(NSPredicate *) parseExcludePeopleRuleDetail:(PeopleRuleDetail*) ruleDetail  ;
-(NSPredicate *) parseDateRule:(DateRule *) rule;
-(NSPredicate *) parseEventRule:(EventRule *) rule;
-(NSPredicate *) parseAssetRule:(AssetRule *) rule;
-(NSPredicate *) ruleFormation:(Album*) i; 
-(NSPredicate *) excludeRuleFormation:(Album*) i; 
-(void) syncAssetwithDataSource;
-(void) refreshDataSource;
-(void) syncDataSource;
-(void) testDataSource;
@end
