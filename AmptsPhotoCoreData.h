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
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSString * appName;
-(id) initWithAppName:(NSString *)app;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
