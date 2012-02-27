//
//  EventTableView.h
//  PhotoApp
//
//  Created by  on 12-2-24.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "Event.h"
#import "AlbumDataSource.h"
@class PhotoAppDelegate;
@interface EventTableView : UITableViewController<UINavigationBarDelegate, UITableViewDelegate, 
EKEventEditViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIBarButtonItem *editButton;
    EKEventViewController *detailViewController;
	EKEventStore *eventStore;
	EKCalendar *defaultCalendar;
	NSMutableArray *eventsList;
    NSMutableArray *eventsName;
    Event *event;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource;
}
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSMutableArray *eventsList;
@property (nonatomic, strong) EKEventViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray *eventsName;

- (NSArray *) fetchEventsForToday;
- (IBAction) addEvent:(id)sender;
-(void)table;

@end
