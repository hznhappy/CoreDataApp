//
//   PhotoAppDelegate.h
//   PhotoApp
//
//  Created by Andy .
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumDataSource.h"
@interface PhotoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *rootViewController;
    AlbumDataSource *dataSource;
}
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *rootViewController;
@property (nonatomic, strong) AlbumDataSource *dataSource;
@end
@interface UITabBarController (MyApp)
@end

@interface UINavigationController (MyApp)
@end
