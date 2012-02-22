#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AmptsPhotoCoreData.h"
#import "People.h"
#import "AlbumDataSource.h"

@class PhotoAppDelegate;
//select t.id,orserid from usertable t,idtable where t.id=idtable.id order by orserid asc;

@interface TagManagementController :UIViewController <UITableViewDelegate,UITableViewDataSource,UINavigationBarDelegate,ABPeoplePickerNavigationControllerDelegate>

{
    
    PhotoAppDelegate * appDelegate;
    AmptsPhotoCoreData * coreData;
    AlbumDataSource *datasource;
    People *favorate;
    People *favorate1;
    NSMutableArray *result;
    NSMutableArray *IdList;
    NSMutableArray *as;
    NSMutableArray *peopleList;
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
    BOOL choose;
    UIBarButtonItem *editButton;
    NSString *bo;
    NSMutableArray *choosePeople;
    NSInteger index;
}
@property(nonatomic,strong)IBOutlet UITableView *tableView; 
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)NSMutableArray *IdList;
@property(nonatomic,strong)NSMutableArray *choosePeople;
@property(nonatomic,strong)NSMutableArray *list;
@property(nonatomic,strong)NSMutableArray *as;
@property(nonatomic,strong)NSMutableArray *result;
@property(nonatomic,strong)NSMutableArray *peopleList;
@property(nonatomic,strong)UIToolbar *tools;
@property(nonatomic,strong)NSString *bo;
@property(nonatomic,strong)People *favorate;
@property(nonatomic,strong)People *favorate1;
@property(nonatomic,strong)AmptsPhotoCoreData * coreData;
-(IBAction)toggleEdit:(id)sender;
-(IBAction)toggleAdd:(id)sender;
-(void)creatButton;
-(void)creatButton1;
-(void)table;
-(void)deletePeople:(NSInteger)Index;
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation;
@end
