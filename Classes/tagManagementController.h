#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AmptsPhotoCoreData.h"
#import "People.h"

@class PhotoAppDelegate;
//select t.id,orserid from usertable t,idtable where t.id=idtable.id order by orserid asc;

@interface tagManagementController :UIViewController <UITableViewDelegate,UITableViewDataSource,ABPeoplePickerNavigationControllerDelegate>

{
    
    PhotoAppDelegate * appDelegate;
    NSMutableArray *people;
    AmptsPhotoCoreData * coreData;
    People *favorate;
    NSMutableArray *result;
    NSMutableArray *IdList;
    
    NSNumber *fid;
    NSString *fname;
    NSString *fcolor;
    NSString *num;
    NSString *selected;	
	UIButton *button;
	NSMutableArray *list;
    UIToolbar *tools;
    NSString *idx; 
    NSString *id1;
    UITableView *tableView;
    BOOL bool1;
    UIBarButtonItem *editButton;
    NSString *bo;
}
@property(nonatomic,retain)IBOutlet UITableView *tableView; 
@property(nonatomic,retain)UIButton *button;
@property(nonatomic,retain)NSMutableArray *IdList;

@property(nonatomic,retain)NSMutableArray *list;
@property(nonatomic,retain)NSMutableArray *people;
@property(nonatomic,retain)NSMutableArray *result;
@property(nonatomic,retain)UIToolbar *tools;
@property(nonatomic,retain)NSString *bo;
@property(nonatomic,retain)People *favorate;
@property(nonatomic,retain)AmptsPhotoCoreData * coreData;
-(IBAction)toggleEdit:(id)sender;
-(IBAction)toggleAdd:(id)sender;
-(void)creatButton;
-(void)creatButton1;
-(void)table;

@end
