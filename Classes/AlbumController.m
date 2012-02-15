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
#import "Asset.h"
@implementation AlbumController

@synthesize tableView;


#pragma mark -
#pragma mark UIViewController method
-(void)viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
}

-(void)viewWillDisappear:(BOOL)animated
{       
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}

-(void)viewDidLoad
{  
    PhotoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    dataSource = appDelegate.dataSource;
    assets = dataSource.assetsBook; 
    [self setWantsFullScreenLayout:YES];
	[self.navigationItem setTitle:@"PlayList"];
    
    NSString *bu=NSLocalizedString(@"Edit", @"button");
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    addButon=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleAdd:)];
    
    editButton = [[UIBarButtonItem alloc] initWithTitle:bu style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit:)];
    
    addButon.style = UIBarButtonItemStyleBordered;
    editButton.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.rightBarButtonItem = editButton;
   // self.navigationItem.rightBarButtonItem = addButon;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabled:) name:@"addplay" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editTable) name:@"editplay" object:nil];
    
}
-(void)tabled:(NSNotification *)note{
   
    [self.tableView setEditing:!self.tableView.editing animated:NO];
    self.navigationItem.leftBarButtonItem=nil;
    NSString *d=NSLocalizedString(@"Edit", @"button");
    editButton.title = d;
    editButton.style=UIBarButtonItemStyleBordered;
    NSDictionary *dic = [note userInfo];
    Album *a=[dic objectForKey:@"name"];
    if(a!=nil)
    {
       // PhotoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        //dataSource = appDelegate.dataSource;
        [dataSource fresh:a index:index];
        assets = dataSource.assetsBook; 
        [tableView reloadData];
    }
    
}
-(void)editTable
{
    [dataSource refresh];
    assets=dataSource.assetsBook;
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
        editButton.style=UIBarButtonItemStyleBordered;
        editButton.title = d;
        self.navigationItem.leftBarButtonItem=nil;
        
    }
    else{
        editButton.style=UIBarButtonItemStyleDone;
        self.navigationItem.leftBarButtonItem = addButon;
        editButton.title = c;
    }

   [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.tableView.allowsSelectionDuringEditing=YES;
  
    
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Disable editing for 1st row in section
    return (indexPath.row == 0 || indexPath.row == 1) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

-(IBAction)toggleAdd:(id)sender
{
    PlaylistDetailController *detailController = [[PlaylistDetailController alloc]initWithNibName:@"PlaylistDetailController" bundle:[NSBundle mainBundle]];
    detailController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:detailController animated:YES];
    index=-1;
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
    Asset *as = [am.assetsList lastObject];
    if (as == nil) {
        cell.imageView.image = [UIImage imageNamed:@"empty1.png"]; 
    }else{
        CGImageRef imgRef = [[dataSource.deviceAssets.deviceAssetsList objectForKey:as.url] thumbnail];
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        cell.imageView.image = image; 
    }
    if(indexPath.row==1)
    {
        cell.textLabel.textColor=[UIColor redColor];
    }
    if (am.num != 0) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *countNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:am.num]];
         if([am.object isEqualToString:@"Photo"])
         {
         cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) ^照片图像^",am.name, countNumber];
         }
         else
         {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",am.name, countNumber];
         }
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@",am.name];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    return cell;
    
}
-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.editing) { 
        NSLog(@"3");
        NSString *a=NSLocalizedString(@"note", @"title");
        NSString *b=NSLocalizedString(@"Inherent members, can not be edited", @"title");
        NSString *c=NSLocalizedString(@"ok", @"title");
        PlaylistDetailController *detailController = [[PlaylistDetailController alloc]initWithNibName:@"PlaylistDetailController" bundle:[NSBundle mainBundle]];
        detailController.bum = [self getAlbumInRow:indexPath.row];
        detailController.hidesBottomBarWhenPushed = YES;
        if(detailController.bum!=nil)
        {
            [self.navigationController pushViewController:detailController animated:YES];
            index=indexPath.row;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:a
                                  message:b
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:c,nil];
            [alert show];
            
        }
        
        
        
        
    }
    else
    {
        AmptsAlbum *ampt = [assets objectAtIndex:indexPath.row];
        NSMutableArray *WE = ampt.assetsList;
        Album *album = [self getAlbumInRow:indexPath.row];
        NSLog(@"album:%@",album.chooseType);
        NSMutableDictionary *dic = nil;
        if (album == nil) {
            dic  = [NSMutableDictionary dictionaryWithObjectsAndKeys:WE, @"myAssets", ampt.name,@"title", nil];
        }else{
            dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:album, @"album", WE, @"myAssets",ampt.name,@"title", nil];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushThumbnailView" object:nil userInfo:dic];
        
        
        
    }
     [table deselectRowAtIndexPath:indexPath animated:YES];
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
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row>1)
    {
        return YES;
    }
    return NO;
}
#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   
    AmptsAlbum *fa=[assets objectAtIndex:indexPath.row];
    NSLog(@"asserts:%@",assets);
    
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
    [self.tableView reloadData];

    
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{ 
    NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
    if(toRow>1)
    {
        id object=[assets objectAtIndex:fromRow];
        [assets removeObjectAtIndex:fromRow];
        [assets insertObject:object atIndex:toRow];
    }
    [self.tableView reloadData];
} 

#pragma mark -
#pragma mark memory method

@end
