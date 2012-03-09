//
//  AlbumDataSource.m
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 16/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDataSource.h"
#import "Asset.h"
#import "Album.h"
#import "People.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
#import "PeopleTag.h"
#import "Event.h"
#import "EventRule.h"
#import "Asset.h"
#import "AssetRule.h"
#import "DateRule.h"
#import "AlbumController.h"
#import "PlaylistRootViewController.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
#import "favorite.h"
@implementation AlbumDataSource
@synthesize coreData,deviceAssets,assetsBook,opQueue;
@synthesize nav;
@synthesize password;
@synthesize favoriteList;
@synthesize s;


-(id) initWithAppName: (NSString *)app navigationController:(UINavigationController *)navigationController{
    self= [super init];
    self.nav = navigationController; 
    coreData=[[AmptsPhotoCoreData alloc]initWithAppName:app];
    over=NO;
    background=NO;
    opQueue=[[NSOperationQueue alloc]init];
    dateQueue=[[NSOperationQueue alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(syncAssetwithDataSource) name:@"fetchAssetsFinished" object:nil];
    deviceAssets=[[OnDeviceAssets alloc]init];
    return self;
}
-(void)update
{   background=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgrounddata) name:@"fetchAssets" object:nil];
    refreshAssets=[[OnDeviceAssets alloc]init];
    refreshAssets.re=@"YES";
    Add=[[NSMutableArray alloc]init];
    Del=[[NSMutableArray alloc]init];
    
}
-(void) syncAssetwithDataSource {
    [opQueue cancelAllOperations];   
    NSInvocationOperation * syncData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(syncDataSource) object:nil];
    NSInvocationOperation * refreshData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(refreshDataSource) object:nil];
    [refreshData addDependency:syncData];
    [opQueue addOperation:syncData];
    [opQueue addOperation:refreshData];
}

-(void) syncDataSource {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
    password=[defaults objectForKey:@"name_preference"];
    NSPredicate * pre1= [NSPredicate predicateWithFormat:@"addressBookId==%d",-1];
    NSMutableArray *PeopleList=[self simpleQuery:@"People" predicate:pre1 sortField:nil
                                       sortOrder:YES];
   if([PeopleList count]==0)
   {
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[coreData managedObjectContext]]; 
    People *favorate=[[People alloc]initWithEntity:entity1 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    favorate.firstName=@"NoBody";
    favorate.favorite=[NSNumber numberWithBool:YES];
    favorate.addressBookId=[NSNumber numberWithInt:-1];
    favorate.listSort=[NSNumber numberWithInt:0];
   }
    [self loadData:deviceAssets];
   
       if(background&&!over)
    {
       [self performSelectorOnMainThread:@selector(refreshDataSource) withObject:nil waitUntilDone:NO]; 
    }
}
-(void)loadData:(OnDeviceAssets *)device
{
    NSArray *urlList =device.urls;
    NSPredicate * pre= [NSPredicate predicateWithFormat:@"NONE url  IN %@",urlList];
    NSMutableArray *assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil
                                       sortOrder:YES];
    for(Asset * tmpAsset in assetsList) {
        [[coreData managedObjectContext] deleteObject:tmpAsset];
        if(background)
        {
            [Del addObject:tmpAsset];
        }
    }
    [coreData saveContext];
    assetsList=[self simpleQuery:@"Asset" predicate:nil sortField:nil
                
                       sortOrder:YES];
    NSMutableArray *tmpArray=[[NSMutableArray alloc]init ];
    for(Asset *tmpAsset in assetsList) {
        [tmpArray addObject:[tmpAsset url]];
    }
    NSArray * toBeAdded=nil;
    if ([tmpArray count]>0) {
        pre=[NSPredicate predicateWithFormat:@"NOT self IN %@",(NSArray*)tmpArray];
        toBeAdded=[urlList filteredArrayUsingPredicate:pre];
    } else {
        toBeAdded=urlList;
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:[coreData managedObjectContext]]; 
    Asset * newAsset=nil;
    for (NSString * str in toBeAdded) {
        ALAsset * alAsset=[[device deviceAssetsList]objectForKey:str]; 
        newAsset=[[Asset alloc]initWithEntity:entity insertIntoManagedObjectContext:[coreData managedObjectContext]];
        NSURL *asUrl = [[alAsset defaultRepresentation]url];
        newAsset.url=[asUrl description];
        @autoreleasepool {
            NSString * strDate=[[[[alAsset defaultRepresentation]metadata]valueForKey:@"{Exif}"]valueForKey:@"DateTimeOriginal"];
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone* timeZone1 = [NSTimeZone timeZoneForSecondsFromGMT:0*3600]; 
            [inputFormatter setTimeZone:timeZone1];
            [inputFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            newAsset.date = [inputFormatter dateFromString:strDate];
        }
        if ([[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ) {
            newAsset.videoType = [NSNumber numberWithBool:YES];
            int durationSeconds = (int)ceilf([[[alAsset valueForProperty:ALAssetPropertyDuration]description]floatValue]);//(CMTimeGetSeconds(duration));
            int hours = durationSeconds / (60 * 60);
            int minutes = (durationSeconds / 60) % 60;
            int seconds = durationSeconds % 60;
            NSString *formattedTimeString = nil;
            if ( hours > 0 ) {
                formattedTimeString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
            } else {
                formattedTimeString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
            }
            newAsset.duration = formattedTimeString;
            newAsset.date = [alAsset valueForProperty:ALAssetPropertyDate];
            
        }else{
            newAsset.videoType = [NSNumber numberWithBool:NO];;
        }
        newAsset.latitude=[NSNumber numberWithDouble:0.0];
        newAsset.longitude=[NSNumber numberWithDouble:0.0];
        newAsset.numOfLike=[NSNumber numberWithInt:0];
        newAsset.numPeopleTag=[NSNumber numberWithInt:0];
        if(background)
        {
            [Add addObject:newAsset];
        }
    }
    
    [coreData saveContext];

}
-(void)DataSource
{if(over)
{
    [self loadData:refreshAssets];
    [self performSelectorOnMainThread:@selector(aDataSource) withObject:nil waitUntilDone:NO];
}
}

-(void)aDataSource
{   if([Add count]>0||[Del count]>0)
{
    [self refreshback];
    deviceAssets=refreshAssets;
   int num=[Add count]+[Del count];
    NSNumber *Num=[NSNumber numberWithInt:num];
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:assetsBook, @"data",Num,@"num",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refresh" object:nil userInfo:dic];
}
}
-(void)refreshback
{
    assetsBook=[[NSMutableArray alloc]init]; 
    favoriteList=[[NSMutableArray alloc]init];
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    [assetsBook removeAllObjects];
    if([Add count]>0)
    {
        [AlbumAll.assetsList addObjectsFromArray:Add];
    }
    if([Del count]>0)
    {
        [AlbumAll.assetsList removeObjectsInArray:Del];
    }
    AlbumAll.num=[AlbumAll.assetsList count];
    [assetsBook addObject:AlbumAll];
    AmptsAlbum *tmpAlbum=nil;
    tmpAlbum=[[AmptsAlbum alloc]init]; 
    NSMutableArray *tem=[[NSMutableArray alloc]init];
    for(AmptsAlbum *al in AlbumAll.assetsList)
    {
        [tem addObject:al];
    }
    tmpAlbum.assetsList=tem;
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag != 0 or conEvent!=nil"];
    NSMutableArray *TageAssets = [self simpleQuery:@"Asset" predicate:pre sortField:nil sortOrder:YES];
    for (Asset *as in TageAssets)
    {
        [tmpAlbum.assetsList removeObject:as];
    }
    AlbumUnTAG.assetsList=tmpAlbum.assetsList;
    AlbumUnTAG.num=[AlbumUnTAG.assetsList count];
    [UIApplication sharedApplication].applicationIconBadgeNumber = AlbumUnTAG.num;
    [assetsBook addObject:AlbumUnTAG];
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    for(Album* i in tmp ) {
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        album.object=[i chooseType];
        pre=[self ruleFormation:i];
        if([i.sortOrder boolValue]==YES){
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:YES];
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
        album.num=[album.assetsList count];
        [assetsBook addObject:album];
        
    }
  

}
-(void)backgrounddata
{
    
   [opQueue cancelAllOperations];   
    NSInvocationOperation * syncData1=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(DataSource) object:nil];
   [opQueue addOperation:syncData1];
    }
-(void) refreshDataSource {
    
    [self refresh];
    [self performSelectorOnMainThread:@selector(playlistAlbum) withObject:nil waitUntilDone:YES];
    over=YES;
}
-(void) refresh
{    
    assetsBook=[[NSMutableArray alloc]init]; 
    favoriteList=[[NSMutableArray alloc]init];
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    [assetsBook removeAllObjects];
    AlbumAll=[[AmptsAlbum alloc]init];
    AlbumAll.name=@"ALL";
    AlbumAll.alblumId=nil;
    NSArray *coreDataAssets = [self simpleQuery:@"Asset" predicate:nil sortField:nil sortOrder:YES];
    
    for (NSString *u in deviceAssets.urls) {
        for (Asset *as in coreDataAssets) {
            if ([as.url isEqualToString:u]) {
                [AlbumAll.assetsList addObject:as];
            }
        }
    }
    
    AlbumAll.num=[AlbumAll.assetsList count];
    [assetsBook addObject:AlbumAll];
    AmptsAlbum *tmpAlbum=nil;
    tmpAlbum=[[AmptsAlbum alloc]init]; 
    NSMutableArray *tem=[[NSMutableArray alloc]init];
    for(AmptsAlbum *al in AlbumAll.assetsList)
    {
        [tem addObject:al];
    }
    tmpAlbum.assetsList=tem;    
    AlbumUnTAG=[[AmptsAlbum alloc]init];
    AlbumUnTAG.name=@"Untag";
    AlbumUnTAG.alblumId=nil;
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag != 0 or conEvent!=nil"];
    NSMutableArray *TageAssets = [self simpleQuery:@"Asset" predicate:pre sortField:nil sortOrder:YES];
      
    for (Asset *as in TageAssets)
    {
        [tmpAlbum.assetsList removeObject:as];
    }
    AlbumUnTAG.assetsList=tmpAlbum.assetsList;
    
    AlbumUnTAG.num=[AlbumUnTAG.assetsList count];
    [UIApplication sharedApplication].applicationIconBadgeNumber = AlbumUnTAG.num;
    [assetsBook addObject:AlbumUnTAG];
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    for(Album* i in tmp ) {
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        album.object=[i chooseType];
        pre=[self ruleFormation:i];
        if([i.sortOrder boolValue]==YES){
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:YES];//[i sortkey]
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
        album.num=[album.assetsList count];
        [assetsBook addObject:album];
        
    }
    [self refreshPeople];
}
-(void)refreshPeople
{
    [favoriteList removeAllObjects];
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"favorite==%@",[NSNumber numberWithBool:YES]];
    NSArray *fa2 = [self simpleQuery:@"People" predicate:favor sortField:@"listSort" sortOrder:YES];
    for(People *p in fa2)
    {
        NSPredicate *ptag=[NSPredicate predicateWithFormat:@"conPeople==%@",p];
        NSArray *Pt=[self simpleQuery:@"PeopleTag" predicate:ptag sortField:nil sortOrder:YES];
        NSMutableArray *WE=[[NSMutableArray alloc]init];
        for(int i=0;i<[Pt count];i++)
        {
            PeopleTag *PT=[Pt objectAtIndex:i];
            if(![PT.conAsset.isprotected boolValue])
            [WE addObject:PT.conAsset];
        }
        favorite *pop=[[favorite alloc]init];
        pop.firstname=p.firstName;
        pop.lastname=p.lastName;
        pop.assetsList=WE;
        pop.num=[WE count];
        pop.people=p;
        [favoriteList addObject:pop];
    }

}
-(NSMutableArray *)addPeople:(People*)po
{
    NSPredicate *ptag=[NSPredicate predicateWithFormat:@"conPeople==%@",po];
    NSArray *Pt=[self simpleQuery:@"PeopleTag" predicate:ptag sortField:nil sortOrder:YES];
    NSMutableArray *WE=[[NSMutableArray alloc]init];
    for(int i=0;i<[Pt count];i++)
    {
        PeopleTag *PT=[Pt objectAtIndex:i];
        if(![PT.conAsset.isprotected boolValue])
        [WE addObject:PT.conAsset];
        
    }
    favorite *pop=[[favorite alloc]init];
    pop.firstname=po.firstName;
    pop.lastname=po.lastName;
    pop.assetsList=WE;
    pop.num=[WE count];
    pop.people=po;
    NSMutableArray *addpeople=[[NSMutableArray alloc]init];
    [addpeople addObject:pop];
    return addpeople;

}
-(void)fresh:(Album *)al index:(int)index
{
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    Album *i=nil;
    if(index==-1)
    {
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
     i=(Album *)[tmp lastObject];
    }
    else
    {
        i=al;
    }
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        album.object=[i chooseType];
        pre=[self ruleFormation:i];
        if([i.sortOrder boolValue]==YES){
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey] sortOrder:YES];
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
    album.num=[album.assetsList count];
    if(index==-1)
    {
        [assetsBook addObject:album];
    }
    else
    {
        [assetsBook replaceObjectAtIndex:index withObject:album];
    }
}
-(void) refreshTag
{
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    [assetsBook removeAllObjects];
    [assetsBook addObject:AlbumAll];
    AmptsAlbum *tmpAlbum=nil;
    tmpAlbum=[[AmptsAlbum alloc]init]; 
    NSMutableArray *tem=[[NSMutableArray alloc]init];
    for(AmptsAlbum *al in AlbumAll.assetsList)
    {
        [tem addObject:al];
    }
    tmpAlbum.assetsList=tem;
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag != 0 or conEvent!=nil"];
    NSMutableArray *TageAssets = [self simpleQuery:@"Asset" predicate:pre sortField:nil sortOrder:YES];
    for (Asset *as in TageAssets)
    {
        [tmpAlbum.assetsList removeObject:as];
    }
    AlbumUnTAG.assetsList=tmpAlbum.assetsList;
    AlbumUnTAG.num=[AlbumUnTAG.assetsList count];
    [UIApplication sharedApplication].applicationIconBadgeNumber = AlbumUnTAG.num;
    [assetsBook addObject:AlbumUnTAG];
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    for(Album* i in tmp ) {
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        album.object=[i chooseType];
        pre=[self ruleFormation:i];
        if([i.sortOrder boolValue]==YES){
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:YES];
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:[i sortKey]  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
        album.num=[album.assetsList count];
        [assetsBook addObject:album];
        
    }
 
}
-(void)playlistAlbum{
    PlaylistRootViewController *root = (PlaylistRootViewController*)self.nav;
    [root.activityView stopAnimating];
    AlbumController *al = [[AlbumController alloc]initWithNibName:@"AlbumController" bundle:[NSBundle mainBundle]];
    [root pushViewController:al animated:NO];
}

-(NSMutableArray*) simpleQuery:(NSString *)table predicate:(NSPredicate *)pre sortField:(NSString *)field sortOrder:(BOOL)asc {
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:coreData.managedObjectContext];   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];
    if (pre!=nil) {

        [request setPredicate:pre];
    }
    if (field!=nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:asc];  
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
        [request setSortDescriptors:sortDescriptors];  
        
    }
    NSError *error;  
    NSMutableArray *mutableFetchResults = [[coreData.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) {  
    }   
    
    // Save our fetched data to an array  
    
    return mutableFetchResults;
}

-(NSPredicate *)parsePeopleRule:(PeopleRule *)rule {
    NSMutableSet * ruleDetail=[rule mutableSetValueForKey:@"conPeopleRuleDetail"];
    NSPredicate * result=nil;
    NSMutableArray * predicateArray=[[NSMutableArray alloc ]init] ;
    [predicateArray removeAllObjects];
    if([ruleDetail count]>0) {
        for(PeopleRuleDetail * i in ruleDetail) {
            [predicateArray addObject:[self parsePeopleRuleDetail:i ]];
        }
        if ([rule.allOrAny boolValue]==YES){
            result= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];  
        } else {
            result =[NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }  
    }
    return result;
}

-(NSPredicate*) parsePeopleRuleDetail:(PeopleRuleDetail *)ruleDetail  {
    NSPredicate * result=nil ;
   if([ruleDetail.opcode isEqualToString:@"INCLUDE"]) {
       
            result=[NSPredicate predicateWithFormat:@"some conPeopleTag.conPeople==%@",[ruleDetail conPeople]];
        
    }else {
   
            result=[NSPredicate predicateWithFormat:@"some conPeopleTag.conPeople!=%@",[ruleDetail conPeople]];             
        
    }
    return result;
}

-(NSPredicate*) excludeRuleFormation:(Album *)i {
    
    NSPredicate *pre=nil;
    
    /*
     People Rules or the Face Rules are parsed in here
     
     */
    
    if ([i conPeopleRule]!=nil) {
        
        pre=[self parseExcludePeopleRule:[i conPeopleRule]];
    }
    return pre;
}  

-(NSPredicate *)parseExcludePeopleRule:(PeopleRule *)rule {
    NSMutableSet * ruleDetail=[rule mutableSetValueForKey:@"conPeopleRuleDetail"];
    NSPredicate * result=nil;
    NSPredicate * tmpResult=nil;
    NSMutableArray * predicateArray=[[NSMutableArray alloc ]init] ;
    [predicateArray removeAllObjects];
    if([ruleDetail count]>0) {
        for(PeopleRuleDetail * i in ruleDetail) {
            tmpResult=[self parseExcludePeopleRuleDetail: i];
            if (tmpResult!=nil) {
                [predicateArray addObject:tmpResult];
            }
        }
        if (predicateArray!=nil) {
            result =[NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    return result;
}

-(NSPredicate*) parseExcludePeopleRuleDetail:(PeopleRuleDetail *)ruleDetail  {
    NSPredicate * result=nil ;
    if(![[ruleDetail opcode] isEqualToString:@"INCLUDE"]) {
        
        result=[NSPredicate predicateWithFormat:@"some conPeopleTag.conPeople==%@",[ruleDetail conPeople]];
        
    }
    return result;
}
-(NSPredicate*) parseDateRule:(DateRule *)rule {
    if(rule.datePeriod != nil)
    { 
        NSPredicate* result =nil;
        NSDate *date = [NSDate date];
        NSDateComponents *components = [[NSDateComponents alloc]init];
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        if ([rule.datePeriod isEqualToString:@"Recent week"]) {
            [components setDay:-7];
            NSDate *lastWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastWeek,date];
        }else if ([rule.datePeriod isEqualToString:@"Recent two weeks"]) {
            [components setDay:-14];
            NSDate *lastTwoWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastTwoWeek,date];
            
        }else if([rule.datePeriod isEqualToString:@"Recent month"]){
            [components setDay:-30];
            NSDate *lastThreeWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastThreeWeek,date];
        }else if([rule.datePeriod isEqualToString:@"Recent three months"]){
            [components setDay:-90];
            NSDate *lastThreeMonth = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastThreeMonth,date];
        }else if([rule.datePeriod isEqualToString:@"Recent six months"]){
            [components setDay:-180];
            NSDate *lastSixMonth = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastSixMonth,date];
        }else if([rule.datePeriod isEqualToString:@"Recent year"]){
            [components setYear:-1];
            NSDate *recentYear = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",recentYear,date];
        }else{
            [components setYear:-1];
            NSDate *lastMonth = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date<%@",lastMonth];
        }
        return result; 
    }
    return nil;
}
-(NSPredicate*) parseEventRule:(EventRule *)rule {
    NSPredicate * result=nil ;
    result=[NSPredicate predicateWithFormat:@"conEvent==%@",[rule conEvent]];
    return result;
}
-(NSPredicate *) parseAssetRule:(AssetRule *)rule {
    NSPredicate * result=nil ;
    if([[rule opCode] isEqualToString:@"INCLUDE"]) {
        result=[NSPredicate predicateWithFormat:@"self==%@",[rule conAsset]];
    }else {
        result=[NSPredicate predicateWithFormat:@"self!=%@",[rule conAsset]];          
    }
    return result;
   
}
-(NSPredicate *) chooseRule:(Album*) i
{
    NSPredicate * result=nil ;
    if([[i chooseType] isEqualToString:@"Photos only"]) {
        result=[NSPredicate predicateWithFormat:@"some videoType==%@",[NSNumber numberWithBool:NO]];//videoType = [NSNumber numberWithBool:YES]
    }else {
        result=[NSPredicate predicateWithFormat:@"videoType==%@",[NSNumber numberWithBool:YES]];          
    }
    return result;

}
-(NSPredicate *)chooseFavorite:(Album *)i
{
     NSPredicate * result=nil ;
    result=[NSPredicate predicateWithFormat:@"isFavorite==%@",[NSNumber numberWithBool:YES]];
    return result;
}
-(NSPredicate*) ruleFormation:(Album *)i {
   
    NSPredicate *pre=nil;
    pre=[NSPredicate predicateWithFormat:@"isprotected==%@||isprotected=nil",[NSNumber numberWithBool:NO]];
    if([i chooseType]!=nil&&![[i chooseType]isEqualToString:@"All"] )
    {
         pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self chooseRule:i],nil]];
    }
    if([[i isFavorite] boolValue])
    {
         pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self chooseFavorite:i],nil]];
    }
    if ([i conPeopleRule]!=nil) {
        if(pre!=nil)
        {
         pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self parsePeopleRule:[i conPeopleRule]], nil]];
        }
        else
        {
            pre=[self parsePeopleRule:[i conPeopleRule]];
            
        }
    }
    if ([i conDateRule]!=nil)  {
        if(pre!=nil)
       {
        pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self parseDateRule:[i conDateRule]], nil]];
        }
       else
        {
           pre=[self parseDateRule:[i conDateRule]];
        }
    }
    if ([i conEventRule]!=nil) {
        NSPredicate * tmpEventPre=nil;
        NSMutableArray * tmpEventPreArray=[[NSMutableArray alloc]init] ;
        [tmpEventPreArray removeAllObjects];
        NSMutableSet *tmpEvent = [i valueForKey:@"conEventRule"];
        if ([tmpEvent count]>0) {
            for (EventRule * e in tmpEvent ) {
                [tmpEventPreArray addObject:[self parseEventRule:e]]; 
            }
            tmpEventPre=[NSCompoundPredicate orPredicateWithSubpredicates:tmpEventPreArray];
            pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,tmpEventPre, nil]]; 
        }
    }
    if ([i conAssetRule]!=nil) {
        NSPredicate * tmpAssetPre=nil;
        NSMutableSet *tmpAsset=[i valueForKey:@"conAssetRule"];
        if ([tmpAsset count]>0) {
        
        
            for (AssetRule *a in tmpAsset) {
                if ([a opCode]==@"INCLUDE") {
                
                    tmpAssetPre=[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:tmpAssetPre,[self parseAssetRule:a], nil]];
                }else {
                
                    tmpAssetPre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:tmpAssetPre,[self parseAssetRule:a], nil]]; 
                
                } 
            }
            pre=[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,tmpAssetPre, nil]];
        }
    }
    
    return pre;

}
    
    
-(NSMutableArray*) getAlbumList{    
       return assetsBook;
}
-(AmptsAlbum *) getAlbum:(NSUInteger)index{
    return (AmptsAlbum*)[assetsBook objectAtIndex:index];
}
-(NSInteger) getAlbumCount{
    return  [assetsBook count];
}
-(ALAsset*) getAsset:(NSString *)u {
    return [deviceAssets getAsset: u];
}

@end
