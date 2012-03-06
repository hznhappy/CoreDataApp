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
    //PeopleRule *pr1;
    NSMutableArray *nameList;
    NSArray *dateList;
    BOOL keybord;
    BOOL bu;
     
    MPMusicPlayerController *musicPlayer;
    UITableView *listTable;
    
    
    UITableViewCell *PlayNameCell;
    UITableViewCell *TypeCell;
    UITableViewCell *MyfavoriteCell;
    UITableViewCell *PeosonCell;
    UITableViewCell *EventCell;
    UITableViewCell *SetDateCell;
    UITableViewCell *SortOrderCell;
    UITableViewCell *EffectCell;
    UILabel *TypeLabel;
    UILabel *PersonLabel;
    UILabel *DateLabel;
    UILabel *SortOrder;
    UILabel *EventLabel;
    
    UISwitch *favoriteSW;
    UITextField *textField;
    NSMutableArray *userNames;
    NSMutableArray *selectedIndexPaths;
    NSMutableArray *IdList;
    UILabel *state;
    BOOL mySwc;
    BOOL sortSwc;
    AlbumController *album;
    NSMutableArray *playrules_idList;
    UIButton *chooseButton;
    NSString *playName;
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

@property(nonatomic,strong)IBOutlet UITableViewCell *PlayNameCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *TypeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *MyfavoriteCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *PeosonCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *EventCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *SetDateCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *SortOrderCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *EffectCell;
@property(nonatomic,strong)IBOutlet UILabel *TypeLabel;
@property(nonatomic,strong)IBOutlet UILabel *PersonLabel;
@property(nonatomic,strong)IBOutlet UILabel *DateLabel;
@property(nonatomic,strong)IBOutlet UILabel *SortOrder;
@property(nonatomic,strong)IBOutlet UILabel *EventLabel;
@property(nonatomic,strong)IBOutlet UISwitch *favoriteSW;

//@property(nonatomic,strong)IBOutlet UITableViewCell *chooseCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *textFieldCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *switchCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *tranCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *musicCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *PeopleRuleCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *SortCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *OrderCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *dateRule;
//@property(nonatomic,strong)IBOutlet UITableViewCell *AddPeopleCell;
//@property(nonatomic,strong)IBOutlet UITableViewCell *sortOrderCell;
//@property(nonatomic,strong)IBOutlet UISwitch *sortSw;
//@property(nonatomic,strong)IBOutlet UILabel *tranLabel;
//@property(nonatomic,strong)IBOutlet UILabel *musicLabel;
@property(nonatomic,strong)IBOutlet UITextField *textField;
//@property(nonatomic,strong)IBOutlet UISwitch *mySwitch;
//@property(nonatomic,strong)IBOutlet UILabel *state;
//@property(nonatomic,strong)IBOutlet UIPickerView *pickerView;
//@property(nonatomic,strong)IBOutlet UITableViewCell *myFavoriteCell;
//

@property(nonatomic,strong)NSMutableArray *selectedIndexPaths;
@property(nonatomic,strong)NSString *Transtion;
//@property(nonatomic,strong)UIButton *stateButton;
//@property(nonatomic,strong)UIButton *chooseButton;
//@property(nonatomic,strong)UIButton *sortButton;
//@property(nonatomic,strong)UIButton *orderButton;
//@property(nonatomic,strong)UIButton *peopleRuleButton;
-(IBAction)hideKeyBoard:(id)sender;
-(IBAction)updateTable:(id)sender;
//-(IBAction)resetAll;
-(IBAction)AddContacts;
//-(IBAction)upSort:(id)sender;
//-(UIButton *)getStateButton;
//-(IBAction)playAlbumPhotos:(id)sender;
-(void)insert:(NSInteger)Row rule:(NSString *)rule;
-(void)update:(NSInteger)Row rule:(NSString *)rule;
-(void)addPlay;
-(void)album;
//-(void)setSort;
//-(void)setOrder;
-(void)table;
-(UIButton *)chooseButton;
-(IBAction)text;

-(void)insert:(NSInteger)Row rule:(NSString *)rule;
-(void)changeType:(NSNotification *)note;
-(void)changePeople:(NSNotification *)note;
-(void)changeDate:(NSNotification *)note;
-(void)personLabel:(NSMutableArray *)person;
-(void)eventLabel:(NSMutableArray *)event;
-(IBAction)chooseMyfavorite:(id)sender;

@end
