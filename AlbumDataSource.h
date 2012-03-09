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
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
//#import "backgroundUpdate.h"
@class Album;
@interface AlbumDataSource : NSObject {
    AmptsPhotoCoreData * coreData;
    OnDeviceAssets * deviceAssets;
    OnDeviceAssets *refreshAssets;
   // backgroundUpdate *background;
     NSMutableArray* assetsBook;
    NSMutableArray *favoriteList;
    NSOperationQueue *opQueue;
    NSOperationQueue *dateQueue;
    UINavigationController *nav;
    NSNumber *password;
    AmptsAlbum *AlbumAll;
    AmptsAlbum *AlbumUnTAG;
    NSString *s;
    NSMutableArray *Add;
    NSMutableArray *Del;
    BOOL over;
    BOOL background;
    
}
@property (nonatomic,strong) AmptsPhotoCoreData * coreData;
@property (nonatomic,strong) OnDeviceAssets * deviceAssets;
@property (nonatomic,strong) NSMutableArray * assetsBook;
@property (nonatomic,strong) NSMutableArray * favoriteList;
@property (nonatomic,strong) NSOperationQueue * opQueue;
@property (nonatomic,strong)UINavigationController *nav;
@property (nonatomic,strong)NSNumber *password;

@property (nonatomic,strong)NSString *s;

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
-(NSPredicate *) chooseRule:(Album*) i;
-(NSPredicate *)chooseFavorite:(Album *)i;
-(void) syncAssetwithDataSource;
-(void) refreshDataSource;
-(void) refresh;
-(void)refreshback;
-(void) refreshTag;
-(void) syncDataSource;
//-(void)background;
-(void)update;
//-(void) testDataSource;
-(void)fresh:(Album *)al index:(int)index;
-(NSMutableArray *)addPeople:(People*)po;
-(void)refreshPeople;
-(void)reloadTimeData:(NSNotification *)note;
@end
