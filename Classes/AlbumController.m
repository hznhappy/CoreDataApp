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
#import "PhotoAppDelegate.h"
#import "AmptsAlbum.h"
#import "Album.h"
@implementation AlbumController

@synthesize tableView;


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
   
    [self tabled];
    [self setWantsFullScreenLayout:YES];
	[self.navigationItem setTitle:@"PlayList"];
    
    NSString *bu=NSLocalizedString(@"Edit", @"button");
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
    
    editButton = [[UIBarButtonItem alloc] initWithTitle:bu style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    
    addButon.style = UIBarButtonItemStyleBordered;
    editButton.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = addButon;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabled) name:@"addplay" object:nil];
    
}
-(void)tabled
{
    PhotoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    dataSource = appDelegate.dataSource;
    [dataSource refresh];
    assets = dataSource.assetsBook; 
    [tableView reloadData];
}
-(void)addcount
{ 
    [self.tableView reloadData];
}


-(IBAction)toggleEdit:(id)sender
{
    NSString *c=NSLocalizedString(@"Done", @"button");
    NSString *d=NSLocalizedString(@"Edit", @"button");
    if (self.tableView.editing) {
        editButton.title = d;
    }
    else{
        
        editButton.title = c;
    }
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
}

-(IBAction)toggleAdd:(id)sender
{
    PlaylistDetailController *detailController = [[PlaylistDetailController alloc]initWithNibName:@"PlaylistDetailController" bundle:[NSBundle mainBundle]];
    detailController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark -
#pragma mark TableView delegate method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    
    return [assets count];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    AmptsAlbum *am = (AmptsAlbum *)[assets objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",am.name, am.num];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;    
    return cell;
}
-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *WE=[(AmptsAlbum *)[assets objectAtIndex:indexPath.row]assetsList];
    NSLog(@"%d is we",WE.count);
    Album *album = [self getAlbumInRow:indexPath.row];
    NSMutableDictionary *dic = nil;
    if (album == nil) {
        dic  = [NSMutableDictionary dictionaryWithObjectsAndKeys:WE, @"myAssets", nil];
    }else{
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:album, @"album", WE, @"myAssets", nil];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pushThumbnailView" object:nil userInfo:dic];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    PlaylistDetailController *detailController = [[PlaylistDetailController alloc]initWithNibName:@"PlaylistDetailController" bundle:[NSBundle mainBundle]];
    detailController.al = [self getAlbumInRow:indexPath.row];
    detailController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailController animated:YES];

    
}
-(Album *)getAlbumInRow:(NSInteger)row{
    AmptsAlbum *am = (AmptsAlbum *)[assets objectAtIndex:row];
    
    NSArray *albums=[dataSource simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    
    for(Album *alb in albums)
    {
        if ([alb.objectID isEqual:am.alblumId]) {
            
            return alb;
        }
    }
    return nil;
}
#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{     AmptsAlbum *fa=[assets objectAtIndex:indexPath.row];
    
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        NSArray *album = [dataSource simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:NO];
        for (Album *al in album) {
            if ([[al objectID] isEqual:fa.alblumId] ) {
                [dataSource.coreData.managedObjectContext deleteObject:al];
                
                [assets removeObject:fa];

            }
        }
            }
    [dataSource.coreData saveContext];
    [self tabled];

    
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{  
    
} 

#pragma mark -
#pragma mark memory method

@end
