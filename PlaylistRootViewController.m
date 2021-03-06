//
//  PlaylistRootViewController.m
//  PhotoApp
//
//  Created by Andy on 12/1/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PlaylistRootViewController.h"
#import "AlbumController.h"
#import "AssetTablePicker.h"
#import "PhotoViewController.h"
#import "Asset.h"
#import "AlbumDataSource.h"
#import "TagManagementController.h"
#import "PhotoAppDelegate.h"
#import "Playlist.h"
@implementation PlaylistRootViewController
@synthesize activityView;

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
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.title= @"Loading....";
    UIActivityIndicatorView *_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView = _activityView;
    CGRect rect = [UIScreen mainScreen].bounds;
    activityView.frame = CGRectMake(( CGRectGetMaxX(rect)/ 2) - 15.0f, (CGRectGetMaxY(rect)/2) - 15.0f , 30.0f, 30.0f);
    activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:activityView];
    [activityView startAnimating];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushAssetsTablePicker:) name:@"pushThumbnailView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPhotosBrowser:) name:@"viewPhotos" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playPhotoWithAnimation:) name:@"PlayPhoto" object:nil];
}

-(void)pushAssetsTablePicker:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
   
     NSMutableArray *__weak assets = [dic objectForKey:@"myAssets"];
    Album *receivedAlbum = [dic objectForKey:@"album"];
    AssetTablePicker *ap = [[AssetTablePicker alloc]initWithNibName:@"AssetTablePicker" bundle:[NSBundle mainBundle]];
    ap.hidesBottomBarWhenPushed = YES;
    ap.crwAssets=assets;
    ap.album = receivedAlbum;
    ap.firstLoad = YES;
    ap.navigationItem.title = [dic objectForKey:@"title"];
    ap.ta=[dic objectForKey:@"title"];
    [self pushViewController:ap animated:YES];
    ap = nil;
}

-(void)pushPhotosBrowser:(NSNotification *)note{
    NSDictionary *dicOfPhotoViewer = [note userInfo];
    NSString *key = [dicOfPhotoViewer objectForKey:@"selectIndex"];
    NSMutableArray *assets = [dicOfPhotoViewer valueForKey:@"assets"];
    NSNumber *num = [dicOfPhotoViewer valueForKey:@"lock"];
    BOOL lock = num.boolValue;
    NSString *transtion  =  [dicOfPhotoViewer valueForKey:@"transition"];
    PhotoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    AlbumDataSource *dataSourec =   delegate.dataSource;

    PhotoViewController *pc = [[PhotoViewController alloc]init];
    pc.assetTablePicker = [dicOfPhotoViewer objectForKey:@"thumbnailViewController"];
    pc.playPhotoTransition = transtion;
    pc.lockMode = lock;
    pc.playlist.storeAssets = assets;
    pc.playlist.assets = dataSourec.deviceAssets.deviceAssetsList;
    pc.currentPageIndex = [key integerValue];
    [self pushViewController:pc animated:YES];
    pc = nil;
}

-(void)playPhotoWithAnimation:(NSNotification *)note{
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
