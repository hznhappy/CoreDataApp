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
#import "PhotoSource.h"
#import "Asset.h"
#import "AlbumDataSource.h"
#import "tagManagementController.h"
#import "PhotoAppDelegate.h"
@implementation PlaylistRootViewController
 static NSString* const kFileName=@"output.mov";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)dealloc
{
    [activityView release];
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
   self.navigationItem.title= @"Loading....";
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect rect = [UIScreen mainScreen].bounds;
    activityView.frame = CGRectMake(( CGRectGetMaxX(rect)/ 2) - 15.0f, (CGRectGetMaxY(rect)/2) - 15.0f , 30.0f, 30.0f);
    activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:activityView];
    [activityView startAnimating];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playlistAlbum) name:@"album" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushAssetsTablePicker:) name:@"pushThumbnailView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPhotosBrowser:) name:@"viewPhotos" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playPhotoWithAnimation:) name:@"PlayPhoto" object:nil];
}

-(void)playlistAlbum{
    AlbumController *al = [[AlbumController alloc]initWithNibName:@"AlbumController" bundle:[NSBundle mainBundle]];
    [self pushViewController:al animated:YES];
    [al release];
    [activityView stopAnimating];
}
-(void)pushAssetsTablePicker:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSMutableArray *assets = [[NSMutableArray alloc]init];
    assets = [dic valueForKey:@"assets"];
    
//    NSMutableArray *alassets = [[NSMutableArray alloc]init];
//    PhotoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    AlbumDataSource *dataSourec =   delegate.dataSource;
//    for (Asset *asset in assets) {
//        [alassets addObject:[dataSourec getAsset:asset.url]];
//    }
    
    AssetTablePicker *ap = [[AssetTablePicker alloc]initWithNibName:@"AssetTablePicker" bundle:[NSBundle mainBundle]];
    ap.hidesBottomBarWhenPushed = YES;
    ap.crwAssets=assets;
    NSLog(@"APassets:%d",[ap.crwAssets count]);
    ap.PLAYID=[dic valueForKey:@"ID"];
    [assets release];
    //[alassets release];
    
    [self pushViewController:ap animated:YES];
    [ap release];    
}

-(void)pushPhotosBrowser:(NSNotification *)note{
    NSDictionary *dicOfPhotoViewer = [note userInfo];
    NSString *key = [[dicOfPhotoViewer allKeys] objectAtIndex:0];
    NSMutableArray *assets = [dicOfPhotoViewer valueForKey:key];
    NSMutableArray *photoSource  = [[NSMutableArray alloc]init];
    PhotoAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    AlbumDataSource *dataSourec =   delegate.dataSource;
    for (Asset *as in assets) {
        [photoSource addObject:[PhotoSource PhotoWithAsset:[dataSourec getAsset:as.url]]];
    }
    PhotoViewController *pc = [[PhotoViewController alloc]initWithPhotoSource:photoSource currentPage:[key integerValue]];
    //PhotosBrowser *pc = [[PhotosBrowser alloc]initWithPhotoSource:assets currentPage:[key integerValue]];
    [self pushViewController:pc animated:YES];
    [pc release];
    [photoSource release];
}

-(void)playPhotoWithAnimation:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSMutableArray *assets = [dic valueForKey:@"0"];
    NSString *transtion = [dic valueForKey:@"animation"];
    NSMutableArray *animatePhotos  = [[NSMutableArray alloc]init];
    for (id as in assets) {
        [animatePhotos addObject:[PhotoSource PhotoWithAsset:as]];
    }

    PhotoViewController *playPhotoController = [[PhotoViewController alloc]initWithPhotoSource:animatePhotos currentPage:0];
    [playPhotoController fireTimer:transtion];
    [self pushViewController:playPhotoController animated:YES];
    [playPhotoController release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
