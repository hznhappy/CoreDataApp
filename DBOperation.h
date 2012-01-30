//
//  DBOperation.h
//  
//
//  Created by Andy on 9/19/11.
//  Copyright 2011 chinarewards . All rights reserved.
//

#import <Foundation/Foundation.h>
#import<sqlite3.h>
#define UserTable  @"UserTable"
#define idOrder @"idOrder"
#define playIdOrder @"PlayIdOrder"
#define TAG @"TAG"
#define PlayTable @"PlayTable"
#define rules @"rules"
@interface DBOperation : NSObject {
    NSDictionary *dic;
    int tagValue;
    sqlite3 *db;
    NSMutableArray *orderIdList;
    NSMutableArray *tagList;
    NSMutableArray *playTableList;
    NSMutableArray *RulesList;
    NSMutableArray *PassTable;
    NSMutableSet *tag1List;
    NSMutableArray *tagName;
    NSMutableArray *photos;
    NSString *name;
    NSString *Transtion;
}
@property(nonatomic,strong)NSMutableArray *orderIdList;
@property(nonatomic,strong)NSMutableArray *tagList;
@property(nonatomic,strong)NSMutableArray *playTableList;
@property(nonatomic,strong)NSMutableArray *RulesList;
@property(nonatomic,strong)NSMutableSet *tag1List;
@property(nonatomic,strong)NSMutableArray *tagName;
@property(nonatomic,strong)NSMutableArray *photos;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *Transtion;
@property (nonatomic,strong)NSMutableArray *PassTable;
+(DBOperation*)getInstance;
-(void)openDB;
-(void)createTable:(NSString *)sql;
-(void)insertToTable:(NSString *)sql;
-(void)updateTable:(NSString *)sql;
-(void)closeDB;
-(void)deleteDB:(NSString *)sql; 
// apply to TagManagementController , PopupPanelView for retreiving user_id  order by idOrder or playIdOrder
-(NSMutableArray *)selectOrderId:(NSString *)sql;
//apply to AlbumController for retreiving user_id user_name from Rules
-(NSMutableArray *)selectFromRules:(NSString *)sql;
// apply to PhotoViewController PopupPanelView , TagManagementController ,AlbumController for retreiving tag_id,tag_url from tag table
-(NSMutableArray *)selectFromTAG:(NSString *)sql;
-(NSMutableSet *)selectFromTAG1:(NSString *)sql;
//-(void)selectFromUserTable;
//apply to AlbumController for retreiving playlist_id,playlist_name from palytable
-(NSMutableArray *)selectFromPlayTable:(NSString *)sql;
-(NSMutableArray *)selectFromPassTable:(NSString *)sql;
//apply to TagManagementController , PopupPanelView,for retreiving user_id,user_name,user_color from UserTable;
- (NSString *)getUserFromUserTable:(int)id;
//apply to AlbumController for retreiving playlist_id,playlist_name from playTable
- (void)getUserFromPlayTable:(NSString *)_id;
//apply to AssetTablePickerController for retreiving url from TAG
-(NSMutableArray *)selectPhotos:(NSString *)sql;
//-(void)selectUserNameFromTag:(NSString *)sql;
-(NSString *)filePath;
-(BOOL)exitInDatabase:(NSString *)sql;

@end
