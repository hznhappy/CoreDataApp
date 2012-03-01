//
//  eventView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumDataSource.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "Event.h"
#import "AlbumDataSource.h"
@class PhotoAppDelegate;
@interface eventView : UIViewController<UITableViewDataSource,UITableViewDelegate,EKEventEditViewDelegate>
{
    NSMutableArray *eventList;
    PhotoAppDelegate *app;
    AlbumDataSource *dataSource; 
    EKEventViewController *detailViewController;
	EKEventStore *eventStore;
	EKCalendar *defaultCalendar;
    NSMutableArray *eventsList;
    NSMutableArray *eventsName;
    Event *event;
    UITableView *tableView;
}
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSMutableArray *eventsList;
@property (nonatomic, strong) EKEventViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray *eventsName;
@property (nonatomic, strong)IBOutlet  UITableView *tableView;
- (NSArray *) fetchEventsForToday;
- (IBAction) addEvent:(id)sender;
-(void)table;

@end
