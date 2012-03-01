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
#import "Asset.h"

@implementation EventTableView
@synthesize eventsList, eventStore, defaultCalendar, detailViewController;
@synthesize eventsName;
@synthesize detailPage;
-(void)viewDidLoad
{
    app = [[UIApplication sharedApplication] delegate];
    dataSource = app.dataSource;

    
    self.eventStore = [[EKEventStore alloc] init];
    self.eventsList = [[NSMutableArray alloc] initWithArray:0];
    self.eventsName=[[NSMutableArray alloc]init];
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
    if (detailPage) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"setTagToolBar" object:nil];
    }
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Table view data source

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar 
- (NSArray *)fetchEventsForToday {
    NSMutableArray *events=[[NSMutableArray alloc]init];
	for(int i=0;i<[eventsName count];i++)
    {
        Event *eve=[eventsName objectAtIndex:i];
        EKEvent *e=[self.eventStore eventWithIdentifier:eve.identify];
        [events addObject:e];
        
    }
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
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy:MM:dd"];
    Event *e=[eventsName objectAtIndex:indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@",e.name];
	return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];	 
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    if(self.tableView.editing)
    {
	self.detailViewController = [[EKEventViewController alloc] initWithNibName:nil bundle:nil];			
    detailViewController.event = [self.eventsList objectAtIndex:indexPath.row];
	detailViewController.allowsEditing = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else
    {
        Event *e=[eventsName objectAtIndex:indexPath.row];
        if (detailPage) {
            NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:e,@"event",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"addEvent" 
                                                               object:self 
                                                             userInfo:dic1]; 
        }else{
            NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:e.name,@"name",e,@"event",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                           object:self 
                                                         userInfo:dic1]; 
        }
        
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Navigation Controller delegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (viewController == self && self.detailViewController.event.title == NULL) {
		[self.eventsList removeObject:self.detailViewController.event];
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark Add a new event
- (void)addEvent:(id)sender {
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
	addController.eventStore = self.eventStore;
	[self presentModalViewController:addController animated:YES];
	addController.editViewDelegate = self;
//    EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
//    
//    eventViewController.delegate = self;
//    
//    eventViewController.event = [self.eventsList objectAtIndex:0];
//
//   
//   eventViewController.allowsEditing = YES;
//    
//   [self.navigationController pushViewController:eventViewController animated:YES];
   

}


#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
	switch (action) {
		case EKEventEditViewActionCanceled:
			break;
			
		case EKEventEditViewActionSaved:
			if (self.defaultCalendar ==  thisEvent.calendar) {
				[self.eventsList addObject:thisEvent];
                Event  *e = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
                e.name=[thisEvent title];
                e.startDate=thisEvent.startDate;
                e.endDate=thisEvent.endDate;
                e.identify=thisEvent.eventIdentifier;
                [dataSource.coreData saveContext];
                [self table];

			}
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			[self.tableView reloadData];
			break;
			
		case EKEventEditViewActionDeleted:
			if (self.defaultCalendar ==  thisEvent.calendar) {
				[self.eventsList removeObject:thisEvent];
			}
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			[self.tableView reloadData];
			break;
			
		default:
			break;
	}
	[controller dismissModalViewControllerAnimated:YES];
	
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   
    

    Event *e=[self.eventsName objectAtIndex:indexPath.row];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"conEvent==%@",e];
    NSMutableArray *AS=[dataSource simpleQuery:@"Asset" predicate:p sortField:nil
                                  sortOrder:YES];
    for(int i=0;i<[AS count];i++)
    {
        Asset *a=[AS objectAtIndex:i];
        a.conEvent=nil;
    }
    [dataSource.coreData.managedObjectContext deleteObject:e];
    [self.eventsName removeObjectAtIndex:indexPath.row];
     
    [dataSource.coreData saveContext];
    [self.tableView reloadData];
    
    
}


@end
