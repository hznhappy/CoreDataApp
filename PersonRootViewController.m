//
//  PersonRootViewController.m
//  PhotoApp
//
//  Created by Andy on 12/1/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PersonRootViewController.h"
#import "TagManagementController.h"
#import "AssetTablePicker.h"
#import "PhotoViewController.h"
#import "PhotoAppDelegate.h"
#import "Playlist.h"

@implementation PersonRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPeopleAssetsTablePicker:) name:@"pushPeopleThumbnailView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPeoplePhotosBrowser:) name:@"PeopleviewPhotos" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playPeoplePhotoWithAnimation:) name:@"PeoplePlayPhoto" object:nil];
    TagManagementController *tm = [[TagManagementController alloc]init];
    [self pushViewController:tm animated:NO];
}
-(void)pushPeopleAssetsTablePicker:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
      NSMutableArray *__weak assets = [dic objectForKey:@"myAssets"];
    NSLog(@"assets:%d",[assets count]);
   // NSMutableArray *assets = [dic objectForKey:@"myAssets"];
   // Album *receivedAlbum = [dic objectForKey:@"album"];
    AssetTablePicker *ap = [[AssetTablePicker alloc]initWithNibName:@"AssetTablePicker" bundle:[NSBundle mainBundle]];
    ap.hidesBottomBarWhenPushed = YES;
    ap.crwAssets=assets;
    ap.album =nil;
    ap.side=@"favorite";
    ap.firstLoad=YES;
    ap.navigationItem.title = [dic objectForKey:@"title"];
    [self pushViewController:ap animated:YES];
    ap = nil;
}
-(void)pushPeoplePhotosBrowser:(NSNotification *)note
{
    NSDictionary *dicOfPhotoViewer = [note userInfo];
    NSString *key = [dicOfPhotoViewer objectForKey:@"selectIndex"];
    NSMutableArray *assets = [dicOfPhotoViewer valueForKey:@"assets"];
    NSNumber *num = [dicOfPhotoViewer valueForKey:@"lock"];
    BOOL lock = num.boolValue;
    NSString *transtion  =  [dicOfPhotoViewer valueForKey:@"transition"];
    PhotoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    AlbumDataSource *dataSourec =   delegate.dataSource;
    
    PhotoViewController *pc = [[PhotoViewController alloc]init];
    pc.assetTablePicker = [dicOfPhotoViewer objectForKey:@"pushPeopleThumbnailView"];
    pc.playPhotoTransition = transtion;
    pc.lockMode = lock;
    pc.playlist.storeAssets = assets;
    pc.playlist.assets = dataSourec.deviceAssets.deviceAssetsList;
    pc.currentPageIndex = [key integerValue];
    [self pushViewController:pc animated:YES];
    pc = nil;
    
}
-(void)playPeoplePhotoWithAnimation:(NSNotification *)note
{
    NSLog(@"play video");
    NSDictionary *dic = [note userInfo];
    NSMutableArray *assets = [dic valueForKey:@"assets"];
    NSString *transtion  =  [dic valueForKey:@"transition"];
    PhotoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    AlbumDataSource *dataSourec =   delegate.dataSource;
    PhotoViewController *playPhotoController = [[PhotoViewController alloc]initWithBool:YES];
    playPhotoController.playlist.storeAssets = assets;
    playPhotoController.playlist.assets = dataSourec.deviceAssets.deviceAssetsList;
    playPhotoController.currentPageIndex = 0;
    playPhotoController.playPhotoTransition = transtion;
    [playPhotoController fireTimer];
    [self pushViewController:playPhotoController animated:YES];
    playPhotoController = nil;

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
