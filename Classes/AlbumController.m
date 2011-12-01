//
//  AlbumController.m
//  PhotoApp
//
//  Created by apple on 11-10-18.
//  Copyright 2011年 chinarewards. All rights reserved.
//

#import "AlbumController.h"
#import "AssetTablePicker.h"
#import "PlaylistDetailController.h"
#import "AlbumClass.h"
#import "AssetProducer.h"
#import "PlaylistProducer.h"


@implementation AlbumController

@synthesize tableView;
@synthesize playList;
@synthesize selectedAlbum;

#pragma mark -
#pragma mark UIViewController method
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
}

-(void)viewWillDisappear:(BOOL)animated
{       
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}

-(void)viewDidLoad
{
    AssetProducer *p = [[AssetProducer alloc]initWithAssetsLibrary: [[ALAssetsLibrary alloc] init]];
    
    self.playList = [[PlaylistProducer alloc]initWithAssetProcuder:p];
    

    [self setWantsFullScreenLayout:YES];
	[self.navigationItem setTitle:@"Loading..."];
    
    NSString *bu=NSLocalizedString(@"Edit", @"button");
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
    
    editButton = [[UIBarButtonItem alloc] initWithTitle:bu style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    
    addButon.style = UIBarButtonItemStyleBordered;
    editButton.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = addButon;
    
    [addButon release];
    [editButton release];
    
   
}


#pragma mark -
#pragma mark TableView delegate method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 

    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
        AlbumClass *al = [self.playList.playlists objectAtIndex:indexPath.row];
       
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",al.albumName,al.photoCount];

       cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}
-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    AssetTablePicker *assetPicker = [[AssetTablePicker alloc]initWithNibName:@"AssetTablePicker" bundle:[NSBundle mainBundle]];
    assetPicker.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:assetPicker animated:YES];
    [assetPicker release];
    [table deselectRowAtIndexPath:indexPath animated:YES];

    
    
    self.selectedAlbum = [self.playList.playlists objectAtIndex: indexPath.row];
    //[[UIApplication sharedApplication]sendAction:@selector(albumSelected:) to:nil from:self forEvent:nil];
    
}

- (void) albumSelected: (id) sender {
    NSLog(@"Album Selected");
    
}

#pragma mark -
#pragma mark memory method

- (void)dealloc {
    
    [playList release];
    [tableView release];

    [super dealloc];
}
@end
