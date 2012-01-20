//
//  AssetTablePicker.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "AssetTablePicker.h"
#import "AlbumController.h"
#import "PhotoViewController.h"
#import "TagManagementController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoAppDelegate.h"
#import "Asset.h"
#import "People.h"
#import "TagSelector.h"

@implementation AssetTablePicker
@synthesize crwAssets;
@synthesize table,val;
@synthesize viewBar,tagBar;
@synthesize save,reset,UrlList;
@synthesize lock;
@synthesize operations;
@synthesize tagRow;
#pragma mark -
#pragma mark UIViewController Methods

-(void)viewDidLoad {
    
    
    done = YES;
    action=YES;
    mode = NO;
    tagBar.hidden = YES;
    save.enabled = NO;
    reset.enabled = NO;
    ME=NO;
    PASS=NO;
    tagSelector = [[TagSelector alloc]initWithViewController:self];
    NSMutableArray *array=[[NSMutableArray alloc]init];
     NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    self.tagRow=array;
    self.UrlList=tempArray;
    [tempArray release];
    [array release];
    
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(huyou) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    [backItem release];
    
   
   
    self.table.delegate = self;
    self.table.maximumZoomScale = 2;
    self.table.minimumZoomScale = 1;
    self.table.contentSize = CGSizeMake(self.table.frame.size.width, self.table.frame.size.height);
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.table setSeparatorColor:[UIColor clearColor]];
	[self.table setAllowsSelection:NO];
    [self setWantsFullScreenLayout:YES];
    
    NSString *a=NSLocalizedString(@"Cancel", @"title");
    cancel = [[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleDone target:self action:@selector(cancelTag)];
    alert1 = [[UIAlertView alloc]initWithTitle:@"请输入密码"  message:@"\n" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"取消",nil];  
    passWord = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
    passWord.backgroundColor = [UIColor whiteColor];  
    passWord.secureTextEntry = YES;
    [alert1 addSubview:passWord];  
   
    [self.table performSelector:@selector(reloadData) withObject:nil afterDelay:.3];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EditPhotoTag)name:@"EditPhotoTag" object:nil];
}


-(void)EditPhotoTag
{
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
            
            [lock setTitle:b];
        }
    }
    else
    {   ME=NO;
        [alert1 show];
    }
}

-(IBAction)saveTags{
    if([tagSelector tagPeople]==nil)
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
            [tagSelector saveTagAsset:asset];
        }
       
         [self cancelTag];
    }
}
-(IBAction)resetTags{
    [self.tagRow removeAllObjects];
    [UrlList removeAllObjects];
    [self.table reloadData];
}
-(IBAction)selectFromFavoriteNames{
    [tagSelector selectTagNameFromFavorites];
}
-(IBAction)selectFromAllNames{
    [tagSelector selectTagNameFromContacts];
}
-(IBAction)playPhotos{
    //[dataBase getUserFromPlayTable:PLAYID];
    //NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.crwAssets,[NSString stringWithFormat:@"%d",0],dataBase.Transtion,@"animation",nil];
   // [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
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
    NSMutableArray *assetsInRow = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i<loopCount; i++) {
        NSInteger row = (indexPath.row*loopCount)+i;
        if (row<[self.crwAssets count]) {
            
            Asset *dbAsset = [self.crwAssets objectAtIndex:row];
            [assetsInRow addObject:dbAsset];
        }
    }
    [cell displayThumbnails:assetsInRow count:loopCount];
    
    if (!action) {
        for (NSInteger i = 0; i<loopCount; i++) {
            NSInteger row = (indexPath.row*loopCount)+i;
            if (row<[self.crwAssets count]) {
                
                NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                if([self.tagRow containsObject:selectedIndex])
                { 
                    [cell checkTagSelection:selectedIndex];
                    
                }
                
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
    self.viewBar = nil;
    self.tagBar = nil;
    self.save = nil;
    self.reset = nil;
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
    [UrlList release];
    [alert1 release];
    [val release];
    [tagRow release];
    [tagSelector release];
    [super dealloc];    
}


@end