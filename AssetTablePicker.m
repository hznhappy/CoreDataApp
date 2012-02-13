//
//  AssetTablePicker.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "AssetTablePicker.h"
#import "PhotoAppDelegate.h"
#import "Asset.h"
#import "TagSelector.h"
#import "Album.h"
#import "PeopleTag.h"
#import "OnDeviceAssets.h"
@implementation AssetTablePicker
@synthesize crwAssets;
@synthesize table,val;
@synthesize viewBar,tagBar;
@synthesize save,reset,UrlList;
@synthesize lock;
@synthesize operations;
@synthesize tagRow;
@synthesize album;
#pragma mark -
#pragma mark UIViewController Methods

-(void)viewDidLoad {
    
    lockMode = NO;
    done = YES;
    action=YES;
    mode = NO;
    tagBar.hidden = YES;
    save.enabled = NO;
    reset.enabled = NO;
    tagSelector = [[TagSelector alloc]initWithViewController:self];
    
    self.tagRow=[[NSMutableArray alloc]init];
    self.UrlList=[[NSMutableArray alloc] init];
    
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    
   
   
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
    NSString *d=NSLocalizedString(@"Please enter a password", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    cancel = [[UIBarButtonItem alloc]initWithTitle:a style:UIBarButtonItemStyleDone target:self action:@selector(cancelTag)];
    alert1 = [[UIAlertView alloc]initWithTitle:d  message:@"\n" delegate:self cancelButtonTitle:c otherButtonTitles: a,nil];  
    passWord = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
    passWord.backgroundColor = [UIColor whiteColor];  
    passWord.secureTextEntry = YES;
    [alert1 addSubview:passWord];  
    alert1.tag=1;
//    oritation = [UIApplication sharedApplication].statusBarOrientation;
//    [self resetTableContentInset];
    
    //[self.table performSelector:@selector(reloadData) withObject:nil afterDelay:.3];
    [table reloadData];    
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow-1 inSection:0];
    [table scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EditPhotoTag)name:@"EditPhotoTag" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:@"reloadTableData" object:nil];
}

//-(void)resetTableContentInset{
//    UIEdgeInsets inset = self.table.contentInset;
//    if (UIInterfaceOrientationIsPortrait(oritation)) {
//        
//        inset.top = 65;
//    }else{
//        inset.top = 65;
//    }
//    self.table.contentInset = inset;
//}
-(void)EditPhotoTag
{
    [self.tagRow removeAllObjects];
    [self.table reloadData];
}

-(void)reloadTableData{
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    //[self resetTableContentInset];
    [self.table reloadData];
}
-(void)backButtonPressed
{
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {  
        [alert1 show];
    }
}
-(void)alertView:(UIAlertView *)alert11 didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *pass=[NSString stringWithFormat:@"%@",val];
    NSString *a=NSLocalizedString(@"Lock", @"title");
    NSString *b=NSLocalizedString(@"note", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    NSString *d=NSLocalizedString(@"The password is wrong", @"title");
    if(alert11.tag==2)
    {
        switch (buttonIndex) {
            case 0:
                if(passWord2.text==nil||passWord2.text.length==0)
                {
                }
                else
                {
                    NSUserDefaults *defaults1=[NSUserDefaults standardUserDefaults]; 
                    [defaults1 setObject:passWord2.text forKey:@"name_preference"]; 
                }
                break;
            case 1:
                break;
            default:
                break;
        }
    }
    else if(alert11.tag==1)
    {
        switch (buttonIndex) {
            case 0:
                if([passWord.text isEqualToString:pass])
                { 
                    
                    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
                    [defaults setObject:pass forKey:@"name_preference"];
                    self.lock.title=a;   
                    lockMode = NO;
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
                    
                    
                    break;
                }
            case 1:
                break;
            default:
                break;
        }
        

  
    }
    passWord.text=nil;
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    selectedRow = NSNotFound;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        tagSelector=nil;
        [[NSNotificationCenter defaultCenter] removeObserver:tagSelector];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
    
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
    [self.tagRow removeAllObjects];
    [self.UrlList removeAllObjects];
    tagSelector.mypeople=nil;
    [self.table reloadData];
}

-(IBAction)actionButtonPressed{
    
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
        action=NO;
      //  [self.table reloadData];
    }
    else
    {
       
        [alert1 show];
    }
}
-(IBAction)lockButtonPressed{
    NSString *a=NSLocalizedString(@"Lock", @"button");
    NSString *b=NSLocalizedString(@"UnLock", @"button");
    NSString *e=NSLocalizedString(@"Cancel", @"title");
    NSString *d=NSLocalizedString(@"The password is blank, set the password", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    if([self.lock.title isEqualToString:a])
    { 
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
        val=[defaults objectForKey:@"name_preference"];
        if(val==nil)
        { 
          
            UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:d  message:@"\n" delegate:self cancelButtonTitle:c otherButtonTitles:e,nil]; 
            passWord2= [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
            passWord2.backgroundColor = [UIColor whiteColor];  
            passWord2.secureTextEntry = YES;
            alert2.tag=2;
            [alert2 addSubview:passWord2];  
            [alert2 show];
        }
        else{
            lockMode = YES;
            [lock setTitle:b];
        }
    }
    else
    {   
        [alert1 show];
    }
}

-(IBAction)saveTags{
    NSString *b=NSLocalizedString(@"please select tag name", @"message");
    NSString *a=NSLocalizedString(@"note", @"button");
    NSString *c=NSLocalizedString(@"ok", @"button");
    NSString *d=NSLocalizedString(@"please select tag photo" ,@"message");

    if([tagSelector tagPeople]==nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:a
                              message:b
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:c,nil];
        [alert show];
        
    }
    else if([self.UrlList count]==0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:a
                              message:d
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:c,nil];
        [alert show];

        
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
    [self.UrlList removeAllObjects];
    [self.tagRow removeAllObjects];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"editplay" 
                                                       object:self 
                                                     userInfo:dic1];
   
}
-(IBAction)resetTags{
    [self.tagRow removeAllObjects];
    [self.UrlList removeAllObjects];
    [self.table reloadData];
}
-(IBAction)selectFromFavoriteNames{
    [self.UrlList removeAllObjects];
    [self.tagRow removeAllObjects];
    tagSelector.add=@"NO";
    [tagSelector selectTagNameFromFavorites];
}
-(IBAction)selectFromAllNames{
    [self.tagRow removeAllObjects];
    [self.UrlList removeAllObjects];
    tagSelector.add=@"NO";
    [tagSelector selectTagNameFromContacts];
}
-(IBAction)playPhotos{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.crwAssets, @"assets", self.album.transitType, @"transition",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
}



#pragma mark -
#pragma mark UITableViewDataSource and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        lastRow = ceil([self.crwAssets count]/6.0)+1;
    }else
        lastRow = ceil([self.crwAssets count]/4.0)+1; 
    
    return lastRow;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {	
        cell = [[ThumbnailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row == lastRow - 1) {
        NSInteger pmillionNumber = 0;
        NSInteger pthoundsNumber = 0;
        NSInteger pNumber = 0;
        NSInteger vmillionNumber = 0;
        NSInteger vthoundsNumber = 0;
        NSInteger vNumber = 0;
        
        NSString *a = @"";
        NSString *b = @"";
        NSString *c = @"";
        NSString *d = @"";
        NSString *e = @"";
        NSString *f = @"";
        PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        OnDeviceAssets *device = delegate.dataSource.deviceAssets;
        pmillionNumber = device.photoCount/1000000;
        if (pmillionNumber != 0) {
            a = [NSString stringWithFormat:@"%d,",pmillionNumber];
        }
        pthoundsNumber = (device.photoCount - pmillionNumber * 1000000)/1000;
        if (pthoundsNumber != 0) {
            b = [NSString stringWithFormat:@"%d,",pthoundsNumber];
        }
        pNumber = (device.photoCount -pmillionNumber * 1000000 - pthoundsNumber * 1000);
        if (pNumber != 0) {
            c = [NSString stringWithFormat:@"%d",pNumber];
        }
        vmillionNumber = device.videoCount/1000000;
        if (vmillionNumber != 0) {
            d = [NSString stringWithFormat:@"%d,",vmillionNumber];
        }
        vthoundsNumber = (device.videoCount - vmillionNumber * 1000000)/1000;
        if (vthoundsNumber != 0) {
            e = [NSString stringWithFormat:@"%d,",vthoundsNumber];
        }
        vNumber = (device.videoCount - vmillionNumber * 1000000 - vthoundsNumber * 1000);
        if (vNumber != 0) {
            f = [NSString stringWithFormat:@"%d",vNumber];
        }
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.origin.x + (cell.frame.size.width)*1/5, 10, (cell.frame.size.width)*4/5, cell.frame.size.height-20)];
        
        label.text = [NSString stringWithFormat: @"%@%@%@ Photos,%@%@%@ Videos",a,b,c,d,e,f];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont fontWithName:@"Arial" size:20];
        [cell addSubview:label]; 
    }else{
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
                if([tagSelector tag:dbAsset]==YES)
                {
                    NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                    NSLog(@"selectedIndex:%@",selectedIndex);
                    [tagRow addObject:selectedIndex];
                    //[cell checkTagSelection:selectedIndex];
                }
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
    }
    return cell;
}

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index{
    NSString *row=[NSString stringWithFormat:@"%d",index];
    Asset *asset = [self.crwAssets objectAtIndex:index];
    if(action==YES)
    {
        selectedRow = cell.rowNumber;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.crwAssets,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                                    [NSNumber numberWithBool:lockMode],@"lock", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"viewPhotos" object:nil userInfo:dic];   
      
    }
    else
    {
        if([self.tagRow containsObject:row])
        {
            [self.UrlList removeObject:asset];
            [self.tagRow removeObject:row];
            [tagSelector deleteTag:asset];
                      
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
   // [self resetTableContentInset];
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
}


@end
