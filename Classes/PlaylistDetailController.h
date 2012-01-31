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
#import "AlbumDataSource.h"
@class PhotoAppDelegate;
@interface PlaylistDetailController : UIViewController<UITableViewDelegate,UITableViewDataSource,MPMediaPickerControllerDelegate,UITextFieldDelegate> {
    PhotoAppDelegate * appDelegate;
    AmptsPhotoCoreData * coreData;
    AlbumDataSource *AL;
    Album *bum;
    Album *al;
    NSMutableArray *list;
    PeopleRule *pr1;
    NSMutableArray *nameList;
    BOOL keybord;
    BOOL bu;
    
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
    NSString *Transtion;
    AlbumController *album;
    NSMutableArray *playrules_idList;
    UIButton *stateButton;
    int key;
}

@property(nonatomic,strong)Album *bum;
@property(nonatomic,strong)Album *al;
@property(nonatomic,strong)PhotoAppDelegate *appDelegate;
@property(nonatomic,strong)AmptsPhotoCoreData *coreData;
@property(nonatomic,strong)NSMutableArray *list;
@property(nonatomic,strong)NSMutableArray *nameList;

@property(nonatomic,strong)IBOutlet UITableView *listTable;
@property(nonatomic,strong)IBOutlet UITableViewCell *textFieldCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *switchCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *tranCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *musicCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *PeopleRuleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *SortCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *OrderCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *DateRangeCell;



@property(nonatomic,strong)IBOutlet UILabel *tranLabel;
@property(nonatomic,strong)IBOutlet UILabel *musicLabel;
@property(nonatomic,strong)IBOutlet UITextField *textField;
@property(nonatomic,strong)IBOutlet UISwitch *mySwitch;
@property(nonatomic,strong)IBOutlet UILabel *state;
@property(nonatomic,strong)IBOutlet UITextField *startText;
@property(nonatomic,strong)IBOutlet UITextField *stopText;


@property(nonatomic,strong)IBOutlet UISegmentedControl *PeopleSeg;
@property(nonatomic,strong)NSMutableArray *selectedIndexPaths;
@property(nonatomic,strong)NSString *Transtion;
@property(nonatomic,strong)UIButton *stateButton;
-(IBAction)hideKeyBoard:(id)sender;
-(IBAction)updateTable:(id)sender;
-(IBAction)resetAll;
-(IBAction)PeopleRuleButton;
-(IBAction)AddButton1;
-(IBAction)AddButton2;
-(IBAction)PeopleRuleButton;
-(UIButton *)getStateButton;
-(void)insert:(NSInteger)Row rule:(NSString *)rule;
-(void)update:(NSInteger)Row rule:(NSString *)rule;
-(void)addPlay;
-(void)changeDate:(NSNotification *)note;
@end
