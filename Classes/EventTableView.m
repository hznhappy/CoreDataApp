//
//  EventTableView.m
//  PhotoApp
//
//  Created by  on 12-2-24.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "EventTableView.h"
#import "PhotoAppDelegate.h"
#import "Event.h"


@implementation EventTableView
@synthesize eventsList, eventStore, defaultCalendar, detailViewController;
@synthesize eventsName;
-(void)viewDidLoad
{
    app = [[UIApplication sharedApplication] delegate];
    dataSource = app.dataSource;

    
    self.eventStore = [[EKEventStore alloc] init];
    self.eventsList = [[NSMutableArray alloc] initWithArray:0];
    self.eventsName=[[NSMutableArray alloc]init];
	// Get the default calendar from store.
	self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];

    [self table];

    [self.navigationItem setTitle:@"Event"];
    NSString *a=NSLocalizedString(@"Back", @"button");
    NSString *b=NSLocalizedString(@"Edit", @"button");
    UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
    self.navigationItem.leftBarButtonItem=BackButton;
    editButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    editButton.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem=editButton;
   [self.eventsList addObjectsFromArray:[self fetchEventsForToday]];
    //date = [NSEntityDescription insertNewObjectForEntityForName:@"DateRule" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
}
-(void)table
{
    self.eventsName=[dataSource simpleQuery:@"Event" predicate:nil sortField:nil
                                  sortOrder:YES];
    [self.tableView reloadData];
}
-(void)toggleback
{
    
    [self dismissModalViewControllerAnimated:YES];
}
-(IBAction)toggleEdit:(id)sender
{ 
    NSString *a=NSLocalizedString(@"Edit", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
    NSString *d=NSLocalizedString(@"Back", @"button");
    if([editButton.title isEqualToString:a])
    {
        editButton.style=UIBarButtonItemStyleDone;         
        editButton.title=b;
        self.tableView.editing=NO;
        UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
        addButon.style = UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = addButon;
    }
    else
    {
        editButton.style=UIBarButtonItemStyleBordered;
        editButton.title=a;
        self.tableView.editing=YES;
        UIBarButtonItem *BackButton=[[UIBarButtonItem alloc]initWithTitle:d style:UIBarButtonItemStyleBordered target:self action:@selector(toggleback)];
        self.navigationItem.leftBarButtonItem=BackButton;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.tableView.allowsSelectionDuringEditing=YES;
    
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
//}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Table view data source

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar 
- (NSArray *)fetchEventsForToday {
	
	NSDate *startDate = [NSDate date];
	
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	
	// Create the predicate. Pass it the default calendar.
	NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
	NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                                    calendars:calendarArray]; 
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    
	return events;
}


#pragma mark -
#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return eventsList.count;
    return eventsName.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	// Add disclosure triangle to cell
	UITableViewCellAccessoryType editableCellAccessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier];
	}
	
	cell.accessoryType = editableCellAccessoryType;
    
	// Get the event at the row selected and display it's title
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy:MM:dd"];
    //NSString *startDate = [outputFormatter stringFromDate:[[self.eventsList objectAtIndex:indexPath.row] startDate]];
   // NSString *endDate = [outputFormatter stringFromDate:[[self.eventsList objectAtIndex:indexPath.row] endDate]];
	//cell.textLabel.text =[NSString stringWithFormat:@"%@ (%@,%@)",[[self.eventsList objectAtIndex:indexPath.row] title],startDate,endDate];
    Event *e=[eventsName objectAtIndex:indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@",e.name];
    
   // cell.textLabel.text =[NSString stringWithFormat:@"%@",[[self.eventsList objectAtIndex:indexPath.row] title]]; 
	return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];	 
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	// Upon selecting an event, create an EKEventViewController to display the event.
    if(self.tableView.editing)
    {
	/*self.detailViewController = [[EKEventViewController alloc] initWithNibName:nil bundle:nil];			
	detailViewController.event = [self.eventsList objectAtIndex:indexPath.row];
	
	// Allow event editing.
	detailViewController.allowsEditing = YES;
	
	//	Push detailViewController onto the navigation controller stack
	//	If the underlying event gets deleted, detailViewController will remove itself from
	//	the stack and clear its event property.
	[self.navigationController pushViewController:detailViewController animated:YES];*/
    }
    else
    {
       /* NSPredicate * pre1= [NSPredicate predicateWithFormat:@"name==%@",[[self.eventsList objectAtIndex:indexPath.row] title]];
        NSMutableArray *EventList=[dataSource simpleQuery:@"Event" predicate:pre1 sortField:nil
                                           sortOrder:YES];
        if([EventList count]==0)
        {
            NSLog(@"add");
           Event  *e = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
            e.name=[[self.eventsList objectAtIndex:indexPath.row] title];
            [dataSource.coreData saveContext];
            NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:[[self.eventsList objectAtIndex:indexPath.row] title],@"name",e,@"event",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                               object:self 
                                                             userInfo:dic1]; 
        }
        else
        {
            NSLog(@"Choose");
            Event *ev=[EventList objectAtIndex:0];
            NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:[[self.eventsList objectAtIndex:indexPath.row] title],@"name",ev,@"event",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                               object:self 
                                                             userInfo:dic1]; 
        }*/
        Event *e=[eventsName objectAtIndex:indexPath.row];
        NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:e.name,@"name",e,@"event",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                           object:self 
                                                         userInfo:dic1]; 
        
      [self dismissModalViewControllerAnimated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Navigation Controller delegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	// if we are navigating back to the rootViewController, and the detailViewController's event
	// has been deleted -  will title being NULL, then remove the events from the eventsList
	// and reload the table view. This takes care of reloading the table view after adding an event too.
	if (viewController == self && self.detailViewController.event.title == NULL) {
		[self.eventsList removeObject:self.detailViewController.event];
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark Add a new event

// If event is nil, a new event is created and added to the specified event store. New events are 
// added to the default calendar. An exception is raised if set to an event that is not in the 
// specified event store.
- (void)addEvent:(id)sender {
	// When add button is pushed, create an EKEventEditViewController to display the event.
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
	
	// set the addController's event store to the current event store.
	addController.eventStore = self.eventStore;
	
	// present EventsAddViewController as a modal view controller
	[self presentModalViewController:addController animated:YES];
	
	addController.editViewDelegate = self;
}


#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
    //NSLog(@"event:%@",thisEvent.)
	
	switch (action) {
		case EKEventEditViewActionCanceled:
			// Edit action canceled, do nothing. 
			break;
			
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store, 
			// and reload table view.
			// If the new event is being added to the default calendar, then update its 
			// eventsList.
			if (self.defaultCalendar ==  thisEvent.calendar) {
				[self.eventsList addObject:thisEvent];
                Event  *e = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
                e.name=[thisEvent title];
                NSLog(@"E.name:%@",e.name);
                [dataSource.coreData saveContext];
                [self table];

			}
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			[self.tableView reloadData];
			break;
			
		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store, 
			// and reload table view.
			// If deleting an event from the currenly default calendar, then update its 
			// eventsList.
			if (self.defaultCalendar ==  thisEvent.calendar) {
				[self.eventsList removeObject:thisEvent];
			}
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			[self.tableView reloadData];
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller dismissModalViewControllerAnimated:YES];
	
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   
    
    //[self.eventsList removeObjectAtIndex:indexPath.row];
    
    //[self.tableView reloadData];
    
    
}


@end
