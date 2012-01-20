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
@implementation AlbumDataSource
@synthesize coreData,deviceAssets,assetsBook,opQueue;
@synthesize nav;

-(id) initWithAppName: (NSString *)app navigationController:(UINavigationController *)navigationController{
   self= [super init];
    self.nav = navigationController;
    
    coreData=[[AmptsPhotoCoreData alloc]initWithAppName:app];
    /*
     assetsBook initialization
     */
    
    assetsBook=[[NSMutableArray alloc]init]; 
    
    /*
     
     get the device access list
     
     */
    opQueue=[[NSOperationQueue alloc]init];
 
    
       
    [self syncAssetwithDataSource];

    
    return self;
}
-(void) syncAssetwithDataSource {
    [opQueue cancelAllOperations];    


    deviceAssets=[[OnDeviceAssets alloc]init];

   // [self testDataSource];
    NSInvocationOperation * syncData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(syncDataSource) object:nil];
    [syncData addDependency:deviceAssets];
   
    NSInvocationOperation * refreshData=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(refreshDataSource) object:nil];
    [refreshData addDependency:syncData];
    [opQueue addOperation:deviceAssets];
    [opQueue addOperation:syncData];
    [opQueue addOperation:refreshData];
  // [self refreshDataSource];
    
 
}

-(void) syncDataSource {
    /*
     
     get All the on device url
     */

    NSArray *urlList =[[deviceAssets deviceAssetsList]allKeys];


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
        NSString * strDate=[[[[alAsset defaultRepresentation]metadata]valueForKey:@"{Exif}"]valueForKey:@"DateTimeOriginal"];
        NSLog(@"strdate:%@",strDate);
        NSDateFormatter * dateFormat=[[NSDateFormatter alloc]init];
        newAsset.date=[dateFormat dateFromString:strDate];
        NSLog(@"newAsset.date:%@",newAsset.date);    
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *newDateString = [outputFormatter stringFromDate:newAsset.date];
        NSLog(@"DATE:%@",newDateString);
        newAsset.latitude=[NSNumber numberWithDouble:0.0];
        newAsset.longitude=[NSNumber numberWithDouble:0.0];
        newAsset.numOfLike=[NSNumber numberWithInt:0];
        newAsset.numPeopleTag=[NSNumber numberWithInt:0];
    }

    [coreData saveContext];
        
}

-(void) refreshDataSource {
    NSMutableArray* tmp=nil;
    NSPredicate * pre=nil;
    
    // Clear AssetsBook
    [assetsBook removeAllObjects];
    AmptsAlbum *tmpAlbum=nil;
    
    // Add All People Entry
    
    tmpAlbum=[[AmptsAlbum alloc]init];
    tmpAlbum.name=@"ALL";
    tmpAlbum.alblumId=nil;
    tmpAlbum.assetsList=[self simpleQuery:@"Asset" predicate:nil sortField:nil sortOrder:YES];
    tmpAlbum.num=[tmpAlbum.assetsList count];
   /* NSLog(@"Asset Fetched: %@", tmpAlbum.assetsList);
    for (Asset *a in tmpAlbum.assetsList) {
        NSLog(@"Asset URL: %@", a.url);
    }*/
    [assetsBook addObject:tmpAlbum];

    
    //Add Untag People Entry
    
    tmpAlbum=[[AmptsAlbum alloc]init];
    tmpAlbum.name=@"Untag";
    tmpAlbum.alblumId=nil;
    pre=[NSPredicate predicateWithFormat:@"numPeopleTag == 0"];
    tmpAlbum.assetsList=[self simpleQuery:@"Asset" predicate:pre sortField:nil sortOrder:YES];
    tmpAlbum.num=[tmpAlbum.assetsList count];
    [assetsBook addObject:tmpAlbum];


    
    tmp=[self simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    //NSLog(@"Number of Album :%d",[tmp count]);
    for(Album* i in tmp ) {
        AmptsAlbum * album=[[AmptsAlbum alloc]init];
        album.name=[i name];
        album.alblumId=[i objectID];
        pre=[self ruleFormation:i];
        //NSLog(@"Predicate : %@",pre);
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
                //NSLog(@"Exclude predicate : %d , %@",[excludePeople count],pre );
            }
        }
        album.num=[album.assetsList count];
       // NSLog(@"Album %@ : %d",album.name,album.num);
        for (Asset* tmpAsset in    album.assetsList) {
            //NSLog(@"Photo contains: %@",tmpAsset.url);
        }
        [assetsBook addObject:album];

    }
   // NSLog(@"finished prepare data");
    [self performSelectorOnMainThread:@selector(playlistAlbum) withObject:nil waitUntilDone:YES];
}

-(void)playlistAlbum{
    PlaylistRootViewController *root = (PlaylistRootViewController*)self.nav;
    [root.activityView stopAnimating];
    AlbumController *al = [[AlbumController alloc]initWithNibName:@"AlbumController" bundle:[NSBundle mainBundle]];
    [root pushViewController:al animated:NO];
    [al release];
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
    NSPredicate* result =nil;
    if ([rule opCode]==@"INCLUDE") {
        result=[NSPredicate predicateWithFormat:@"self.date BETWEEN %@",[NSArray arrayWithObjects:[rule startDate],[rule stopDate],nil]];
    } else {
                result=[NSPredicate predicateWithFormat:@"NONE self.date  BETWEEN %@",[NSArray arrayWithObjects:[rule startDate],[rule stopDate],nil]];
    }
    return result; 
}
-(NSPredicate*) parseEventRule:(EventRule *)rule {
    NSPredicate * result=nil ;
    if([rule opCode]==@"INCLUDE") {
        result=[NSPredicate predicateWithFormat:@"conEvent==%@",[rule conEvent]];
    }else {
           result=[NSPredicate predicateWithFormat:@"conEvent!=%@",[rule conEvent]];          
    }
    return result;
}
-(NSPredicate *) parseAssetRule:(AssetRule *)rule {
    NSPredicate * result=nil ;
    if([rule opCode]==@"INCLUDE") {
        result=[NSPredicate predicateWithFormat:@"self==%@",[rule conAsset]];
    }else {
        result=[NSPredicate predicateWithFormat:@"self!=%@",[rule conAsset]];          
    }
    return result;
   
}
-(NSPredicate*) ruleFormation:(Album *)i {
   
    NSPredicate *pre=nil;

    /*
     People Rules or the Face Rules are parsed in here
     
     */
    
    if ([i conPeopleRule]!=nil) {
        
        pre=[self parsePeopleRule:[i conPeopleRule]];
    }
    
    
    /*
     
     Date Rules are parsed in here
     
     */
    if ([i conDateRule]!=nil)  {
        pre=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pre,[self parseDateRule:[i conDateRule]], nil]];
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
}

@end