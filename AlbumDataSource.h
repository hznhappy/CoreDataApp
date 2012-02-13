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
@class Album;
@interface AlbumDataSource : NSObject {
    AmptsPhotoCoreData * coreData;
    OnDeviceAssets * deviceAssets;
     NSMutableArray* assetsBook;
    NSOperationQueue *opQueue;
    UINavigationController *nav;
    
}
@property (nonatomic,strong) AmptsPhotoCoreData * coreData;
@property (nonatomic,strong) OnDeviceAssets * deviceAssets;
@property (nonatomic,strong) NSMutableArray * assetsBook;
@property (nonatomic,strong) NSOperationQueue * opQueue;
@property (nonatomic,strong)UINavigationController *nav;
-(id) initWithAppName: (NSString*) app navigationController:(UINavigationController *)navigationController;
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
-(void) refresh;
-(void) syncDataSource;
-(void) testDataSource;
-(void)fresh:(Album *)al index:(int)index;
@end
