//
//  AssetTablePicker.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "AssetTablePicker.h"
#import "AlbumController.h"
#import "PhotoViewController.h"
#import "tagManagementController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoAppDelegate.h"
#import "Asset.h"
#import "People.h"

@implementation AssetTablePicker
@synthesize crwAssets,urlsArray,dateArry;
@synthesize table,val;
@synthesize viewBar,tagBar;
@synthesize save,reset,UserId,UrlList,UserName;
@synthesize images,PLAYID,lock;
@synthesize library;
@synthesize operations;
@synthesize tagRow;
@synthesize destinctUrl;
@synthesize photos;
#pragma mark -
#pragma mark UIViewController Methods

-(void)viewDidLoad {
    appDelegate = [[UIApplication sharedApplication] delegate];
    done = YES;
    action=YES;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    NSMutableArray *array1=[[NSMutableArray alloc]init];
    self.tagRow=array;
    self.photos=array1;
    [array release];
    [array1 release];
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    [backItem release];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.UrlList=tempArray;
    [tempArray release];
    self.table.delegate = self;
    self.table.maximumZoomScale = 2;
    self.table.minimumZoomScale = 1;
    self.table.contentSize = CGSizeMake(self.table.frame.size.width, self.table.frame.size.height);
    mode = NO;
    tagBar.hidden = YES;
    save.enabled = NO;
    reset.enabled = NO;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.table setSeparatorColor:[UIColor clearColor]];
	[self.table setAllowsSelection:NO];
    [self setWantsFullScreenLayout:YES];
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    self.images = temp;
    [temp release];
    NSString *a=NSLocalizedString(@"Cancel", @"title");
    cancel = [[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleDone target:self action:@selector(cancelTag)];
    alert1 = [[UIAlertView alloc]initWithTitle:@"请输入密码"  message:@"\n" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"取消",nil];  
    passWord = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
    passWord.backgroundColor = [UIColor whiteColor];  
    passWord.secureTextEntry = YES;
    [alert1 addSubview:passWord];  
    ME=NO;
    PASS=NO;
    [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:.3];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AddUser:) name:@"AddUser" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EditPhotoTag)name:@"EditPhotoTag" object:nil];
    [self setPhotoTag];
}


-(void)EditPhotoTag
{
    [self setPhotoTag];
    [self.table reloadData];
}

-(void)huyou
{
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {  
        [alert1 show];
        ME=NO;
    }
}
-(void)alertView:(UIAlertView *)alert1 didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *pass=[NSString stringWithFormat:@"%@",val];
    NSString *a=NSLocalizedString(@"Lock", @"title");
    NSString *b=NSLocalizedString(@"note", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    NSString *d=NSLocalizedString(@"The password is wrong", @"title");
    if(ME==NO)
    {
        switch (buttonIndex) {
            case 0:
                if(PASS==YES)
                {
                    if(passWord2.text==nil||passWord2.text.length==0)
                    {
                    }
                    else
                    {
                        NSUserDefaults *defaults1=[NSUserDefaults standardUserDefaults]; 
                        [defaults1 setObject:passWord2.text forKey:@"name_preference"]; 
                    }
                    PASS=NO;
                }
                else if([passWord.text isEqualToString:pass])
                { 
                    NSString *deletePassTable= [NSString stringWithFormat:@"DELETE FROM PassTable"];	
                    NSLog(@"%@",deletePassTable);
                    //[dataBase deleteDB:deletePassTable];
                    
                    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
                    [defaults setObject:pass forKey:@"name_preference"];
                    self.lock.title=a;               
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:b
                                          message:d
                                          delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:c,nil];
                    [alert show];
                    [alert release];
                    ME=YES;
                    
                }
        }
        passWord.text=nil;
    }
}

-(void)AddUser:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
    mypeople=[dic objectForKey:@"people"];
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}

-(void)viewWillAppear:(BOOL)animated{
    selectedRow = NSNotFound;
}
-(void)viewWillDisappear:(BOOL)animated{
    
}
-(void)viewDidDisappear:(BOOL)animated{
    if (selectedRow != NSNotFound) {
        ThumbnailCell *cell = (ThumbnailCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
        [cell clearSelection];
        selectedRow = NSNotFound;
    }
}
-(void)setPhotoTag{
   
}

#pragma mark -
#pragma mark ButtonAction Methods
-(void)cancelTag{
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = nil;
    tagBar.hidden = YES;
    viewBar.hidden = NO;
    mode = NO;
    save.enabled=NO;
    reset.enabled=NO;
    action=YES;
    [self resetTags];
    
    [self.table reloadData];
}

-(IBAction)actionButtonPressed{
    action=NO;
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
        mode = YES;
        save.enabled=YES;
        reset.enabled=YES;
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = cancel;
        viewBar.hidden = YES;
        tagBar.hidden = NO;
        [self.table reloadData];
    }
    else
    {
        ME=NO;
        [alert1 show];
    }
}
-(IBAction)lockButtonPressed{
    NSString *a=NSLocalizedString(@"Lock", @"button");
    NSString *b=NSLocalizedString(@"UnLock", @"button");
    if([self.lock.title isEqualToString:a])
    { NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
        val=[[defaults objectForKey:@"name_preference"]retain];
        if(val==nil)
        { PASS=YES;
            UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"密码为空,请设置密码"  message:@"\n" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"取消",nil];  
            passWord2= [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
            passWord2.backgroundColor = [UIColor whiteColor];  
            passWord2.secureTextEntry = YES;
            [alert2 addSubview:passWord2];  
            [alert2 show];
            [alert2 release];
        }
        else{
            //NSString *deletePassTable= [NSString stringWithFormat:@"DELETE FROM PassTable"];
            //[dataBase deleteDB:deletePassTable];
            //for(int i=0;i<[self.urlsArray count];i++)
            // {
           // NSString *insertPassTable= [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(LOCK,PASSWORD,PLAYID) VALUES('%@','%@','%@')",PassTable,@"UnLock",val,self.PLAYID];
           // [dataBase insertToTable:insertPassTable];
            
            [lock setTitle:b];
        }
    }
    else
    {   ME=NO;
        [alert1 show];
    }
}

-(IBAction)saveTags{
    if(mypeople==nil)
    {
        ME=YES;
        NSString *message=[[NSString alloc] initWithFormat:
                           @"please select tag name"];
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"note"
                              message:message
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK!",nil];
        [alert show];
        [alert release];
        [message release];
        
    }
    
    else
    {
        for(int i=0;i<[self.UrlList count];i++)
        {   
         
            Asset *asset = [self.UrlList objectAtIndex:i];
            PeopleTag  *peopleTag= [NSEntityDescription insertNewObjectForEntityForName:@"PeopleTag" inManagedObjectContext:[appDelegate.dataSource.coreData managedObjectContext]];
            peopleTag.conAsset = asset;
            [asset addConPeopleTagObject:peopleTag];
            peopleTag.conPeople = mypeople;
            [mypeople addConPeopleTagObject:peopleTag];
            [appDelegate.dataSource.coreData saveContext];
            
        }
       

       
        
        /*for(int i=0;i<[self.UrlList count];i++)
        {    
            NSString *insertTag= [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@(ID,URL,NAME) VALUES('%@','%@','%@')",TAG,UserId,[self.UrlList objectAtIndex:i],self.UserName];
            NSLog(@"JJJJ%@",insertTag);
            [dataBase insertToTable:insertTag];
        }
       
        [self setPhotoTag];
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                           object:self 
                                                         userInfo:dic1];*/
        
         [self cancelTag];
    }
}
-(IBAction)resetTags{
    [self.tagRow removeAllObjects];
    [UrlList removeAllObjects];
    [self.table reloadData];
}
-(IBAction)selectFromFavoriteNames{
    tagManagementController *nameController = [[tagManagementController alloc]init];
    nameController.bo=[NSString stringWithFormat:@"yes"];
	UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:nameController];
	[self presentModalViewController:navController animated:YES];
    [navController release];
    [nameController release];
}
-(IBAction)selectFromAllNames{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    [picker release]; 
}
-(IBAction)playPhotos{
    //[dataBase getUserFromPlayTable:PLAYID];
    //NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.crwAssets,[NSString stringWithFormat:@"%d",0],dataBase.Transtion,@"animation",nil];
   // [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
}

#pragma mark - 
#pragma mark notification method

-(void)setEditOverlay:(NSNotification *)notification{
    
    [self setPhotoTag];
    
}

#pragma mark -
#pragma mark People picker delegate
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    
    NSString *firstName = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    ABRecordID recId = ABRecordGetRecordID(person);
    
    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectsContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"addressBookId == %@",[NSNumber numberWithInteger:recId]];
    [request setPredicate:pre];
    
    NSError *error = nil;
    NSArray *array = [managedObjectsContext executeFetchRequest:request error:&error];
    if (array != nil && [array count] && error == nil) {
        mypeople = [array objectAtIndex:0];
    }else{
        mypeople = [NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:managedObjectsContext];
        mypeople.firstName = firstName;
        mypeople.lastName = lastName;
        mypeople.addressBookId = [NSNumber numberWithInteger:recId];
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}
#pragma mark -
#pragma mark UITableViewDataSource and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        return ceil([self.crwAssets count]/6.0);
    }else
        return ceil([self.crwAssets count]/4.0);    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {	
        cell = [[[ThumbnailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        
    }
    
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionDelegate = self;
    cell.rowNumber = indexPath.row;
    
    NSInteger loopCount = 0;
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        loopCount = 6;
    }else
        loopCount = 4;
   // NSMutableArray *assetsInRow = [[NSMutableArray alloc]init];
    CGRect frame = CGRectMake(4, 2, 75, 75);
    for (NSInteger i = 0; i<loopCount; i++) {
        NSInteger row = (indexPath.row*loopCount)+i;
        if (row<[self.crwAssets count]) {
            
            Asset *dbAsset = [self.crwAssets objectAtIndex:row];
            NSString *dbUrl = dbAsset.url;
            NSURL *url = [NSURL URLWithString:dbUrl];
            ALAsset *asset = [appDelegate.dataSource getAsset:dbAsset.url];
            ThumbnailImageView *thumImageView = [[ThumbnailImageView alloc]initWithAsset:asset index:row];
            thumImageView.frame = frame;
            thumImageView.delegate = cell;
            [cell addSubview:thumImageView];
            [thumImageView release];
            frame.origin.x = frame.origin.x + frame.size.width + 4;
            NSString *ROW=[NSString stringWithFormat:@"%d",row];
            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) 
            {
                NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                 forKey:AVURLAssetPreferPreciseDurationAndTimingKey];           
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts]; 
                
                minute = 0, second = 0; 
                second = urlAsset.duration.value / urlAsset.duration.timescale;
                if (second >= 60) {
                    int index = second / 60;
                    minute = index;
                    second = second - index*60;                        
                }    
                [thumImageView addSubview:[self CGRectMake2]];
                
            }
            
            if([self.tagRow containsObject:ROW])
            { 
                [thumImageView addSubview:[self CGRectMake]]; 
                
            }
            if([dbAsset.numPeopleTag intValue] != 0)
            {   
                [thumImageView addSubview:[self CGRectMake1]];
                count.text =[NSString stringWithFormat:@"%@",dbAsset.numPeopleTag];
                [count release];
                
                
            }
        }
    }
    return cell;
}

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index{
    NSString *row=[NSString stringWithFormat:@"%d",index];
    Asset *asset = [self.crwAssets objectAtIndex:index];
    if(action==YES)
    {
        selectedRow = cell.rowNumber;
        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.crwAssets forKey:[NSString stringWithFormat:@"%d",index]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"viewPhotos" object:nil userInfo:dic];   
    }
    else
    {
        if([self.tagRow containsObject:row])
        {
            [self.UrlList removeObject:asset];
            [self.tagRow removeObject:row];
        }
        else
        {   [self.UrlList addObject:asset];
            [self.tagRow addObject:row];
        }
    }
    [self.table reloadData];
    
}
-(UIImageView *)CGRectMake
{
    CGRect viewFrames = CGRectMake(0, 0, 75, 75);
    UIImageView *overlayView = [[[UIImageView alloc]initWithFrame:viewFrames]autorelease];
    [overlayView setImage:[UIImage imageNamed:@"selectOverlay.png"]];
    return overlayView;
}
-(UIView *)CGRectMake1
{
    UIView *tagBg =[[[UIView alloc]initWithFrame:CGRectMake(3, 3, 25, 25)]autorelease];
    CGPoint tagBgCenter = tagBg.center;
    tagBg.layer.cornerRadius = 25 / 2.0;
    tagBg.center = tagBgCenter;
    
    UIView *tagCount = [[UIView alloc]initWithFrame:CGRectMake(2.6, 2.2, 20, 20)];
    tagCount.backgroundColor = [UIColor colorWithRed:182/255.0 green:0 blue:0 alpha:1];
    CGPoint saveCenter = tagCount.center;
    tagCount.layer.cornerRadius = 20 / 2.0;
    tagCount.center = saveCenter;
    count= [[UILabel alloc]initWithFrame:CGRectMake(3, 4, 13, 12)];
    count.backgroundColor = [UIColor colorWithRed:182/255.0 green:0 blue:0 alpha:1];
    count.textColor = [UIColor whiteColor];
    count.textAlignment = UITextAlignmentCenter;
    count.font = [UIFont boldSystemFontOfSize:11];
    [tagCount addSubview:count];
    [tagBg addSubview:tagCount];
    [tagCount release];
    return tagBg;
    
}
-(UIView *)CGRectMake2
{
    UIView *video =[[[UIView alloc]initWithFrame:CGRectMake(0, 54, 74, 16)]autorelease];
    UILabel *length=[[UILabel alloc]initWithFrame:CGRectMake(40, 3, 44, 10)];
    UIImageView *tu=[[UIImageView alloc]initWithFrame:CGRectMake(6, 4,15, 8)];
    //  tu= [UIButton buttonWithType:UIButtonTypeCustom]; 
    UIImage *picture = [UIImage imageNamed:@"VED.png"];
    // set the image for the button
    [tu setImage:picture];
    [video addSubview:tu];
    
    
    [length setBackgroundColor:[UIColor clearColor]];
    length.alpha=0.8;
    NSString *a=[NSString stringWithFormat:@"%d",minute];
    NSString *b=[NSString stringWithFormat:@"%d",second];
    length.text=a;
    length.text=[length.text stringByAppendingString:@":"];
    length.text=[length.text stringByAppendingString:b];
    length.textColor = [UIColor whiteColor];
    length.textAlignment = UITextAlignmentLeft;
    length.font = [UIFont boldSystemFontOfSize:12.0];
    [video addSubview:length];

    [video setBackgroundColor:[UIColor grayColor]];
    video.alpha=0.9;
    length.alpha = 1.0;
    tu.alpha = 1.0;
    [length release];
    [tu release];
    return video;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

-(void)viewPhotos:(id)sender{
    
    UIButton *button1= (UIButton *)sender;
    NSLog(@"button tag:%d",button1.tag);
    NSString *row=[NSString stringWithFormat:@"%d",button1.tag];
    ALAsset *asset = [self.crwAssets objectAtIndex:button1.tag];
    NSString *url = [[[asset defaultRepresentation]url] description];
    if(action==YES)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.crwAssets forKey:[NSString stringWithFormat:@"%d",button1.tag]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"viewPhotos" object:nil userInfo:dic];    
    }
    else
    {
        if([self.tagRow containsObject:row])
        {
            [self.UrlList removeObject:url];
            [self.tagRow removeObject:row];
        }
        else
        {   [self.UrlList addObject:url];
            [self.tagRow addObject:row];
        }
    }
    [self.table reloadData];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    oritation = toInterfaceOrientation;
	return (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    oritation = toInterfaceOrientation;
    if ((UIInterfaceOrientationIsLandscape(oritation) && UIInterfaceOrientationIsLandscape(previousOrigaton))||(UIInterfaceOrientationIsPortrait(oritation)&&UIInterfaceOrientationIsPortrait(previousOrigaton))) {
        return;
    }
    UIEdgeInsets insets = self.table.contentInset;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.table setContentInset:UIEdgeInsetsMake(insets.top-12, insets.left, insets.bottom, insets.right)];
    }else{
        [self.table setContentInset:UIEdgeInsetsMake(insets.top+12, insets.left, insets.bottom, insets.right)];
    }
    previousOrigaton = toInterfaceOrientation;
    [self.table reloadData];
}

#pragma  mark -
#pragma  mark Memory management
-(void)viewDidUnload{
    self.table = nil;
    self.crwAssets = nil;
    self.urlsArray = nil;
    self.viewBar = nil;
    self.tagBar = nil;
    self.save = nil;
    self.reset = nil;
    self.dateArry = nil;
    self.images = nil;
    [super viewDidUnload];
}


- (void)dealloc
{   
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [viewBar release];
    [tagBar release];
    [cancel release];
    [save release];
    [reset release];
    [table release];
    [crwAssets release];
    [urlsArray release];
    [dateArry release];
    [UserId release];
    [UserName release];
    [images release];
    [UrlList release];
    [PLAYID release];
    [alert1 release];
    [val release];
    [tagRow release];
    [photos release];
    [super dealloc];    
}


@end
