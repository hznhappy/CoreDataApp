//
//  PlaylistRootViewController.h
//  PhotoApp
//
//  Created by Andy on 12/1/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssetTablePicker;

@interface PlaylistRootViewController : UINavigationController {
    UIActivityIndicatorView *activityView;
}

@property (nonatomic,strong)UIActivityIndicatorView *activityView;
@end
