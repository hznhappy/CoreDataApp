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
@implementation AssetTablePicker
@synthesize crwAssets;
@synthesize table;
@synthesize viewBar,tagBar;
@synthesize UrlList;
@synthesize lock;
@synthesize operations;
@synthesize tagRow;
@synthesize album;
@synthesize likeAssets;
@synthesize assertList;
@synthesize AddAssertList;
@synthesize action;
@synthesize side;
#pragma mark -
#pragma mark UIViewController Methods

-(void)viewDidLoad {
     name= [UIButton buttonWithType:UIButtonTypeCustom];
    PhotoAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    dataSource = appDelegate.dataSource;
    if(album==nil)
    {
        lock.enabled=NO;

        
    }
    lockMode = NO;
    done = YES;
    action=YES;
    as=NO;
    mode = NO;
    tagBar.hidden = YES;
    photoCount = 0;
    videoCount = 0;
    for (Asset *ast in self.crwAssets) {
        if ([ast.videoType boolValue]) {
            videoCount += 1;
        }else{
            photoCount += 1;
        }
    }
    tagSelector = [[TagSelector alloc]initWithViewController:self];
    
    self.tagRow=[[NSMutableArray alloc]init];
    self.UrlList=[[NSMutableArray alloc] init];
    assertList=[[NSMutableArray alloc]init];
    AddAssertList=[[NSMutableArray alloc]init];
    inAssert=[[NSMutableArray alloc]init];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EditPhotoTag:)name:@"EditPhotoTag" object:nil];
   // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:@"reloadTableData" object:nil];
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
-(void)EditPhotoTag:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
   // tagSelector.mypeople.f
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
        people=[NSString stringWithFormat:@"%@ %@",po.firstName,po.lastName];
    }
    if([a count]>1)
    {
    [name setTitle:[NSString stringWithFormat:@"选%@等%d人",people,[a count]] forState:UIControlStateNormal];
    }
    else
    {
        [name setTitle:[NSString stringWithFormat:@"选取%@",people] forState:UIControlStateNormal];
    }
    name.frame = CGRectMake(0, 0,160, 40);
    [tagBar addSubview:name];
    }
    [self.tagRow removeAllObjects];
    [self.table reloadData];
}

/*-(void)reloadTableData{
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    //[self resetTableContentInset];
    [self.table reloadData];
}*/
-(void)backButtonPressed
{
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
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
    [self.tagRow removeAllObjects];
    [self.UrlList removeAllObjects];
    tagSelector.mypeople=nil;
    [self.table reloadData];
    }
}

-(IBAction)actionButtonPressed{
    NSString *a=NSLocalizedString(@"Lock", @"title");
    if([self.lock.title isEqualToString:a])
    {
        mode = YES;
       // save.enabled=YES;
        //reset.enabled=YES;
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
        
        for(int i=0;i<[self.UrlList count];i++)
        {   
            Asset *asset = [self.UrlList objectAtIndex:i];
            [tagSelector saveTagAsset:asset];
        }
         [self cancelTag];
        
    }
    [self.UrlList removeAllObjects];
    [self.tagRow removeAllObjects];
      
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
    as=YES;
    [assertList removeAllObjects];
    [tagSelector selectTagNameFromFavorites];
}
-(IBAction)selectFromAllNames{
    [self.tagRow removeAllObjects];
    [self.UrlList removeAllObjects];
    tagSelector.add=@"NO";
    as=YES;
    [assertList removeAllObjects];
    [tagSelector selectTagNameFromContacts];
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
        if (photoCount != 0 || videoCount != 0) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.origin.x, 10, cell.frame.size.width, cell.frame.size.height-20)];
            label.textAlignment = UITextAlignmentCenter;
            label.textColor = [UIColor grayColor];
            label.font = [UIFont fontWithName:@"Arial" size:20];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
            if (photoCount == 0) {
                NSString *videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:videoCount]];
                if (videoCount == 1) {
                    label.text = [NSString stringWithFormat:@"%@ Video",videoNumber];
                }else{
                    label.text = [NSString stringWithFormat:@"%@ Videos",videoNumber];
                }
            }else if(videoCount == 0){
                NSString *photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:photoCount]];
                if (photoCount == 1) {
                    label.text = [NSString stringWithFormat:@"%@ Photo",photoNumber];
                }else{
                    label.text = [NSString stringWithFormat:@"%@ Photos",photoNumber];
                }
            }else{
                NSString *photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:photoCount]];
                NSString *videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:videoCount]];
                if (photoCount == 1 && videoCount == 1) {
                    label.text = [NSString stringWithFormat:@"%@ Photo, %@ Video",photoNumber,videoNumber];
                }else if(photoCount == 1 && videoCount != 1){
                    label.text = [NSString stringWithFormat:@"%@ Photo, %@ Videos",photoNumber,videoNumber];
                }else if(photoCount != 1 && videoCount == 1){
                    label.text = [NSString stringWithFormat:@"%@ Photos, %@ Video",photoNumber,videoNumber];
                }
                else{
                    label.text = [NSString stringWithFormat:@"%@ Photos, %@ Videos",photoNumber,videoNumber];
                }
            }
             [cell addSubview:label]; 
        }
        
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
                if(as==YES)
                {
                if([tagSelector tag:dbAsset]==YES)
                {
                    NSString *selectedIndex = [NSString stringWithFormat:@"%d",row];
                    [tagRow addObject:selectedIndex];
                    //[cell checkTagSelection:selectedIndex];
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
        NSLog(@"action");
        if([side isEqualToString:@"favorite"])
        {
            NSLog(@"people");
            selectedRow = cell.rowNumber;
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.crwAssets,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                                        [NSNumber numberWithBool:lockMode],@"lock", self,@"pushPeopleThumbnailView",self.album.transitType,@"transition",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PeopleviewPhotos" object:nil userInfo:dic]; 
        }
        else
        {
        selectedRow = cell.rowNumber;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.crwAssets,@"assets",[NSString stringWithFormat:@"%d",index],@"selectIndex",
                                    [NSNumber numberWithBool:lockMode],@"lock", self,@"thumbnailViewController",self.album.transitType,@"transition",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"viewPhotos" object:nil userInfo:dic]; 
        }
      
    }
    else
    {
       if([tagSelector.peopleList count]!=0)
       {
        as=NO;
        if([self.tagRow containsObject:row])
        {
            [self.UrlList removeObject:asset];
            [self.tagRow removeObject:row];
            NSString *selectedIndex = [NSString stringWithFormat:@"%d",index];
            [cell removeTag:selectedIndex];
            [assertList addObject:asset];
            [tagSelector deleteTag:asset];
            //[self.table reloadData];
                      
        }
        else
        {  
            [self.tagRow addObject:row];
            NSString *selectedIndex = [NSString stringWithFormat:@"%d",index];
            [cell checkTagSelection:selectedIndex];
            [tagSelector save:asset];
            [AddAssertList addObject:asset];
                   
                    
                }
            
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
    [super viewDidUnload];
}


- (void)dealloc
{   
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
