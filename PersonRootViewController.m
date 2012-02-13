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
    TagManagementController *tm = [[TagManagementController alloc]init];
    [self pushViewController:tm animated:NO];
}
-(void)pushPeopleAssetsTablePicker:(NSNotification *)note
{
    NSDictionary *dic = [note userInfo];
    
    NSMutableArray *assets = [dic objectForKey:@"myAssets"];
   // Album *receivedAlbum = [dic objectForKey:@"album"];
    AssetTablePicker *ap = [[AssetTablePicker alloc]initWithNibName:@"AssetTablePicker" bundle:[NSBundle mainBundle]];
    ap.hidesBottomBarWhenPushed = YES;
    ap.crwAssets=assets;
    ap.album =nil;
    [self pushViewController:ap animated:YES];
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
