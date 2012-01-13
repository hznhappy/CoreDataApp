//
//  AmptsPhotoCoreData.h
//  AmptsPhoto
//
//  Created by Leung Po Chuen on 16/12/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
@interface AmptsPhotoCoreData : NSObject {
    NSString  * appName;
    
}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,retain) NSString * appName;
-(id) initWithAppName:(NSString *)app;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
