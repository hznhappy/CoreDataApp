//
//  eventView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "eventView.h"
#import "PhotoAppDelegate.h"
#import "EventRule.h"
#import "Event.h"
@implementation eventView
@synthesize eventsList, eventStore, defaultCalendar, detailViewController;
@synthesize eventsName;
@synthesize tableView;
@synthesize album;
-(void)viewDidLoad
{
    app = [[UIApplication sharedApplication] delegate];
    dataSource = app.dataSource;
    NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
    ev=[[EventRule alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
    self.eventStore = [[EKEventStore alloc] init];
    self.eventsList = [[NSMutableArray alloc] initWithArray:0];
    self.eventsName=[[NSMutableArray alloc]init];
    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
    [self table];
    [self.navigationItem setTitle:@"Event"];
    UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    addButon.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = addButon;
    [self.eventsList addObjectsFromArray:[self fetchEventsForToday]]; 
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    NSString *b=NSLocalizedString(@"Back", @"title");
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    
}
-(void)back
{
    NSLog(@"back");
    NSMutableArray *eventname=[[NSMutableArray alloc]init];
    for(EventRule *e in album.conEventRule)
    {
        [eventname addObject:e.conEvent.name];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:eventname,@"evename",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeEvent" object:nil userInfo:dictionary];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)table
{
    self.eventsName=[dataSource simpleQuery:@"Event" predicate:nil sortField:nil
                                  sortOrder:YES];
    [self.tableView reloadData];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return eventsList.count;
    return eventsName.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	// Add disclosure triangle to cell
	//UITableViewCellAccessoryType editableCellAccessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
	
	UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
	}
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	//cell.accessoryType = editableCellAccessoryType;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy:MM:dd"];
    Event *e=[eventsName objectAtIndex:indexPath.row];
   // cell.textLabel.text =[NSString stringWithFormat:@"%@",e.name];
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
    name.tag = indexPath.row;
    name.backgroundColor = [UIColor clearColor];
    name.text=e.name;
    [cell.contentView addSubview:name];
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.tag = indexPath.row;
    [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
    selectButton.frame = CGRectMake(10, 11, 30, 30);
    [selectButton setImage:unselectImg forState:UIControlStateNormal];
    [cell.contentView addSubview:selectButton];
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"conEvent==%@ and conAlbum==%@",e,album];
    NSArray *e1= [dataSource simpleQuery:@"EventRule" predicate:favor sortField:nil sortOrder:YES];
    if(e1.count>0)
    {
         [selectButton setImage:selectImg forState:UIControlStateNormal];
    }
	return cell;
}
//
//- (void)viewWillAppear:(BOOL)animated {
//	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];	 
//}
//
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
   
    for (UIButton *button2 in cell.contentView.subviews) {
        
        if ([button2 isKindOfClass:[UIButton class]]) {
            if ([button2.currentImage isEqual:unselectImg]) {
                [button2 setImage:selectImg forState:UIControlStateNormal]; 
                NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
                EventRule *e1=[[EventRule alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
                e1.conEvent=[eventsName objectAtIndex:indexPath.row];
                [album addConEventRuleObject:e1];
                [dataSource.coreData saveContext];
                             
            }
            
            
            else
            {
                [button2 setImage:unselectImg forState:UIControlStateNormal]; 
                NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:managedObjectsContext];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                [request setEntity:entity];
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conEvent==%@ and conAlbum==%@",[eventsName objectAtIndex:indexPath.row],album];
                [request setPredicate:pre];
                NSError *error = nil;
                NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
                EventRule *e0=[A objectAtIndex:0];
                [album removeConEventRuleObject:e0];
                [[eventsName objectAtIndex:indexPath.row] removeConEventRuleObject:e0];
                [dataSource.coreData.managedObjectContext deleteObject:e0];
                [dataSource.coreData saveContext];
            }
        }
    }
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void)setSelectState:(id)sender{
   
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *index = [tableView indexPathForCell:cell];
    NSInteger Row=index.row;
    
    if ([button.currentImage isEqual:selectImg]) {
        [button setImage:unselectImg forState:UIControlStateNormal];
        cell.accessoryView = nil;
        NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:managedObjectsContext];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entity];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conEvent==%@ and conAlbum==%@",[eventsName objectAtIndex:Row],album];
        [request setPredicate:pre];
        NSError *error = nil;
        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
        EventRule *e0=[A objectAtIndex:0];
        [album removeConEventRuleObject:e0];
        [[eventsName objectAtIndex:Row] removeConEventRuleObject:e0];
        [dataSource.coreData.managedObjectContext deleteObject:e0];
        [dataSource.coreData saveContext];  
    }
    else{
        [button setImage:selectImg forState:UIControlStateNormal];
         NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
         EventRule *e1=[[EventRule alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
        e1.conEvent=[eventsName objectAtIndex:Row];
        [album addConEventRuleObject:e1];
        [dataSource.coreData saveContext];
        
    }
    //[self.tableView reloadData];
}


#pragma mark -
#pragma mark Navigation Controller delegate

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (viewController == self && self.detailViewController.event.title == NULL) {
		[self.eventsList removeObject:self.detailViewController.event];
		//[self.tableView reloadData];
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
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{   
//    
//    
//    Event *e=[self.eventsName objectAtIndex:indexPath.row];
//    NSPredicate *p=[NSPredicate predicateWithFormat:@"conEvent==%@",e];
//    NSMutableArray *AS=[dataSource simpleQuery:@"Asset" predicate:p sortField:nil
//                                     sortOrder:YES];
//    for(int i=0;i<[AS count];i++)
//    {
//        //Asset *a=[AS objectAtIndex:i];
//       // a.conEvent=nil;
//    }
//    [dataSource.coreData.managedObjectContext deleteObject:e];
//    [self.eventsName removeObjectAtIndex:indexPath.row];
//    
//    [dataSource.coreData saveContext];
//    [self.tableView reloadData];
//    
//    
//}
//






@end

