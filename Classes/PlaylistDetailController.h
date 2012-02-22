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
#define PhotoVideo @"Photo&Video"
#define Photo @"Photo"
#define Video @"Video"
#define OPTIONAL @"Optional"
#define Rules    @"Rules"
#import "AmptsPhotoCoreData.h"
#import "Album.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
#import "AlbumDataSource.h"
#import "DateRule.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@class PhotoAppDelegate;
@interface PlaylistDetailController : UIViewController<UITableViewDelegate,UITableViewDataSource,MPMediaPickerControllerDelegate,UITextFieldDelegate
,ABPeoplePickerNavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource> {
    PhotoAppDelegate * appDelegate;
    AmptsPhotoCoreData * coreData;
    AlbumDataSource *AL;
    Album *bum;
    DateRule *date;
    NSMutableArray *list;
    PeopleRule *pr1;
    NSMutableArray *nameList;
    NSArray *dateList;
    BOOL keybord;
    BOOL bu;
     
    MPMusicPlayerController *musicPlayer;
    UITableView *listTable;
    UITableViewCell *textFieldCell;
    UITableViewCell *switchCell;
    UITableViewCell *tranCell;
    UITableViewCell *musicCell;
    UITableViewCell *PeopleRuleCell;
    UITableViewCell *SortCell;
    UITableViewCell *OrderCell;
    UITableViewCell *dateRule;
    UITableViewCell *AddPeopleCell;
    UITableViewCell *sortOrderCell;
    UITableViewCell *chooseCell;
    UIPickerView *pickerView;
    
    UILabel *tranLabel;
    UILabel *musicLabel;
    UITextField *textField;
    UISwitch *mySwitch;
    UIImage *selectImg;
    UIImage *unselectImg;
    UISwitch *sortSw;
    
    NSMutableArray *userNames;
    NSMutableArray *selectedIndexPaths;
    NSMutableArray *IdList;
    UILabel *state;
    BOOL mySwc;
    BOOL sortSwc;
    AlbumController *album;
    NSMutableArray *playrules_idList;
    UIButton *stateButton;
    UIButton *chooseButton;
    UIButton *sortButton;
    UIButton *orderButton;
    UIButton *peopleRuleButton;
    int key;
}

@property(nonatomic,strong)Album *bum;
@property(nonatomic,strong)DateRule *date;
@property(nonatomic,strong)PhotoAppDelegate *appDelegate;
@property(nonatomic,strong)AmptsPhotoCoreData *coreData;
@property(nonatomic,strong)NSMutableArray *list;
@property(nonatomic,strong)NSMutableArray *nameList;
@property(nonatomic,strong)NSMutableArray *IdList;

@property(nonatomic,strong)IBOutlet UITableView *listTable;
@property(nonatomic,strong)IBOutlet UITableViewCell *chooseCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *textFieldCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *switchCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *tranCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *musicCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *PeopleRuleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *SortCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *OrderCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *dateRule;
@property(nonatomic,strong)IBOutlet UITableViewCell *AddPeopleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *sortOrderCell;
@property(nonatomic,strong)IBOutlet UISwitch *sortSw;
@property(nonatomic,strong)IBOutlet UILabel *tranLabel;
@property(nonatomic,strong)IBOutlet UILabel *musicLabel;
@property(nonatomic,strong)IBOutlet UITextField *textField;
@property(nonatomic,strong)IBOutlet UISwitch *mySwitch;
@property(nonatomic,strong)IBOutlet UILabel *state;
@property(nonatomic,strong)IBOutlet UIPickerView *pickerView;
@property(nonatomic,strong)NSMutableArray *selectedIndexPaths;
@property(nonatomic,strong)NSString *Transtion;
@property(nonatomic,strong)UIButton *stateButton;
@property(nonatomic,strong)UIButton *chooseButton;
@property(nonatomic,strong)UIButton *sortButton;
@property(nonatomic,strong)UIButton *orderButton;
@property(nonatomic,strong)UIButton *peopleRuleButton;
-(IBAction)hideKeyBoard:(id)sender;
-(IBAction)updateTable:(id)sender;
-(IBAction)resetAll;
-(IBAction)AddContacts;
-(IBAction)upSort:(id)sender;
-(UIButton *)getStateButton;
-(IBAction)playAlbumPhotos:(id)sender;
-(void)insert:(NSInteger)Row rule:(NSString *)rule;
-(void)update:(NSInteger)Row rule:(NSString *)rule;
-(void)addPlay;
-(void)album;
-(void)setSort;
-(void)setOrder;
-(void)table;

-(IBAction)text;
@end
