//
//  PlaylistDetailController.h
//  PhotoApp
//
//  Created by Andy on 11/3/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AlbumController.h"
#define INCLUDE     @"INCLUDE"
#define EXCLUDE  @"Exclude"
#define OPTIONAL @"Optional"
#define Rules    @"Rules"
#import "AmptsPhotoCoreData.h"
#import "Album.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
@class PhotoAppDelegate;
@class DBOperation;
@interface PlaylistDetailController : UIViewController<UITableViewDelegate,UITableViewDataSource,MPMediaPickerControllerDelegate,UITextFieldDelegate> {
    PhotoAppDelegate * appDelegate;
    //NSMutableArray *people;
    AmptsPhotoCoreData * coreData;
    Album *bum;
    Album *al;
    NSMutableArray *list;
    PeopleRule *pr1;
    NSMutableArray *nameList;
   // PeopleRuleDetail*prd1;
    BOOL keybord;
    
    UITableView *listTable;
    UITableViewCell *textFieldCell;
    UITableViewCell *switchCell;
    UITableViewCell *tranCell;
    UITableViewCell *musicCell;
    UITableViewCell *PeopleRuleCell;
    UITableViewCell *SortCell;
    UITableViewCell *OrderCell;
    UITableViewCell *DateRangeCell;
    UITextField *startText;
    UITextField *stopText;
    UIButton *AddButton1;
    UIButton *AddButton2;
    
    
    UILabel *tranLabel;
    UILabel *musicLabel;
    UITextField *textField;
    UISwitch *mySwitch;
    UIImage *selectImg;
    UIImage *unselectImg;
    UISegmentedControl *PeopleSeg;
    
    NSMutableArray *userNames;
    NSMutableArray *selectedIndexPaths;
    UILabel *state;
    BOOL mySwc;
    NSString *listName;
    NSString *Transtion;
    NSString *a;
    DBOperation *dataBase;
    AlbumController *album;
    NSMutableArray *playrules_idList;
    NSMutableArray *playIdList;
    NSMutableArray *orderList;
    UIButton *stateButton;
    NSMutableArray *photos;
    int key;
}

@property(nonatomic,retain)Album *bum;
@property(nonatomic,retain)Album *al;
@property(nonatomic,retain)PhotoAppDelegate *appDelegate;
@property(nonatomic,retain)AmptsPhotoCoreData *coreData;
@property(nonatomic,retain)NSMutableArray *list;
@property(nonatomic,retain)NSMutableArray *nameList;

@property(nonatomic,retain)IBOutlet UITableView *listTable;
@property(nonatomic,retain)IBOutlet UITableViewCell *textFieldCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *switchCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *tranCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *musicCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *PeopleRuleCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *SortCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *OrderCell;
@property(nonatomic,retain)IBOutlet UITableViewCell *DateRangeCell;



@property(nonatomic,retain)IBOutlet UILabel *tranLabel;
@property(nonatomic,retain)IBOutlet UILabel *musicLabel;
@property(nonatomic,retain)IBOutlet UITextField *textField;
@property(nonatomic,retain)IBOutlet UISwitch *mySwitch;
@property(nonatomic,retain)IBOutlet UILabel *state;
@property(nonatomic,retain)IBOutlet UITextField *startText;
@property(nonatomic,retain)IBOutlet UITextField *stopText;


@property(nonatomic,retain)IBOutlet UISegmentedControl *PeopleSeg;
@property(nonatomic,retain)NSMutableArray *photos;
@property(nonatomic,retain)NSMutableArray *selectedIndexPaths;
@property(nonatomic,retain)NSMutableArray *userNames;
@property(nonatomic,assign)BOOL mySwc;
@property(nonatomic,retain)NSString *listName;
@property(nonatomic,retain)NSString *Transtion;
@property(nonatomic,retain)NSString *a;
@property(nonatomic,retain)NSMutableArray *playrules_idList;
@property(nonatomic,retain)NSMutableArray *playIdList;
@property(nonatomic,retain)NSMutableArray *orderList;
@property(nonatomic,retain)UIButton *stateButton;
-(IBAction)hideKeyBoard:(id)sender;
-(IBAction)updateTable:(id)sender;
-(IBAction)resetAll;
-(IBAction)PeopleRuleButton;
-(IBAction)AddButton1;
-(IBAction)AddButton2;
-(IBAction)PeopleRuleButton;
-(UIButton *)getStateButton;
//-(void)insert:(NSInteger)Row playId:(int)playId;
-(void)deletes:(NSInteger)Row playId:(int)playId;
-(void)insert:(NSInteger)Row rule:(NSString *)rule;
-(void)update:(NSInteger)Row rule:(NSString *)rule;
-(void)addPlay;
-(void)changeDate:(NSNotification *)note;
@end
