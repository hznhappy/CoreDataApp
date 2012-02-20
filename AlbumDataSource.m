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

-(id) initWithAppName: (NSString *)app navigationController:(UINavigationController *)navigationController{
    self= [super init];
    self.nav = navigationController;
    
    coreData=[[AmptsPhotoCoreData alloc]initWithAppName:app];
    /*
     assetsBook initialization
     */
    
    
    
    /*
     
     get the device access list
     
     */
    opQueue=[[NSOperationQueue alloc]init];
 
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(syncAssetwithDataSource) name:@"fetchAssetsFinished" object:nil];
    deviceAssets=[[OnDeviceAssets alloc]init];
    return self;
}
-(void) syncAssetwithDataSource {
    
    [opQueue cancelAllOperations];   

   // [self testDataSource];
    NSInvocationOperation * syncData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(syncDataSource) object:nil];
   
    NSInvocationOperation * refreshData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(refreshDataSource) object:nil];
    [refreshData addDependency:syncData];
    [opQueue addOperation:syncData];
    [opQueue addOperation:refreshData];
  // [self refreshDataSource];
    
 
}

-(void) syncDataSource {
    /*
     
     get All the on device url
     */
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
   
    NSArray *urlList =deviceAssets.urls;
   

    /*
     delete the asset object which are no longer on the device itself 
     */

    NSPredicate * pre= [NSPredicate predicateWithFormat:@"NONE url  IN %@",urlList];
    NSMutableArray *assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil
                                       sortOrder:YES];
    for(Asset * tmpAsset in assetsList) {
        [[coreData managedObjectContext] deleteObject:tmpAsset];
    }
    [coreData saveContext];
    
    
    
    /*
     copy the newly inserted on device asset into the asset entity.
     */
    assetsList=[self simpleQuery:@"Asset" predicate:nil sortField:nil
                
                                       sortOrder:YES];
    NSMutableArray *tmpArray=[[NSMutableArray alloc]init ];
    for(Asset *tmpAsset in assetsList) {
        [tmpArray addObject:[tmpAsset url]];
    }
    NSArray * toBeAdded=nil;
    
    if ([tmpArray count]>0) {
        pre=[NSPredicate predicateWithFormat:@"NOT self IN %@",(NSArray*)tmpArray];
     //   NSLog(@"%@",pre);
        toBeAdded=[urlList filteredArrayUsingPredicate:pre];
    } else {
        toBeAdded=urlList;
    }
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:[coreData managedObjectContext]]; 
    
  
   // NSLog(@"%@",[toBeAdded count]);
    Asset * newAsset=nil;
    for (NSString * str in toBeAdded) {
        ALAsset * alAsset=[[deviceAssets deviceAssetsList]objectForKey:str];
        
        newAsset=[[Asset alloc]initWithEntity:entity insertIntoManagedObjectContext:[coreData managedObjectContext]];
        newAsset.url=[[[alAsset defaultRepresentation]url]description];
      // NSString * strDate=[[[[alAsset defaultRepresentation]metadata]valueForKey:@"{Exif}"]valueForKey:@"DateTimeOriginal"];
       // NSLog(@"strdate:%@",strDate);
      /*  NSString * strDate=[[[[alAsset defaultRepresentation]metadata]valueForKey: @"{TIFF}"]objectForKey:@"DateTime"];
       // NSLog(@"strdate:%@",strDate);
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        //[inputFormatter setLocale:[NSLocale currentLocale]];
        NSTimeZone* timeZone1 = [NSTimeZone timeZoneForSecondsFromGMT:0*3600]; 
       [inputFormatter setTimeZone:timeZone1];
        [inputFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        newAsset.date = [inputFormatter dateFromString:strDate];*/
     //  NSLog(@"date = %@", newAsset.date);
       
        if ([[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ) {
            newAsset.videoType = [NSNumber numberWithBool:YES];
        }else{
            newAsset.videoType = [NSNumber numberWithBool:NO];;
        }
        newAsset.latitude=[NSNumber numberWithDouble:0.0];
        newAsset.longitude=[NSNumber numberWithDouble:0.0];
        newAsset.numOfLike=[NSNumber numberWithInt:0];
        newAsset.numPeopleTag=[NSNumber numberWithInt:0];
    }
    [coreData saveContext];
        
}

-(void) refreshDataSource {
    [self refresh];
   // NSLog(@"finished prepare data");
    [self performSelectorOnMainThread:@selector(playlistAlbum) withObject:nil waitUntilDone:YES];
}
-(void) refresh
{    assetsBook=[[NSMutableArray alloc]init]; 
    favoriteList=[[NSMutableArray alloc]init];
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    [assetsBook removeAllObjects];
    AlbumAll=[[AmptsAlbum alloc]init];
    AlbumAll.name=@"ALL";
    AlbumAll.alblumId=nil;
    NSMutableArray *coreDataAssets = [self simpleQuery:@"Asset" predicate:nil sortField:nil sortOrder:YES];
    
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
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag!=0"];
    NSMutableArray *TageAssets = [self simpleQuery:@"Asset" predicate:pre sortField:nil sortOrder:YES];
    /*for (NSString *u in deviceAssets.urls) {
        for (Asset *as in unTageAssets) {
            if ([as.url isEqualToString:u]) {
                [AlbumUnTAG.assetsList addObject:as];
            }
        }
    }*/
    for (Asset *as in TageAssets)
    {
        [tmpAlbum.assetsList removeObject:as];
    }
    AlbumUnTAG.assetsList=tmpAlbum.assetsList;
    
    AlbumUnTAG.num=[AlbumUnTAG.assetsList count];
    [UIApplication sharedApplication].applicationIconBadgeNumber = AlbumUnTAG.num;
    [assetsBook addObject:AlbumUnTAG];
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    //NSLog(@"Number of Album :%d",[tmp count]);
    for(Album* i in tmp ) {
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        album.object=[i chooseType];
        pre=[self ruleFormation:i];
        if([i.sortOrder boolValue]==YES){
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];//[i sortkey]
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
        album.num=[album.assetsList count];
        NSPredicate *newPre = [NSPredicate predicateWithFormat:@"self in %@",album.assetsList];
        NSArray *array = [((AmptsAlbum*)[assetsBook objectAtIndex:0]).assetsList filteredArrayUsingPredicate:newPre];
        album.assetsList = [NSMutableArray arrayWithArray:array];
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
       // NSString *sort=[NSString stringWithFormat:@"%@",[p listSort]];
        NSArray *Pt=[self simpleQuery:@"PeopleTag" predicate:ptag sortField:nil sortOrder:YES];
        NSMutableArray *WE=[[NSMutableArray alloc]init];
        for(int i=0;i<[Pt count];i++)
        {
            PeopleTag *PT=[Pt objectAtIndex:i];
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
        [WE addObject:PT.conAsset];
    }
    favorite *pop=[[favorite alloc]init];
    pop.firstname=po.firstName;
    pop.lastname=po.lastName;
    pop.assetsList=WE;
    pop.num=[WE count];
    pop.people=po;
    [favoriteList addObject:pop];
    return favoriteList;

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
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
    album.num=[album.assetsList count];
    NSPredicate *newPre = [NSPredicate predicateWithFormat:@"self in %@",album.assetsList];
    NSArray *array = [((AmptsAlbum*)[assetsBook objectAtIndex:0]).assetsList filteredArrayUsingPredicate:newPre];
    album.assetsList = [NSMutableArray arrayWithArray:array];
    
    if(index==-1)
    {
        [assetsBook addObject:album];
    }
    else
    {
        [assetsBook replaceObjectAtIndex:index withObject:album];
    }
   /* NSManagedObjectContext *managedObjectContext=[coreData managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSPredicate *favor = [NSPredicate predicateWithFormat:@"some favorite==%@",[NSNumber numberWithBool:YES]];
    [request setPredicate:favor];
    NSError *error;
    NSMutableArray *parray=[[NSMutableArray alloc]init];
    parray=[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
*/
    //result=[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
   // }
  

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
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag != 0"];
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
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
        }else {
            album.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:NO];
            
        }
        
        pre=[self excludeRuleFormation:i];
        if (pre!=nil) {
            NSMutableArray* excludePeople=[self simpleQuery:@"Asset" predicate:pre sortField:nil  sortOrder:YES];
            if(excludePeople!=nil) {
                [album.assetsList removeObjectsInArray:excludePeople];
            }
        }
        album.num=[album.assetsList count];
        NSPredicate *newPre = [NSPredicate predicateWithFormat:@"self in %@",album.assetsList];
        NSArray *array = [((AmptsAlbum*)[assetsBook objectAtIndex:0]).assetsList filteredArrayUsingPredicate:newPre];
        album.assetsList = [NSMutableArray arrayWithArray:array];
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

    // Define our table/entity to use  
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:coreData.managedObjectContext];   
    // Setup the fetch request  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];
    
    
    // Define the Predicate
    if (pre!=nil) {

        [request setPredicate:pre];
    }
    
    // Define how we will sort the records  

    if (field!=nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:asc];  
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
        [request setSortDescriptors:sortDescriptors];  
        
    }
    // Fetch the records and handle an error  
    NSError *error;  
   // NSLog(@"REQUSEST:%@",request);
    NSMutableArray *mutableFetchResults = [[coreData.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) {  
        // Handle the error.  
        // This is a serious error and should advise the user to restart the application  
    }   
    
    // Save our fetched data to an array  
    
    return mutableFetchResults;
}

-(NSPredicate *)parsePeopleRule:(PeopleRule *)rule {
    NSMutableSet * ruleDetail=[rule mutableSetValueForKey:@"conPeopleRuleDetail"];
    NSPredicate * result=nil;
    NSMutableArray * predicateArray=[[NSMutableArray alloc ]init] ;
    [predicateArray removeAllObjects];
   //NSLog(@"PeopleRuleDetail count: %d",[ruleDetail count]);
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
   // NSLog(@"PeopleRule Predicate: %@",result);
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
    // NSLog(@"PeopleRuleDetail count: %d",[ruleDetail count]);
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
   // NSLog(@"PeopleRule Predicate: %@",result);
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
        if ([rule.datePeriod isEqualToString:@"Last Week"]) {
            [components setDay:-7];
            NSDate *lastWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            NSLog(@"the date is %@ and %@",date,lastWeek);
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastWeek,date];
        }else if ([rule.datePeriod isEqualToString:@"Last Two Weeks"]) {
            [components setDay:-14];
            NSDate *lastTwoWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastTwoWeek,date];
            
        }else if([rule.datePeriod isEqualToString:@"Last Three Weeks"]){
            [components setDay:-21];
            NSDate *lastThreeWeek = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastThreeWeek,date];
        }else if([rule.datePeriod isEqualToString:@"Last Month"]){
            [components setDay:-30];
            NSDate *lastMonth = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastMonth,date];
        }else{
            [components setDay:-90];
            NSDate *lastMonth = [gregorian dateByAddingComponents:components toDate:date options:0];
            result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",lastMonth,date];
        }
    /*if ([[rule opCode] isEqualToString:@"INCLUDE"]) {
      result=[NSPredicate predicateWithFormat:@"some self.date>=%@ and self.date<=%@",[rule startDate],[rule stopDate]];
        // result=[NSPredicate predicateWithFormat:@"some self.date between %@ and %@",[rule startDate],[rule stopDate]];
               //;
           // result=[NSPredicate predicateWithFormat:@"self.date>=%@",[rule startDate]];
        
    } else {
        result=[NSPredicate predicateWithFormat:@"NONE self.date>=%@ and self.date<=%@",[rule startDate],[rule stopDate]];
    }*/
        return result; 
    }
    return nil;
}
-(NSPredicate*) parseEventRule:(EventRule *)rule {
    NSPredicate * result=nil ;
    if([[rule opCode] isEqualToString:@"INCLUDE"]) {
        result=[NSPredicate predicateWithFormat:@"conEvent==%@",[rule conEvent]];
    }else {
           result=[NSPredicate predicateWithFormat:@"conEvent!=%@",[rule conEvent]];          
    }
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
    if([[i chooseType] isEqualToString:@"Photo"]) {
        result=[NSPredicate predicateWithFormat:@"some videoType==%@",[NSNumber numberWithBool:NO]];//videoType = [NSNumber numberWithBool:YES]
    }else {
        result=[NSPredicate predicateWithFormat:@"videoType==%@",[NSNumber numberWithBool:YES]];          
    }
    return result;

}
-(NSPredicate*) ruleFormation:(Album *)i {
   
    NSPredicate *pre=nil;

    /*
     People Rules or the Face Rules are parsed in here
     
     */
    if([i chooseType]!=nil&&![[i chooseType]isEqualToString:@"Photo&Video"] )
    {
         pre=[self chooseRule:i];
    }

    if ([i conPeopleRule]!=nil) {
        
       // pre=[self parsePeopleRule:[i conPeopleRule]];
        if(pre!=nil)
        {
         pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self parsePeopleRule:[i conPeopleRule]], nil]];
        }
        else
        {
            pre=[self parsePeopleRule:[i conPeopleRule]];
            
        }
    }
    
    
    /*
     
     Date Rules are parsed in here
     
     */
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
    
    /*
     
     Event Rules are parsed in here
     */
    
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
    
    /*
     
     Asset Rules are parsed in here
     */
    
    
    if ([i conAssetRule]!=nil) {
        NSPredicate * tmpAssetPre=nil;
        NSMutableSet *tmpAsset=[i valueForKey:@"conAssetRule"];
       // NSLog(@"AssetRule : %d",[tmpAsset count]);
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
/*
-(void) testDataSource {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:[ coreData managedObjectContext]]; 
    People *p=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[coreData managedObjectContext]];
    p.firstName=@"Po Chuen";
    p.lastName=@"Leung";
    p.addressBookId=[NSNumber numberWithInt:12];
    p.colorCode=[NSNumber numberWithInt:111];
    p.favorite=[NSNumber numberWithBool:NO];
    p.inAddressBook=[NSNumber numberWithBool:NO];
    p.listSeq=[NSNumber numberWithInt:35];
    
    
//    People *p1=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    p1.firstName=@"Ka Man";
//    p1.lastName=@"Tong";
//    p1.addressBookId=[NSNumber numberWithInt:13];
//    p1.colorCode=[NSNumber numberWithInt:111];
//    p1.favorite=[NSNumber numberWithBool:NO];
//    p1.inAddressBook=[NSNumber numberWithBool:NO];
//    p1.listSeq=[NSNumber numberWithInt:31];
//    
//    People *p2=[[People alloc]initWithEntity:entity insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    p2.firstName=@"Anthony";
//    p2.lastName=@"Liu";
//    p2.addressBookId=[NSNumber numberWithInt:15];
//    p2.colorCode=[NSNumber numberWithInt:111];
//    p2.favorite=[NSNumber numberWithBool:NO];
//    p2.inAddressBook=[NSNumber numberWithBool:NO];
//    p2.listSeq=[NSNumber numberWithInt:36];
    
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:[ coreData managedObjectContext]]; 
    Album *al=[[Album alloc]initWithEntity:entity1 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    al.name=@"a great Name!";
    al.byCondition=@"numOfLike";
    al.sortOrder=[NSNumber numberWithBool:YES];
    
    
    
    Album *al1=[[Album alloc]initWithEntity:entity1 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    al1.name=@"a long Story!";
    al1.byCondition=@"numOfLike";
    al1.sortOrder=[NSNumber numberWithBool:NO];
//    Album *al2=[[Album alloc]initWithEntity:entity1 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    al2.name=@"a love Story!";
//    al2.byCondition=@"numOfLike";
//    al2.sortOrder=[NSNumber numberWithBool:NO]; 
//    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[ coreData managedObjectContext]]; 
//    Event *e1=[[Event alloc]initWithEntity:entity2 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    e1.name=@"a SUCK EVENT!";
//    Event *e2=[[Event alloc]initWithEntity:entity2 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    e2.name=@"a dumb EVENT!";
    
    NSEntityDescription *entity3 = [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:[ coreData managedObjectContext]]; 
    Asset *a1=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a1.url=@"pc km anthony";
    a1.numPeopleTag=[NSNumber numberWithInt:0];
    Asset *a2=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a2.url=@"pc km";
    a2.numPeopleTag=[NSNumber numberWithInt:0];
    Asset *a3=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a3.url=@"km anthony";
    a3.numPeopleTag=[NSNumber numberWithInt:0];
    Asset *a4=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a4.url=@"pc";
    a4.numPeopleTag=[NSNumber numberWithInt:0];
    Asset *a5=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a5.url=@"anthony";
    a5.numPeopleTag=[NSNumber numberWithInt:0];
    Asset *a6=[[Asset alloc]initWithEntity:entity3 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    a6.url=@"untag";
    a6.numPeopleTag=[NSNumber numberWithInt:0];
    NSEntityDescription *entity4 = [NSEntityDescription entityForName:@"PeopleTag" inManagedObjectContext:[ coreData managedObjectContext]]; 
    
    PeopleTag *pt1=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    pt1.conAsset=a1;
    [a1 addConPeopleTagObject:pt1];
    pt1.conPeople=p;     
    [p addConPeopleTagObject:pt1];
    
    PeopleTag *pt2=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    pt2.conAsset=a2;
    [a2 addConPeopleTagObject:pt2];
    pt2.conPeople=p;     
    [p addConPeopleTagObject:pt2];
    
    PeopleTag *pt3=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    pt3.conAsset=a3;
    [a3 addConPeopleTagObject:pt3];
    pt3.conPeople=p;     
    [p addConPeopleTagObject:pt3];
    
//    PeopleTag *pt4=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt4.conAsset=a4;
//    [a4 addConPeopleTagObject:pt4];
//    pt4.conPeople=p;     
//    [p addConPeopleTagObject:pt4];
//    PeopleTag *pt2=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt2.conAsset=a2;
//    [a2 addConPeopleTagObject:pt2];
//    pt2.conPeople=p1;     
//    [p1 addConPeopleTagObject:pt2];
//    
//    PeopleTag *pt3=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt3.conAsset=a3;
//    [a3 addConPeopleTagObject:pt3];
//    pt3.conPeople=p2;     
//    [p2 addConPeopleTagObject:pt3];
//    
//    PeopleTag *pt4=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt4.conAsset=a1;
//    [a1 addConPeopleTagObject:pt4];
//    pt4.conPeople=p1;     
//    [p1 addConPeopleTagObject:pt4];
//    
//    PeopleTag *pt5=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt5.conAsset=a1;
//    [a1 addConPeopleTagObject:pt5];
//    pt5.conPeople=p2;   
//    [p2 addConPeopleTagObject:pt5];
//    
//    PeopleTag *pt6=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt6.conAsset=a2;
//    [a2 addConPeopleTagObject:pt6];
//    pt6.conPeople=p;     
//    [p addConPeopleTagObject:pt6];
//    PeopleTag *pt7=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt7.conAsset=a3;
//    [a3 addConPeopleTagObject:pt7];
//    pt7.conPeople=p1;
//    [p1 addConPeopleTagObject:pt7];
    
    
    
//    PeopleTag *pt8=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt8.conAsset=a4;
//    [a4 addConPeopleTagObject:pt8];
//    pt8.conPeople=p;     
//    [p addConPeopleTagObject:pt8];
//    PeopleTag *pt9=[[PeopleTag alloc]initWithEntity:entity4 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pt9.conAsset=a5;
//    [a5 addConPeopleTagObject:pt9];
//    pt9.conPeople=p2;
//    [p2 addConPeopleTagObject:pt9];
//    a2.numPeopleTag=[NSNumber numberWithInt:2];
//    a1.numPeopleTag=[NSNumber numberWithInt:3];
//    a3.numPeopleTag=[NSNumber numberWithInt:2];
//    a4.numPeopleTag=[NSNumber numberWithInt:1];
//    a5.numPeopleTag=[NSNumber numberWithInt:1];
//    a1.conEvent=e1;
//    [e1 addConAssetObject:a1];
//    a3.conEvent=e1;
//    [e1 addConAssetObject:a3];
//    a2.conEvent=e2;
//    [e2 addConAssetObject:a2];
//    a4.conEvent=e1;
//    [e1 addConAssetObject:a4];
    NSEntityDescription *entity5 = [NSEntityDescription entityForName:@"PeopleRule" inManagedObjectContext:[ coreData managedObjectContext]]; 
    PeopleRule *pr1=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    pr1.allOrAny=[NSNumber numberWithBool:YES];
    PeopleRule *pr2=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    pr2.allOrAny=[NSNumber numberWithBool:NO];
//    PeopleRule *pr3=[[PeopleRule alloc]initWithEntity:entity5 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    pr3.allOrAny=[NSNumber numberWithBool:YES];
//    
   al.conPeopleRule=pr1;
    pr1.conAlbum=al;
//    
    al1.conPeopleRule=pr2;
    pr2.conAlbum=al1;
//    
//    al2.conPeopleRule=pr3;
//    pr3.conAlbum=al2;
    NSEntityDescription *entity11 = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:[ coreData managedObjectContext]]; 
    Album *al3=[[Album alloc]initWithEntity:entity11 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    al3.name=@"Date!";
    al3.byCondition=@"numOfLike";
    al3.sortOrder=[NSNumber numberWithBool:YES];
    
    
    
    NSEntityDescription *entity51 = [NSEntityDescription entityForName:@"DateRule" inManagedObjectContext:[ coreData managedObjectContext]]; 
    DateRule *d1=[[DateRule alloc]initWithEntity:entity51 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    //[inputFormatter setLocale:[NSLocale currentLocale]];
    [inputFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    d1.startDate= [inputFormatter dateFromString:@"2011:2:1 6:40:23"];
    d1.stopDate= [inputFormatter dateFromString:@"2011:2:1 6:40:23"];
    NSLog(@"DS:%@",d1.startDate);
     NSLog(@"DS:%@",d1.stopDate);
    d1.opCode=@"INCLUDE";
    d1.conAlbum=al3;
    al3.conDateRule=d1;
    

    NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:[ coreData managedObjectContext]]; 
    PeopleRuleDetail*prd1=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    prd1.conPeopleRule=pr1;
    [pr1 addConPeopleRuleDetailObject:prd1];
    prd1.conPeople=p;
    [p addConPeopleRuleDetailObject:prd1];
    prd1.opcode=@"INCLUDE";
    
    
    PeopleRuleDetail*prd2=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
    prd2.conPeopleRule=pr2;
    [pr2 addConPeopleRuleDetailObject:prd2];
    prd2.conPeople=p;
    [p addConPeopleRuleDetailObject:prd2];
    prd2.opcode = @"INCLUDE";
//    [pr1 addConPeopleRuleDetailObject:prd2];
//    prd2.opcode=@"INCLUDE";
//    PeopleRuleDetail*prd3=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    prd3.conPeopleRule=pr1;
//    [pr1 addConPeopleRuleDetailObject:prd3];
//    prd3.conPeople=p2;
//    [p2 addConPeopleRuleDetailObject:prd3];
//    prd3.opcode=@"INCLUDE";
//    PeopleRuleDetail*prd4=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    prd4.conPeopleRule=pr2;
//    [pr2 addConPeopleRuleDetailObject:prd4];
//    prd4.conPeople=p;
//    [p addConPeopleRuleDetailObject:prd4];
//    prd4.opcode=@"INCLUDE";
//    PeopleRuleDetail*prd5=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    prd5.conPeopleRule=pr2;
//    [pr2 addConPeopleRuleDetailObject:prd5];
//    prd5.conPeople=p1;
//    [p1 addConPeopleRuleDetailObject:prd5];
//    prd5.opcode=@"INCLUDE";
//    PeopleRuleDetail*prd6=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    prd6.conPeopleRule=pr1;
//    [pr1 addConPeopleRuleDetailObject:prd6];
//    prd6.conPeople=p2;
//    [p2 addConPeopleRuleDetailObject:prd6];
//    prd6.opcode=@"INCLUDE";  
//  
//    
//    PeopleRuleDetail*prd7=[[PeopleRuleDetail alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[coreData managedObjectContext]];
//    prd7.conPeopleRule=pr3;
//    [pr3 addConPeopleRuleDetailObject:prd7];
//    prd7.conPeople=p;
//    [p addConPeopleRuleDetailObject:prd7];
//    prd7.opcode=@"EXCLUDE";     
    [coreData saveContext];   
}*/

@end
