//
//  PlaylistDetailController.m
//  PhotoApp
//
//  Created by Andy on 11/3/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PlaylistDetailController.h"
#import "User.h"
#import "DBOperation.h"
#import "AnimaSelectController.h"

@implementation PlaylistDetailController
@synthesize listTable;
@synthesize textFieldCell,switchCell,tranCell,musicCell;
@synthesize tranLabel,musicLabel,state,stateButton;
@synthesize textField;
@synthesize mySwitch;
@synthesize listName,photos;
@synthesize userNames;
@synthesize selectedIndexPaths;
@synthesize mySwc,a,playrules_idList,playrules_nameList,playrules_ruleList,playIdList,orderList;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [selectedIndexPaths release];
    [musicLabel release];
    [tranLabel release];
    [mySwitch release];
    [textField release];
    [textFieldCell release];
    [switchCell release];
    [tranCell release];
    [musicCell release];
    [listTable release];
    [dataBase release];
    [listName release];
    [userNames release];
    [state release];
    [a release];
    [photos release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{ 
    key=0;
    mySwc = YES;
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
    dataBase=[[DBOperation alloc]init];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *playArray = [[NSMutableArray alloc]init];
    NSMutableArray *IdOrderArray = [[NSMutableArray alloc]init];
     NSMutableArray *IdArray = [[NSMutableArray alloc]init];
    NSMutableArray *temArray = [[NSMutableArray alloc]init];
    self.selectedIndexPaths = temArray;
    self.userNames = tempArray;
    [IdOrderArray release];
    [IdArray release];
    [tempArray release];
    [temArray release];
    [playArray release];
    [dataBase openDB];
    NSString *selectIdOrder=[NSString stringWithFormat:@"select id from idOrder"];
    [dataBase selectOrderId:selectIdOrder];
    self.orderList=dataBase.orderIdList;
    for (id object in orderList) {
        User *userName = [dataBase getUserFromUserTable:[object intValue]];
        [userNames addObject:userName.name];
    }
    [self creatTable];
    NSString *selectSql = @"SELECT DISTINCT NAME FROM TAG";
    self.photos = [dataBase selectPhotos:selectSql];
    NSLog(@"%@",photos);
 

    [dataBase closeDB];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playListedit:) name:@"playListedit" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTransitionAccessoryLabel:) name:@"changeTransitionLabel" object:nil];
    [super viewDidLoad];
}
#pragma mark -
#pragma mark UITableView  method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            if (mySwc) {
                return 4;
            }
            else{
                return 3;
            }
            break;
        case 1:
            return [userNames count];
            break;
        default:
            break;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowNum=indexPath.row;
    if (indexPath.section == 0) {
        UITableViewCell *cell = nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
                if (cell == nil) {
                    cell = self.textFieldCell;
                }
                if(a!=nil)
                {
                    if(key==0)
                    {
                self.textField.text = listName;
                    }
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"transitionsCell"];
                if (cell == nil) {
                    cell = self.tranCell;
                }
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"playMusicCell"];
                if (cell == nil) {
                    cell = self.switchCell;
                }
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
                if (cell == nil) {
                    cell = self.musicCell;
                }
                break;
            default:
                cell = nil;
                break;
        }
        return cell;
    }else {
        static NSString *cellIdentifier = @"nameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
           
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(45, 11, 126, 20)];
            name.tag = indexPath.row;
            if([self.photos count]!=0)
            {
            name.text = [self.photos objectAtIndex:indexPath.row];
            }
            [cell.contentView addSubview:name];
            [name release];

            UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectButton.tag = indexPath.row;
            [selectButton addTarget:self action:@selector(setSelectState:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.frame = CGRectMake(10, 11, 30, 30);
            [selectButton setImage:unselectImg forState:UIControlStateNormal];
            if([playrules_idList containsObject:[orderList objectAtIndex:indexPath.row]])
            {[dataBase openDB];
                NSString *selectRules= [NSString stringWithFormat:@"select user_id,user_name,playlist_rules from rules where user_id=%d and playlist_id=%d",[[orderList objectAtIndex:indexPath.row]intValue],[a intValue]];
                [dataBase selectFromRules:selectRules];
                 cell.accessoryView = [self getStateButton];
                [selectedIndexPaths addObject:indexPath];
                [selectButton setImage:selectImg forState:UIControlStateNormal];
                for(NSString * rule in dataBase.playlist_UserRules)
                {NSLog(@"ew%d",[rule intValue]);
                    if([rule intValue]==1)
                    {
                        [stateButton setTitle:MUST forState:UIControlStateNormal];
                       stateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
                    }
                    else if([rule intValue]==0)
                    {
                        stateButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                        [stateButton setTitle:EXCLUDE forState:UIControlStateNormal];
                    }
                    else if([rule intValue]==2)
                    {  
                       stateButton.backgroundColor =  [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
                        [stateButton setTitle:OPTIONAL forState:UIControlStateNormal];
                    }
                }
               

                [dataBase closeDB];
            }

            [cell.contentView addSubview:selectButton];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0 && indexPath.row == 1) {
        AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
        animateController.tranStyle = self.tranLabel.text;
        [self.navigationController pushViewController:animateController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [animateController release];
    }
    if (indexPath.section ==0 && indexPath.row == 3) {
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = @"Select songs";
        
        [self.navigationController pushViewController:mediaPicker animated:YES];
        [mediaPicker release];    
    }
    if (indexPath.section == 1) {
        if(textField.text==nil||textField.text.length==0)
        { NSString *message=[[NSString alloc] initWithFormat:
                             @"请先填写规则名!"];
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"提示"
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"确定!",nil];
            [alert show];
            [alert release];
            [message release];
            

        }
        else
        {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = [self getStateButton];
        if (cell.accessoryView==nil) {
            cell.accessoryView = button;
        }else{
            cell.accessoryView = nil;
        }
          NSInteger Row=indexPath.row;
        int playID=0;
        if(textField.text==nil||textField.text.length==0)
        {
            playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue]+1;
        }
        else
        {
         playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue];
        }
        for (UIButton *button in cell.contentView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                if ([button.currentImage isEqual:unselectImg]) {
                    [button setImage:selectImg forState:UIControlStateNormal];
                    [selectedIndexPaths addObject:indexPath];
                [button setImage:selectImg forState:UIControlStateNormal];
                    if(a==nil)
                    {
                      [self insert:Row playId:playID];
                    }
                    else{
                          [self insert:Row playId:[a intValue]];
                    
                    }
                }else{
                    if(a==nil)
                    {
                           [self deletes:Row playId:playID];
                    }
                    else{
                        [self deletes:Row playId:[a intValue]];

                 
                    }
                    [button setImage:unselectImg forState:UIControlStateNormal];
                    [selectedIndexPaths removeObject:indexPath];
                }
            }
        }
    }
    }
    [self.textField resignFirstResponder];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];
}

#pragma mark -
#pragma mark media picker delegate method
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play];
        self.musicLabel.text = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    }
    [self dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}
-(void)creatTable
{
    NSString *createPlayTable= [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(playList_id INTEGER PRIMARY KEY,playList_name)",PlayTable];
    [dataBase createTable:createPlayTable];
    NSString *createPlayIdOrder= [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(play_id INT)",playIdOrder];
    [dataBase createTable:createPlayIdOrder];
    NSString *selectPlayIdOrder=[NSString stringWithFormat:@"select id from playIdOrder"];
    [dataBase selectOrderId:selectPlayIdOrder];
    
    NSString *selectPlayTable = [NSString stringWithFormat:@"select playlist_id from PlayTable"];
    [dataBase selectFromPlayTable:selectPlayTable];
     self.playIdList=dataBase.playIdAry;
    NSString *createRules=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(playList_id INT,playList_rules INT,user_id INT,user_name)",Rules];
    [dataBase createTable:createRules];
    NSString *selectRules= [NSString stringWithFormat:@"select user_id,user_name from rules where playlist_id=%d",[a intValue]];
    [dataBase selectFromRules:selectRules];
    self.playrules_idList=dataBase.playlist_UserId;
    NSLog(@"YYYY%@",playrules_idList);

}


-(void)insert:(NSInteger)Row playId:(int)playId
{
    [dataBase openDB];
    NSString *insertRules= [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(playList_id,playList_rules,user_id,user_name) VALUES('%d','%d','%@','%@')",Rules,playId,1,[orderList objectAtIndex:Row],[userNames objectAtIndex:Row]];
    NSLog(@"%@",insertRules);
    [dataBase insertToTable:insertRules];  
    [dataBase closeDB];

}


-(void)deletes:(NSInteger)Row playId:(int)playId
{[dataBase openDB];
    NSString *deleteRules= [NSString stringWithFormat:@"DELETE FROM Rules WHERE playlist_id=%d and user_id='%@'",playId,[orderList objectAtIndex:Row]];
    NSLog(@"%@",deleteRules);
    [dataBase deleteDB:deleteRules];
    [dataBase closeDB];
}


-(void)update:(NSInteger)Row rule:(int)rule playId:(int)playId
{[dataBase openDB];
    NSString *updateRules= [NSString stringWithFormat:@"UPDATE %@ SET playList_rules=%d WHERE playlist_id=%d and user_id='%@'",Rules,rule,playId,[orderList objectAtIndex:Row]];
	NSLog(@"%@",updateRules);
	[dataBase updateTable:updateRules];
    [dataBase closeDB];
}
#pragma mark -
#pragma mark Coustom method
-(UIButton *)getStateButton{
   stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stateButton.frame = CGRectMake(0, 0, 75, 28);
    [stateButton addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    [stateButton setTitle:MUST forState:UIControlStateNormal];
    stateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [stateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return stateButton;
}
-(void)changeState:(id)sender{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSLog(@"rrrr%@",[button superview]);
    NSIndexPath *index = [listTable indexPathForCell:cell];
    NSInteger Row=index.row;
    NSLog(@"FFFFF%d",Row);
    int playID=0;
    if(textField.text==nil||textField.text.length==0)
    {
        playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue]+1;
    }
    else
    {
        playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue];
    }
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:MUST]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:EXCLUDE forState:UIControlStateNormal];
        if(a==nil)
        {
        [self update:Row rule:0 playId:playID];
        }
        else
        {
            [self update:Row rule:0 playId:[a intValue]];
        }
    }else if([button.titleLabel.text isEqualToString:EXCLUDE]){
        button.backgroundColor = [UIColor colorWithRed:81/255.0 green:142/255.0 blue:72/255.0 alpha:1.0];
        [button setTitle:OPTIONAL forState:UIControlStateNormal];
        if(a==nil)
        {
        [self update:Row rule:2 playId:playID];
        }
        else
        {
            [self update:Row rule:2 playId:[a intValue]];
            
        }
    }else{
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:MUST forState:UIControlStateNormal];
        if(a==nil)
        {
            [self update:Row rule:1 playId:playID];
        }
        else
        {
            [self update:Row rule:1 playId:[a intValue]];
            
        }
    }
}
-(void)setSelectState:(id)sender{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *index = [listTable indexPathForCell:cell];
     NSInteger Row=index.row;
    int playID=0;
    if(textField.text==nil||textField.text.length==0)
    {
        playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue]+1;
    }
    else
    {
        playID=[[playIdList objectAtIndex:[playIdList count]-1]intValue];
    }

    if ([button.currentImage isEqual:selectImg]) {
        if(a==nil)
        {
            [self deletes:Row playId:playID];
        }
        else{
        
            [self deletes:Row playId:[a intValue]];
        }
        [button setImage:unselectImg forState:UIControlStateNormal];
        NSIndexPath *index = [listTable indexPathForCell:cell];
        [selectedIndexPaths removeObject:index];
        cell.accessoryView = nil;
    }else{
        if(a==nil)
        {
            [self insert:Row playId:playID];
            
        }
        else
        {
        [self insert:Row playId:[a intValue]];
        }
        [button setImage:selectImg forState:UIControlStateNormal];
        NSIndexPath *index = [listTable indexPathForCell:cell];
        [selectedIndexPaths addObject:index];
        cell.accessoryView = [self getStateButton];
    }
    
}
#pragma mark -
#pragma mark IBAction method
-(IBAction)hideKeyBoard:(id)sender{
    [sender resignFirstResponder];
    key=key+1;
    dataBase=[[DBOperation alloc]init];
    [dataBase openDB];
    if(textField.text==nil||textField.text.length==0)
    {
        
        NSString *message=[[NSString alloc] initWithFormat:
                           @"规则名不能为空!"];
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:message
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"确定!",nil];
        [alert show];
        [alert release];
        [message release];
        
    }
    else
    {
        if(a==nil)
    {
    if(key==1)
     {
        NSString *insertPlayTable= [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(playList_name) VALUES('%@')",PlayTable,textField.text];
        NSLog(@"%@",insertPlayTable);
        [dataBase insertToTable:insertPlayTable];
        
        NSString *selectPlayTable = [NSString stringWithFormat:@"select * from PlayTable"];
        [dataBase selectFromPlayTable:selectPlayTable];
        playIdList=dataBase.playIdAry;
        NSString *insertPlayIdOrder= [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(play_id) VALUES(%d)",playIdOrder,[[playIdList objectAtIndex:[playIdList count]-1]intValue]];
        NSLog(@"%@",insertPlayIdOrder);
        [dataBase insertToTable:insertPlayIdOrder];
        }
        else
        {
            NSString *updateRules= [NSString stringWithFormat:@"UPDATE %@ SET playlist_name='%@' WHERE playlist_id=%d",PlayTable,textField.text,[[playIdList objectAtIndex:[playIdList count]-1]intValue]];
            NSLog(@"%@",updateRules);
            [dataBase updateTable:updateRules];
 
        }
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                           object:self 
                                                         userInfo:dic1];
        
    }
   else{
        
       NSString *updateRules= [NSString stringWithFormat:@"UPDATE %@ SET playlist_name='%@' WHERE playlist_id=%d",PlayTable,textField.text,[a intValue]];
       NSLog(@"%@",updateRules);
       [dataBase updateTable:updateRules];
       NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
       [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                          object:self 
                                                        userInfo:dic1];



       }
    }
    

}


-(IBAction)updateTable:(id)sender{
    UISwitch *newSwitcn  = (UISwitch *)sender;
    mySwc = newSwitcn.on;
    if (newSwitcn.on) {
        [listTable beginUpdates];
        [listTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }else{
        [listTable beginUpdates];
        [listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [listTable endUpdates];
    }
}

-(IBAction)resetAll{
    for (NSIndexPath *path in selectedIndexPaths) {
        if (path.section == 1) {
            UITableViewCell *cell = [listTable cellForRowAtIndexPath:path];
            cell.accessoryView = nil;
            for (UIButton *button in cell.contentView.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    if ([button.currentImage isEqual:selectImg]) {
                        [button setImage:unselectImg forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
    [dataBase openDB];
    if(a==nil)
    {
    NSString *deleteRules=[NSString stringWithFormat:@"delete from Rules where playList_id=%d",[[playIdList objectAtIndex:[playIdList count]-1]intValue]];
        NSLog(@"%@",deleteRules);
        [dataBase deleteDB:deleteRules];
    }
    else
    {
        NSString *deleteRules1=[NSString stringWithFormat:@"delete from Rules where playList_id=%d",[a intValue]];
        NSLog(@"%@",deleteRules1);
        [dataBase deleteDB:deleteRules1];
    }
    [dataBase closeDB];
    [selectedIndexPaths removeAllObjects];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];
}

#pragma mark -
#pragma mark Notification method
-(void)changeTransitionAccessoryLabel:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSString *labelText = [dic objectForKey:@"tranStyle"];
    self.tranLabel.text = labelText;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [textField resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    selectedIndexPaths = nil;
    textFieldCell = nil;
    textField = nil;
    tranCell = nil;
    tranLabel = nil;
    switchCell = nil;
    mySwitch = nil;
    musicCell = nil;
    musicLabel = nil;
    a = nil;
    dataBase = nil;
    listTable =nil;
    listName = nil;
    userNames = nil;
    state = nil;
}
@end
