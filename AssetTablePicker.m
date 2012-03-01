//
//  AssetTablePicker.m
//
//  Created by Andy.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "AssetTablePicker.h"
#import "Asset.h"
#import "TagSelector.h"
#import "Album.h"
#import "PeopleTag.h"
#import "PhotoAppDelegate.h"
#import "People.h"
#import "favorite.h"
#import "EventTableView.h"
#import "EventRule.h"
@implementation AssetTablePicker
@synthesize crwAssets;
@synthesize table;
@synthesize viewBar,tagBar;
@synthesize lock;
@synthesize operations;
@synthesize album;
@synthesize likeAssets;
@synthesize assertList;
@synthesize AddAssertList;
@synthesize action;
@synthesize side;
@synthesize ta;
@synthesize lockMode;
@synthesize firstLoad;
@synthesize personButton;
#pragma mark -
#pragma mark UIViewController Methods
-(void)viewDidLoad {
    name= [UIButton buttonWithType:UIButtonTypeCustom];
    PhotoAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    dataSource = appDelegate.dataSource;
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    [self setTableViewEdge:oritation];
    if(album==nil)
    {
        NSString *timeTitle = NSLocalizedString(@"Time", @"title");
        lock.enabled=NO;
        NSArray *array = [NSArray arrayWithObjects:@"All",@"Photos",@"Videos", nil];
        datelist=[NSMutableArray arrayWithObjects:@"Recent 2 weeks",@"Recent month",@"Recent 3 mohths",@"Recent 6 months",@"More than 6 months",@"More than one year",@"UnKnow",nil];
        UISegmentedControl *segControl = [[UISegmentedControl alloc]initWithItems:array];
        [segControl addTarget:self action:@selector(showTypeSelections:) forControlEvents:UIControlEventValueChanged];
        segControl.selectedSegmentIndex = 0;
        segControl.segmentedControlStyle = UISegmentedControlStyleBar;
      //  UIBarButtonItem *fix = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
       // fix.width = 40;
        UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *time = [[UIBarButtonItem alloc]initWithTitle:timeTitle style:UIBarButtonItemStyleBordered target:self action:@selector(showTimeSelections)];
        UIBarButtonItem *type = [[UIBarButtonItem alloc]initWithCustomView:segControl];
        //UIBarButtonItem *type = [[UIBarButtonItem alloc]initWithTitle:typeTitle style:UIBarButtonItemStyleBordered target:self action:@selector(showTypeSelections)];
        [viewBar setItems:[NSArray arrayWithObjects:time,flex,type, nil]];
        
    }
    isEvent=NO;
    lockMode = NO;
    done = YES;
    action=YES;
    as=NO;
    mode = NO;
    protecteds=NO;
    photoType = NO;
    videoType = NO;
    timeBtPressed = NO;
    tagBar.hidden = YES;
    personPt=NO;
    isFavorite=NO;
    tagSelector = [[TagSelector alloc]initWithViewController:self];
    
    tagRow=[[NSMutableArray alloc]init];
    UrlList=[[NSMutableArray alloc] init];
    assertList=[[NSMutableArray alloc]init];
    AddAssertList=[[NSMutableArray alloc]init];
    inAssert=[[NSMutableArray alloc]init];
    photoArray = [[NSMutableArray alloc]init];
    videoArray = [[NSMutableArray alloc]init];
    green = [UIImage imageNamed:@"dot-green.png"];
    red = [UIImage imageNamed:@"dot-red.png"];
    greenImageView = [[UIImageView alloc]initWithImage:green];
    greenImageView.frame = CGRectZero;
    redImagView = [[UIImageView alloc]initWithImage:red];
    redImagView.frame = CGRectMake(10, 165, 10, 10);
    [self countPhotosAndVideosCounts];
    allTableData = self.crwAssets;
    photoTableData = photoArray;
    videoTableData = videoArray;
    self.likeAssets = [[NSMutableArray alloc]init];
    NSString *b=NSLocalizedString(@"Back", @"title");
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.table setSeparatorColor:[UIColor clearColor]];
	[self.table setAllowsSelection:NO];
    [self setWantsFullScreenLayout:YES];
    NSString *e=NSLocalizedString(@"Tag", @"title");
    NSString *a=NSLocalizedString(@"Done", @"title");
    NSString *d=NSLocalizedString(@"Please enter a password", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    cancel = [[UIBarButtonItem alloc]initWithTitle:e style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTag)];
     self.navigationItem.rightBarButtonItem = cancel;
    alert1 = [[UIAlertView alloc]initWithTitle:d  message:@"\n" delegate:self cancelButtonTitle:c otherButtonTitles: a,nil];  
    passWord = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 30)];  
    passWord.backgroundColor = [UIColor whiteColor];  
    passWord.secureTextEntry = YES;
    [alert1 addSubview:passWord];  
    alert1.tag=1;
    [table reloadData];    
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow-1 inSection:0];
    [table scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self configureTimeSelectionView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EditPhotoTag:)name:@"EditPhotoTag" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:@"reloadTableData" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"refresh" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    if (firstLoad) {
        firstLoad = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if (firstLoad) {
        [table reloadData];    
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow-1 inSection:0];
        [table scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
//    ThumbnailCell *cell = (ThumbnailCell *)[[self.table visibleCells]objectAtIndex:0];
//    NSInteger index = cell.rowNumber;
//    NSLog(@"the first %d",index);
//    CGPoint offset = self.table.contentOffset;
//    NSLog(@"the previous is %@",NSStringFromCGPoint(offset));
    selectedRow = NSNotFound;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        tagSelector=nil;
        [[NSNotificationCenter defaultCenter] removeObserver:tagSelector];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        self.crwAssets = nil;
        self.album = nil;
    }
    
}
-(void)viewDidDisappear:(BOOL)animated{
    if (selectedRow != NSNotFound) {
        ThumbnailCell *cell = (ThumbnailCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
        [cell clearSelection];
        selectedRow = NSNotFound;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    oritation = toInterfaceOrientation;
	return (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    oritation = toInterfaceOrientation;
    if ((UIInterfaceOrientationIsLandscape(oritation) && UIInterfaceOrientationIsLandscape(previousOrigaton))||(UIInterfaceOrientationIsPortrait(oritation)&&UIInterfaceOrientationIsPortrait(previousOrigaton))) {
        return;
    }
    [self setTableViewEdge:toInterfaceOrientation];
    if (previousOrigaton != toInterfaceOrientation) {
        ThumbnailCell *cell = (ThumbnailCell *)[[self.table visibleCells]objectAtIndex:0];
        NSInteger index = 0;
        NSInteger row = 0;
        [self.table reloadData];
        // NSLog(@"the row is %d",cell.rowNumber);
        //NSLog(@"the contentOffset is %@",NSStringFromCGPoint(self.table.contentOffset));;
        if (UIInterfaceOrientationIsLandscape(previousOrigaton)) {
            index = cell.rowNumber * 6;
            row = index / 4;
        }else{
            index = cell.rowNumber * 4;
            row = index / 6;
        }
        // NSLog(@" after row is %d",row);
        //       NSInteger abs = row - cell.rowNumber;
        //        NSLog(@"the different is %d",row);
        //        CGPoint contetOffset = self.table.contentOffset;
        //        CGPoint newPoint = CGPointMake(0, contetOffset.y + cell.frame.size.height *abs); 
        //        [self.table setContentOffset:newPoint];
        
        
        /*if (UIInterfaceOrientationIsLandscape(previousOrigaton)) {
         index = cell1.rowNumber * 6 + ((cell2.rowNumber * 6 + 5)- cell1.rowNumber * 6)/2;
         row  = index /4;
         
         }else{
         index = cell1.rowNumber * 4 + ((cell2.rowNumber * 4 + 3)- cell1.rowNumber * 4)/2;
         row  = index /6;
         }
         NSLog(@"the index is %d and row is %d",index,row);
         if (row>=lastRow) {
         row = lastRow - 1;
         }
         if (row<0) {
         row = 0;
         }*/
        // [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    previousOrigaton = toInterfaceOrientation;
    timeSelectionsView.frame =[self setTheTimeSelectionsViewFrame:CGRectGetMinY(self.viewBar.frame)-185];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation{
    UIEdgeInsets insets = self.table.contentInset;
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        [self.table setContentInset:UIEdgeInsetsMake(53, insets.left, insets.bottom, insets.right)];
    }else{
        [self.table setContentInset:UIEdgeInsetsMake(65, insets.left, insets.bottom, insets.right)];
    }
}

-(void)countPhotosAndVideosCounts{
    photoCount = 0;
    videoCount = 0;
    for (Asset *ast in self.crwAssets) {
        if ([ast.videoType boolValue]) {
            videoCount += 1;
            [videoArray addObject:ast];
        }else{
            photoCount += 1;
            [photoArray addObject:ast];
        }
    }
}

-(void)refresh:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    
    NSMutableArray *a=[dic objectForKey:@"data"];
    //AmptsAlbum *ampt = [assets objectAtIndex:indexPath.row];
    for(int i=0;i<[a count];i++)
    {
        NSLog(@"%d",i);
        AmptsAlbum *am = (AmptsAlbum *)[a objectAtIndex:i];
        if([am.name isEqualToString:ta])
        {
            crwAssets=am.assetsList;
            [self.table reloadData];
            break;
        }
        
        // NSLog(@"assets:%@",am.assetsList);
    }
}

-(void)reloadTableData{
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    [self setTableViewEdge:oritation];
    [self.table reloadData];
}

#pragma mark -
#pragma mark Tagmode ButtonAction Methods
-(void)cancelTag{
    protecteds=NO;
    isEvent=NO;
    isFavorite=NO;
    NSString *a=NSLocalizedString(@"Tag", @"title");
    NSString *b=NSLocalizedString(@"Done", @"title");
    if([cancel.title isEqualToString:a])
    {
        cancel.style=UIBarButtonItemStyleDone;
        cancel.title=b;
        NSString *a=NSLocalizedString(@"Lock", @"title");
        if([self.lock.title isEqualToString:a])
        {
            mode = YES;
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.rightBarButtonItem = cancel;
            viewBar.hidden = YES;
            tagBar.hidden = NO;
            action=NO;
            [self.table reloadData];
        }
        else
        {
            
            [alert1 show];
        }
        
        
    }
    else
    {
        [name removeFromSuperview];
        cancel.style=UIBarButtonItemStyleBordered;
        cancel.title=a;
        tagBar.hidden = YES;
        viewBar.hidden = NO;
        mode = NO;
        action=YES;
        [self resetTags];
        [tagRow removeAllObjects];
        [UrlList removeAllObjects];
        [tagSelector.peopleList removeAllObjects];
        tagSelector.mypeople=nil;
        [self.navigationItem setTitle:ta];
        [self releasePersonPt];
        [self.table reloadData];
    }
}

-(IBAction)saveTags{
    NSString *b=NSLocalizedString(@"please select tag name", @"message");
    NSString *a=NSLocalizedString(@"note", @"button");
    NSString *c=NSLocalizedString(@"ok", @"button");
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:a
                          message:b
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:c,nil];
    [alert show]; 
    
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
    else if([tagRow count]==0)
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
        if([assertList count]>0)
        {
            for(int i=0;i<[assertList count];i++)
            {
                Asset *asset=[assertList objectAtIndex:i];
                [tagSelector deleteTag:asset];
            }
        }
        
        for(int i=0;i<[UrlList count];i++)
        {   
            Asset *asset = [UrlList objectAtIndex:i];
            [tagSelector saveTagAsset:asset];
        }
        [self cancelTag];
        
    }
    [UrlList removeAllObjects];
    [tagRow removeAllObjects];
    
}
-(IBAction)NoBodyButton
{[self releasePersonPt];
    as=YES;
    protecteds=NO;
    isEvent=NO;
    isFavorite=NO;
    [tagSelector.peopleList removeAllObjects];
    [tagRow removeAllObjects];
    favorite *fi=[dataSource.favoriteList objectAtIndex:0];
    People *p1=fi.people;
    [tagSelector.peopleList addObject:p1];
    NSDictionary *dic1= [NSDictionary dictionaryWithObjectsAndKeys:tagSelector.peopleList,@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic1]; 
}
-(IBAction)protectButton
{
    [self releasePersonPt];
    [tagSelector.peopleList removeAllObjects];
    [tagRow removeAllObjects];
    [UrlList removeAllObjects];
    protecteds=YES;
    as=NO;
    isEvent=NO;
    isFavorite=NO;
    self.navigationItem.title=@"给照片加密";   
    [self.table reloadData];
}

-(void)EditPhotoTag:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
    // tagSelector.mypeople.f
    if(isEvent)
    {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"事件:%@",[dic objectForKey:@"name"]]];
        event=[dic objectForKey:@"event"];
        NSLog(@"eventname:%@",event.name);
    }
    else
    {
        NSMutableArray *a=[dic objectForKey:@"name"];
        if([a count]!=0)
        {
            NSString *people=nil;
            People *po=[a objectAtIndex:0];
            if( po.firstName==nil)
            {
                people=[NSString stringWithFormat:@"%@",po.lastName];
            }
            else if(po.lastName==nil)
            {
                people=[NSString stringWithFormat:@"%@",po.firstName];
                
            }
            else
            {
                people=[NSString stringWithFormat:@"%@ %@",po.lastName,po.firstName];
            }
            
            if([a count]>1)
            {
                [self.navigationItem setTitle:[NSString stringWithFormat:@"选%@等%d人",people,[a count]]];
            }
            else
            {
                [self.navigationItem setTitle:[NSString stringWithFormat:@"选取%@",people]];
            }
            // name.frame = CGRectMake(0, 0,160, 40);
            //[tagBar addSubview:name];
        }
    }
    [tagRow removeAllObjects];
    [self.table reloadData];
}

-(IBAction)personpressed
{isEvent=NO;
    isFavorite=NO;
    [tagSelector.peopleList removeAllObjects];
    [tagRow removeAllObjects];
    if (!personPt) {
        CGFloat height = 80;
        CGFloat width =120;
        CGFloat x = CGRectGetMaxX(viewBar.frame)-width-5;
        CGFloat y = CGRectGetMinY(viewBar.frame)-height;
        if(personView){
            personView = nil;
        }
        personView = [[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
        personView.backgroundColor = [UIColor blackColor];
        personView.alpha=0.7;
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom]; 
        button1.frame = CGRectMake(10, 5, 100, 30);
        [button1 setBackgroundColor:[UIColor clearColor]]; 
        [button1 setTitle:@"Favorite" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom]; 
        button2.frame = CGRectMake(10, 40, 100, 30);
        [button2 setBackgroundColor:[UIColor clearColor]]; 
        [button2 setTitle:@"Phonebook" forState:UIControlStateNormal];
        //-(void)selectFromFavoriteNames;
        //-(void)selectFromAllNames;
        [button1 addTarget:self action:@selector(selectFromFavoriteNames) forControlEvents:UIControlEventTouchDown];
        [button2 addTarget:self action:@selector(selectFromAllNames) forControlEvents:UIControlEventTouchDown];
        
        //[personView.layer setCornerRadius:10.0];
        // [personView setClipsToBounds:YES]; 
        [personView addSubview:button1];
        [personView addSubview:button2];
        [self.view addSubview:personView];
        
        
        
    }else{
        if (personView && personView.superview != nil) {
            [personView removeFromSuperview];
        }
    }
    
    personPt = !personPt;
}
-(IBAction)Eventpressed
{  
    [self releasePersonPt];
    [tagSelector.peopleList removeAllObjects];
    [tagRow removeAllObjects];
    isEvent=YES;
    isFavorite=NO;
    EventTableView *evn=[[EventTableView alloc]init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:evn];
    [self.navigationController presentModalViewController:navController animated:YES];
}

-(IBAction)myfavorite
{
    [self releasePersonPt];
    NSLog(@"favorite");
    [tagSelector.peopleList removeAllObjects];
    [tagRow removeAllObjects];
    [UrlList removeAllObjects];
    protecteds=NO;
    as=NO;
    isEvent=NO;
    isFavorite=YES;
    self.navigationItem.title=@"标记My favorite";   
    [self.table reloadData];
}

-(void)selectFromFavoriteNames{
    [UrlList removeAllObjects];
    [tagRow removeAllObjects];
    tagSelector.add=@"NO";
    as=YES;
    protecteds=NO;
    [assertList removeAllObjects];
    [tagSelector.peopleList removeAllObjects];
    [self.navigationItem setTitle:ta];
    [tagSelector selectTagNameFromFavorites];
    if(personPt)
    {
        if (personView && personView.superview != nil) {
            [personView removeFromSuperview];
        }
        personPt=!personPt;
        
    }
}
-(void)selectFromAllNames{
    [tagRow removeAllObjects];
    [UrlList removeAllObjects];
    tagSelector.add=@"NO";
    as=YES;
    protecteds=NO;
    [assertList removeAllObjects];
    [tagSelector.peopleList removeAllObjects];
    [self.navigationItem setTitle:ta];
    [tagSelector selectTagNameFromContacts];
    if(personPt)
    {
        if (personView && personView.superview != nil) {
            [personView removeFromSuperview];
        }
        personPt=!personPt;
        
    }
    [self.table reloadData];
}

-(void)releasePersonPt
{
    if(personPt)
    {
        if (personView && personView.superview != nil) {
            [personView removeFromSuperview];
        }
        personPt=!personPt;
        
    }
    
}

-(IBAction)resetTags{
    [tagRow removeAllObjects];
    [UrlList removeAllObjects];
    [self.table reloadData];
}
#pragma mark -
#pragma mark Viewmode button methods
-(void)backButtonPressed
{
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self.navigationController popViewControllerAnimated:YES];
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"editplay" 
                                                           object:self 
                                                         userInfo:dic1];
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"add" 
                                                           object:self 
                                                         userInfo:dic2];
        
        
        
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
        NSString *password=[NSString stringWithFormat:@"%@",dataSource.password];
        if(dataSource.password==nil||password==nil||password.length==0)
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
            if(self.likeAssets.count != 0){
                [self.likeAssets removeAllObjects];
            }
            lockMode = YES;
            [lock setTitle:b];
        }
    }
    else
    {   
        [alert1 show];
    }
}


-(IBAction)playPhotos{
    if([side isEqualToString:@"favorite"])
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.crwAssets, @"assets", self.album.transitType, @"transition",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PeoplePlayPhoto" object:nil userInfo:dic]; 
        
    }
    else
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.crwAssets, @"assets", self.album.transitType, @"transition",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayPhoto" object:nil userInfo:dic]; 
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 7;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSString *name1=[datelist objectAtIndex:section];
    return name1;
}


-(void)configureTimeSelectionView{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
   // UIButton *button8 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button5.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button6.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button7.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
   // button8.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [button1 setTitle:@"Recent 2 week" forState:UIControlStateNormal];
    [button2 setTitle:@"Recent month" forState:UIControlStateNormal];
    [button3 setTitle:@"Recent 3 months" forState:UIControlStateNormal];
    [button4 setTitle:@"Recent 6 mohths" forState:UIControlStateNormal];
    [button5 setTitle:@"More than 6 months" forState:UIControlStateNormal];
    //[button6 setTitle:@"All" forState:UIControlStateNormal];
    [button6 setTitle:@"More than 1 year" forState:UIControlStateNormal];
    [button7 setTitle:@"All" forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(25, 10, 150, 20);
    button2.frame = CGRectMake(25, 35, 150, 20);
    button3.frame = CGRectMake(25, 60, 150, 20);
    button4.frame = CGRectMake(25, 85, 150, 20);
    button5.frame = CGRectMake(25, 110, 170, 20);
    button6.frame = CGRectMake(25, 135, 150, 20);
    button7.frame = CGRectMake(25, 160, 150, 20);
    //button8.frame = CGRectMake(25, 185, 150, 20);
    
    button1.tag = 1;
    button2.tag = 2;
    button3.tag = 3;
    button4.tag = 4;
    button5.tag = 5;
    button6.tag = 6;
    button7.tag = 7;
    //button8.tag = 8;
    
    [button1 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button3 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button4 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button5 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button6 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    [button7 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
   // [button8 addTarget:self action:@selector(selectTimeRange:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat y = CGRectGetMinY(viewBar.frame)-185;
    timeSelectionsView = [[UIView alloc]initWithFrame:[self setTheTimeSelectionsViewFrame:y]];
    timeSelectionsView.alpha = 0;
    timeSelectionsView.backgroundColor = [UIColor grayColor];
    [timeSelectionsView.layer setCornerRadius:8.0];
    [timeSelectionsView addSubview:button1];
    [timeSelectionsView addSubview:button2];
    [timeSelectionsView addSubview:button3];
    [timeSelectionsView addSubview:button4];
    [timeSelectionsView addSubview:button5];
    [timeSelectionsView addSubview:button6];
    [timeSelectionsView addSubview:button7];
   // [timeSelectionsView addSubview:button8];
    [timeSelectionsView addSubview:redImagView];
    [timeSelectionsView addSubview:greenImageView];
    
    [self.view addSubview:timeSelectionsView];
    
}

-(void)selectTimeRange:(id)sender{
    UIButton *bt = (UIButton *)sender;
    redImagView.frame = CGRectZero;
    NSPredicate* result =nil;
    NSDate *date = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    switch (bt.tag) {
        case 1:
            greenImageView.frame = CGRectMake(10, 15, 10, 10);
            [components setDay:-14];
            result=[NSPredicate predicateWithFormat:@"self.date>=%@ and self.date<=%@",[gregorian dateByAddingComponents:components toDate:date options:0],date];
            break;
        case 2:
            greenImageView.frame = CGRectMake(10, 40, 10, 10);
            [components setDay:-30];
            result=[NSPredicate predicateWithFormat:@"self.date>=%@ and self.date<=%@",[gregorian dateByAddingComponents:components toDate:date options:0],date];
            break;
        case 3:
            greenImageView.frame = CGRectMake(10, 65, 10, 10);
            [components setDay:-90];
            result=[NSPredicate predicateWithFormat:@"self.date>=%@ and self.date<=%@",[gregorian dateByAddingComponents:components toDate:date options:0],date];
            break;
        case 4:
            greenImageView.frame = CGRectMake(10, 90, 10, 10);
            [components setDay:-180];
            result=[NSPredicate predicateWithFormat:@"self.date>=%@ and self.date<=%@",[gregorian dateByAddingComponents:components toDate:date options:0],date];
            break;
//        case 5:
//            [components setDay:-180];
//            result=[NSPredicate predicateWithFormat:@"self.date>=%@ and self.date<=%@",[gregorian dateByAddingComponents:components toDate:date options:0],date];
//            greenImageView.frame = CGRectMake(10, 115, 10, 10);
//            break;
        case 5:
            greenImageView.frame = CGRectMake(10, 115, 10, 10);
            [components setDay:-180];
            result=[NSPredicate predicateWithFormat:@"self.date<%@",[gregorian dateByAddingComponents:components toDate:date options:0]];
            break;
        case 6:
            greenImageView.frame = CGRectMake(10, 140, 10, 10);
            [components setYear:-1];
            result=[NSPredicate predicateWithFormat:@"self.date<%@",[gregorian dateByAddingComponents:components toDate:date options:0]];
            break;
        default:
            greenImageView.frame = CGRectZero;
            redImagView.frame = CGRectMake(10, 165, 10, 10);
            break;
    }
    if (result) {
        if (photoType) {
            photoTableData = [photoArray filteredArrayUsingPredicate:result];
            timeSelectionPhoto = bt.tag;
        }else if(videoType){
            videoTableData = [videoArray filteredArrayUsingPredicate:result];
            timeSelectionVideo = bt.tag;
        }else{
            allTableData = [self.crwAssets filteredArrayUsingPredicate:result];
            timeSelectionAll = bt.tag;
        }
        
    }else{
        if (photoType) {
            if (![photoTableData isEqualToArray:photoArray]) {
                photoTableData = photoArray;
                timeSelectionPhoto = 0;
            }
        }else if(videoType){
            if (![videoTableData isEqualToArray:videoArray]) {
                videoTableData = videoArray;
                timeSelectionVideo = 0;
            }
            
        }else{
            if (![allTableData isEqualToArray:self.crwAssets]) {
                allTableData = self.crwAssets;
                timeSelectionAll = 0;
            }
        }
    }
    [self showTimeSelections];
    [self.table reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow-1 inSection:0];
    [table scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}




-(void)showTimeSelections{
    if (!timeBtPressed) {
        
        [UIView animateWithDuration:0.4 animations:^{
          timeSelectionsView.alpha = 1.0;
        }];
//        if (photoType) {
//            [self setTimeSelectionWithIndex:timeSelectionPhoto];
//
//        }else if(videoType){
//            [self setTimeSelectionWithIndex:timeSelectionVideo];
//      
//        }else{
//            [self setTimeSelectionWithIndex:timeSelectionAll];
//                  
//        }

        [timeSelectionsView.layer setOpaque:NO];
        timeSelectionsView.opaque = NO;
        
    }else{
        if (timeSelectionsView && timeSelectionsView.superview != nil) {
            [UIView animateWithDuration:0.4 animations:^{
                timeSelectionsView.alpha = 0;//frame = [self setTheTimeSelectionsViewFrame:CGRectGetMaxY(self.view.frame)];
                //[timeSelectionsView removeFromSuperview];
            }];
        }
    }
   
    timeBtPressed = !timeBtPressed;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"test" object:nil];
}
-(CGRect)setTheTimeSelectionsViewFrame:(CGFloat)y{
    CGFloat height = 185;
    CGFloat width = 190;
    CGFloat x = self.view.frame.origin.x;
    return CGRectMake(x, y, width, height);
}
-(void)showTypeSelections:(id)sender{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    if (seg.selectedSegmentIndex == 0) {
        photoType = NO;
        videoType = NO;
        [self setTimeSelectionWithIndex:timeSelectionAll];
    }else if(seg.selectedSegmentIndex == 1){
        photoType = YES;
        videoType = NO;
        [self setTimeSelectionWithIndex:timeSelectionPhoto];
    }else{
        photoType = NO;
        videoType = YES;
        [self setTimeSelectionWithIndex:timeSelectionVideo];
    }
    [self.table reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow-1 inSection:0];
    [table scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)setTimeSelectionWithIndex:(NSInteger)index{
    redImagView.frame = CGRectZero;
    switch (index) {
        case 1:
            greenImageView.frame = CGRectMake(10, 15, 10, 10);
            break;
        case 2:
            greenImageView.frame = CGRectMake(10, 40, 10, 10);
            break;
        case 3:
            greenImageView.frame = CGRectMake(10, 65, 10, 10);
            break;
        case 4:
            greenImageView.frame = CGRectMake(10, 90, 10, 10);
            break;
        case 5:
            greenImageView.frame = CGRectMake(10, 115, 10, 10);
            break;
        case 6:
            greenImageView.frame = CGRectMake(10, 140, 10, 10);
            break;
//        case 7:
//            greenImageView.frame = CGRectMake(10, 165, 10, 10);
//            break;
        default:
            greenImageView.frame = CGRectZero;
            redImagView.frame = CGRectMake(10, 165, 10, 10);
            break;
            
    }
}
#pragma mark -
#pragma mark UITableViewDataSource and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        if (photoType) {
            lastRow = ceil([photoTableData count]/6.0)+1;
        }else if(videoType){
            lastRow = ceil([videoTableData count]/6.0)+1;
        }else
            lastRow = ceil([allTableData count]/6.0)+1;
    }else
        if (photoType) {
            lastRow = ceil([photoTableData count]/4.0)+1;
        }else if(videoType){
            lastRow = ceil([videoTableData count]/4.0)+1;
        }else
            lastRow = ceil([allTableData count]/4.0)+1; 
    
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
    cell.selectionDelegate = self;
    cell.rowNumber = indexPath.row;
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row == lastRow - 1) {
        NSInteger vcount = 0;
        NSInteger pcount = 0;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.origin.x, 10, cell.frame.size.width, cell.frame.size.height-20)];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont fontWithName:@"Arial" size:20];
        if (photoType) {
            for (Asset *ast in photoTableData) {
                if (ast.videoType.boolValue) {
                    vcount += 1;
                }else{
                    pcount += 1;
                }
            }
            
        }else if(videoType){
            for (Asset *ast in videoTableData) {
                if (ast.videoType.boolValue) {
                    vcount += 1;
                }else{
                    pcount += 1;
                }
            }
        }else{
            for (Asset *ast in allTableData) {
                if (ast.videoType.boolValue) {
                    vcount += 1;
                }else{
                    pcount += 1;
                }
            }
        }
        
        label.text = [self configurateLastRowPhotoCount:pcount VideoCount:vcount];
        
        [cell addSubview:label];        
    }else{
        NSInteger loopCount = 0;
        if (UIInterfaceOrientationIsLandscape(oritation)) {
            loopCount = 6;
        }else
            loopCount = 4;
        NSMutableArray *assetsInRow = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 0; i<loopCount; i++) {
            NSInteger row = (indexPath.row*loopCount)+i;
            
            Asset *dbAsset = nil;
           if (videoType) {
                if (row < [videoTableData count]) {
                    dbAsset = [videoTableData objectAtIndex:row];
                }
            }else if(photoType){
                if (row < [photoTableData count]) {
                    dbAsset = [photoTableData objectAtIndex:row];
                }
                
            }else{
                if (row < [allTableData count]) {
                    dbAsset = [allTableData objectAtIndex:row];
                }
            }
            if (dbAsset != nil) {
                if(as==YES)
                {
                    if([tagSelector tag:dbAsset]==YES)
                    {
                        NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                        [tagRow addObject:selectedIndex];
                        //[cell checkTagSelection:selectedIndex];
                    }
                }
                if(protecteds==YES)
                {
                    if([dbAsset.isprotected boolValue])
                    {
                        NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                        [tagRow addObject:selectedIndex];
                    }
                }
                if(isEvent&&event!=nil)
                {
                    if(dbAsset.conEvent==event)
                    {
                        NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                        [tagRow addObject:selectedIndex];
                    }
                }
                if(isFavorite)
                {
                    if(dbAsset.isFavorite)
                    {
                        NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                        [tagRow addObject:selectedIndex];

                    }
                }
                [assetsInRow addObject:dbAsset];
            }
        }
        [cell displayThumbnails:assetsInRow count:loopCount action:action];
        
        if (!action) {
            for (NSInteger i = 0; i<loopCount; i++) {
                NSInteger row = (indexPath.row*loopCount)+i;
                if (row<[self.crwAssets count]) {
                    
                    NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                    if([tagRow containsObject:selectedIndex])
                    { 
                        [cell checkTagSelection:selectedIndex];
                        
                    }
                    
                }
            }
        }
    }
    return cell;
}

-(NSString *)configurateLastRowPhotoCount:(NSInteger)pCount VideoCount:(NSInteger)vCount{
    NSString *result = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    if (pCount == 0 && vCount == 0) {
        return result;
    }else if(pCount != 0 && vCount == 0){
        NSString *photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:pCount]];
        if (pCount == 1) {
            result = [NSString stringWithFormat:@"%@ Photo",photoNumber];
        }else{
            result = [NSString stringWithFormat:@"%@ Photos",photoNumber];
        }
    }else if(pCount == 0 && vCount != 0){
        NSString *videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:vCount]];
        if (vCount == 1) {
            result = [NSString stringWithFormat:@"%@ Video",videoNumber];
        }else{
            result = [NSString stringWithFormat:@"%@ Videos",videoNumber];
        }
    }else if(pCount != 0 && vCount != 0){
        NSString *photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:pCount]];
        NSString *videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:vCount]];
        if (pCount == 1 && vCount == 1) {
            result = [NSString stringWithFormat:@"%@ Photo, %@ Video",photoNumber,videoNumber];
        }else if(pCount == 1 && vCount != 1){
            result = [NSString stringWithFormat:@"%@ Photo, %@ Videos",photoNumber,videoNumber];
        }else if(pCount != 1 && vCount == 1){
            result = [NSString stringWithFormat:@"%@ Photos, %@ Video",photoNumber,videoNumber];
        }
        else{
            result = [NSString stringWithFormat:@"%@ Photos, %@ Videos",photoNumber,videoNumber];
        }
        
    }
    return result;
}

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index{
    NSString *row=[NSString stringWithFormat:@"%d",index];
    Asset *asset = nil;
    if (photoType) {
        asset = [photoTableData objectAtIndex:index];
    }else if(videoType){
        asset = [videoTableData objectAtIndex:index];
    }else{
        asset = [allTableData objectAtIndex:index];
    }
     
    if(action==YES)
    {
        self.navigationItem.title=ta;
        selectedRow = cell.rowNumber;
        NSMutableDictionary *dic = nil;
        if (photoType) {
            dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:photoTableData,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                   [NSNumber numberWithBool:lockMode],@"lock", self,@"thumbnailViewController",self.album.transitType,@"transition",nil];
        }else if(videoType){
            dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:videoTableData,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                   [NSNumber numberWithBool:lockMode],@"lock", self,@"thumbnailViewController",self.album.transitType,@"transition",nil];
        }else{
            dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:allTableData,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                                    [NSNumber numberWithBool:lockMode],@"lock", self,@"thumbnailViewController",self.album.transitType,@"transition",nil];
        }
        if([side isEqualToString:@"favorite"])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PeopleviewPhotos" object:nil userInfo:dic]; 
        }
        else
        {
       
        [[NSNotificationCenter defaultCenter]postNotificationName:@"viewPhotos" object:nil userInfo:dic]; 
        }
      
    }
    else
    {
       if([tagSelector.peopleList count]!=0)
       {
        as=NO;
        if([tagRow containsObject:row])
        {
            [UrlList removeObject:asset];
            [tagRow removeObject:row];
            [cell removeTag:row];
            [assertList addObject:asset];
            [tagSelector deleteTag:asset];
                      
        }
        else
        {   favorite *fi=[dataSource.favoriteList objectAtIndex:0];
            People *p1=fi.people;
            if([tagSelector.peopleList containsObject:p1])
            {
               BOOL b=[tagSelector selectAssert:asset];
               if(b==YES)
               {
                                     
               }
               else
               {    
                   if([tagSelector.peopleList count]>1)
                   {
                   }
                   else
                   {
                   [tagRow addObject:row];
                   [cell checkTagSelection:row];
                   [tagSelector save:asset];
                   [AddAssertList addObject:asset];  
                   }
               }
           }
            else
            {
                [tagRow addObject:row];
                [cell checkTagSelection:row];
                [tagSelector save:asset];
                [AddAssertList addObject:asset];
            }


        }
            
    }
        else if(protecteds==YES)
        {
         
            if([tagRow containsObject:row])
            {
                [UrlList removeObject:asset];
                [tagRow removeObject:row];
                [cell removeTag:row];
                asset.isprotected=[NSNumber numberWithBool:NO];
                asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]-1];
                
            }
            else
            {   
                [tagRow addObject:row];
                [cell checkTagSelection:row];
                asset.isprotected=[NSNumber numberWithBool:YES];
                asset.numPeopleTag=[NSNumber numberWithInt:[asset.numPeopleTag intValue]+1];
        }
            [dataSource.coreData saveContext];
        }
        else if(isEvent)
        {
            //EventRule  *eventRule= [NSEntityDescription insertNewObjectForEntityForName:@"EventRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
           // eventRule.conEvent=event;
            if([tagRow containsObject:row])
            {
                [tagRow removeObject:row];
                [cell removeTag:row];
                //[asset re]
                asset.conEvent=nil;
            }
            else
            {
            asset.conEvent=event;
            
            NSLog(@"assert.name:%@",asset.conEvent.name);
            [tagRow addObject:row];
            [cell checkTagSelection:row];
            }
            [dataSource.coreData saveContext];
        }
        else if(isFavorite)
        {
            if([tagRow containsObject:row])
            {
                [tagRow removeObject:row];
                [cell removeTag:row];
                asset.isFavorite=nil;
                //[asset re]
               
            }
            else
            {
                asset.isFavorite=[NSNumber numberWithBool:YES];
                
                NSLog(@"assert.name:%@",asset.conEvent.name);
                [tagRow addObject:row];
                [cell checkTagSelection:row];
            }
           [dataSource.coreData saveContext];
        }
       else
       {
           NSString *b=NSLocalizedString(@"please select tag name", @"message");
           NSString *a=NSLocalizedString(@"note", @"button");
           NSString *c=NSLocalizedString(@"ok", @"button");
           UIAlertView *alert = [[UIAlertView alloc]
                                 initWithTitle:a
                                 message:b
                                 delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:c,nil];
           [alert show]; 
           
       }

    }
      }


    
    

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (ThumbnailCell *cell in self.table.visibleCells) {
        [cell clearSelection];
    }
}
#pragma  mark -
#pragma  mark AlerView delegate method
-(void)alertView:(UIAlertView *)alert11 didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *pass=[NSString stringWithFormat:@"%@",dataSource.password];
    NSString *a=NSLocalizedString(@"Lock", @"title");
    NSString *b=NSLocalizedString(@"note", @"title");
    NSString *c=NSLocalizedString(@"ok", @"title");
    NSString *d=NSLocalizedString(@"The password is wrong", @"title");
    NSString *e=NSLocalizedString(@"UnLock", @"title");
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
                    self.lock.title=e;
                    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults]; 
                    dataSource.password=[defaults objectForKey:@"name_preference"];
                    lockMode = YES;
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
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeLockModeInDetailView" object:nil];
                    NSLog(@"pass the lock");
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
#pragma  mark -
#pragma  mark Memory management
-(void)viewDidUnload{
    self.table = nil;
    self.crwAssets = nil;
    self.viewBar = nil;
    self.tagBar = nil;
    [super viewDidUnload];
}


@end
