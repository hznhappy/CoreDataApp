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
    [self settableViewEdge:[UIApplication sharedApplication].statusBarOrientation];
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
    
    NSArray *tmp=[dataSource simpleQuery:@"Setting" predicate:nil sortField:nil sortOrder:YES];
    if(tmp.count!=0)
    {
        setting=[tmp objectAtIndex:0];
    }

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabled:) name:@"addplay" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editTable) name:@"editplay" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:@"refresh" object:nil];

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self settableViewEdge:toInterfaceOrientation];
    
}

-(void)settableViewEdge:(UIInterfaceOrientation)oritation{
    UIEdgeInsets insets = self.tableView.contentInset;
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        [self.tableView setContentInset:UIEdgeInsetsMake(53, insets.left, insets.bottom, insets.right)];
    }else{
        [self.tableView setContentInset:UIEdgeInsetsMake(63, insets.left, insets.bottom, insets.right)];
    }
    [self.tableView reloadData];
}

-(void)tabled:(NSNotification *)note{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    cell1.selectionStyle=UITableViewCellSelectionStyleBlue;
    [self.tableView setEditing:!self.tableView.editing animated:NO];
    self.navigationItem.leftBarButtonItem=nil;
    NSString *d=NSLocalizedString(@"Edit", @"button");
    editButton.title = d;
    editButton.style=UIBarButtonItemStyleBordered;
    NSDictionary *dic = [note userInfo];
    Album *a=[dic objectForKey:@"name"];
    if(a!=nil)
    {
        [dataSource fresh:a index:index];
        assets = dataSource.assetsBook; 
        [tableView reloadData];
    }
    
}
-(void)refresh:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];

    assets=[dic objectForKey:@"data"];
     // =[dic objectForKey:@"num"];
    NSString *num=[NSString stringWithFormat:@"有%@张照片更新",[dic objectForKey:@"num"]];
   
  /*for(int i=0;i<[assets count];i++)
    {
     AmptsAlbum *am = (AmptsAlbum *)[assets objectAtIndex:i];
    NSLog(@"assets:%d",am.num);
    }*/
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"提示"
                          message:num
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"确定",nil];
    alert.tag=10;
    [alert show];

    [self.tableView reloadData];
   // NSLog(@"refresh");
}
-(void)editTable
{
    [dataSource refreshTag];
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    

    if (self.tableView.editing) {
        editButton.style=UIBarButtonItemStyleBordered;
        editButton.title = d;
        self.navigationItem.leftBarButtonItem=nil;
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        cell1.selectionStyle=UITableViewCellSelectionStyleBlue;
        NSArray *cells = self.tableView.visibleCells;
        for (UITableViewCell *cell in cells) {
            UIView *iv = [cell viewWithTag:100];
            if (iv) {
                iv.hidden = NO;
            }
            iv = nil;
            iv = [cell viewWithTag:101];
            if (iv) {
                iv.hidden = NO;
            }
        }

    }
    else{
        editButton.style=UIBarButtonItemStyleDone;
        self.navigationItem.leftBarButtonItem = addButon;
        editButton.title = c;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        NSArray *cells = self.tableView.visibleCells;
        for (UITableViewCell *cell in cells) {
            UIView *iv = [cell viewWithTag:100];
            if (iv) {
                iv.hidden = YES;
            }
            iv = nil;
            iv = [cell viewWithTag:101];
            if (iv) {
                iv.hidden = YES;
            }
        }

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
    [[cell viewWithTag:101] removeFromSuperview];
     [[cell viewWithTag:100] removeFromSuperview];
    AmptsAlbum *am = (AmptsAlbum *)[assets objectAtIndex:indexPath.row];
    Asset *as=nil;
    if([setting.albumIcon isEqualToString:@"FirstPic"])
    {
        as=[am.assetsList objectAtIndex:0];   
    }
    else
    {
     as = [am.assetsList lastObject];   
    }
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
    else
    {
        cell.textLabel.textColor=[UIColor blackColor];
    }
    if (am.num != 0) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *countNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:am.num]];
        if([am.object isEqualToString:@"Photos only"])
        {
            //NSString *a=NSLocalizedString(@"Edit", @"button");
            UIImage *photo = [UIImage imageNamed:@"photo_24.png"];
            CGRect rect = CGRectMake(CGRectGetMaxX(cell.frame)-50, cell.frame.size.height/2 - 10, 24, 24);
            UIImageView *iv = [[UIImageView alloc]initWithFrame:rect];
            iv.tag = 100;
            iv.image = photo;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",am.name, countNumber];
            [cell addSubview:iv];
        }
        else if([am.object isEqualToString:@"Videos only"])
        {
            UIImage *video = [UIImage imageNamed:@"video_24.png"];
            CGRect rect = CGRectMake(CGRectGetMaxX(cell.frame)-50, cell.frame.size.height/2 - 10, 24, 24);
            UIImageView *iv = [[UIImageView alloc]initWithFrame:rect];
            iv.image = video;
            iv.tag = 101;
             cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",am.name, countNumber];
            [cell.contentView addSubview:iv];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",am.name, countNumber];
        }
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@",am.name];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    return cell;
    
}

-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if (self.tableView.editing) { 
        PlaylistDetailController *detailController = [[PlaylistDetailController alloc]initWithNibName:@"PlaylistDetailController" bundle:[NSBundle mainBundle]];
        detailController.bum = [self getAlbumInRow:indexPath.row];
        detailController.hidesBottomBarWhenPushed = YES;
        if(detailController.bum!=nil)
        {
            [self.navigationController pushViewController:detailController animated:YES];
            index=indexPath.row;
        }
    }
    else
    {
        AmptsAlbum *ampt = [assets objectAtIndex:indexPath.row];
        NSMutableArray *WE = ampt.assetsList;
        Album *album = [self getAlbumInRow:indexPath.row];
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
