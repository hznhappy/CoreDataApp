//
//  SettingController.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "SettingController.h"
#import "resetView.h"
#import "PhotoAppDelegate.h"
#import "Setting.h"
@implementation SettingController
@synthesize table;
@synthesize lockSW;
@synthesize iconsizeCell,albumiconCell,lockmodeCell,dateCell,resetCell,versionCell;
@synthesize lcon,album,lock,date,reset,version;

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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 5;
    }
    else
    {
        return 1;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    if(section==0)
    {
        NSString *a=NSLocalizedString(@"display", @"title");
        return a;
    }
    else
    {
        NSString *b=NSLocalizedString(@"information", @"title");
        return b;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowNum=indexPath.row;
   if(indexPath.section==0)
    {
       UITableViewCell *cell=nil;
        switch (rowNum) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"iconsizeCell"];
                if (cell == nil) {
                    cell = self.iconsizeCell;
                    cell.accessoryView = [self iconsizeButton];
                    
                    if([setting.iconSize isEqualToString:@"Bigger"])
                    {
                        NSString *a=NSLocalizedString(@"Bigger", @"title");
                    iconsizeButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [iconsizeButton setTitle:a forState:UIControlStateNormal];
                    }
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    
                    
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"albumiconCell"];
                if (cell == nil) {
                    cell = self.albumiconCell;
                    cell.accessoryView = [self albumiconButton];
                    if([setting.albumIcon  isEqualToString:@"FirstPic"])
                    {
                         NSString *a=NSLocalizedString(@"FirstPic", @"title");
                    albumiconButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [albumiconButton setTitle:a forState:UIControlStateNormal];
                    
                    }
                    
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                break;
                case 2:
                cell=[tableView dequeueReusableCellWithIdentifier:@"lockmodeCell"];
                if(cell==nil)
                {
                    cell=self.lockmodeCell;
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                break;
                case 3:
                cell=[tableView dequeueReusableCellWithIdentifier:@"dateCell"];
                if(cell==nil)
                {
                    cell=self.dateCell;
                    cell.accessoryView = [self dateButton];
                    if([setting.dateInfo isEqualToString:@"Relative"])
                    {
                    NSString *a=NSLocalizedString(@"Relative", @"title");
                    dateButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [dateButton setTitle:a forState:UIControlStateNormal];
                    }
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                break;
            case 4:
                cell=[tableView dequeueReusableCellWithIdentifier:@"resetCell"];
                if(cell==nil)
                {
                    cell=self.resetCell;
                    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                break;
            default:
                break;
        }
        return cell;
    }
    else if(indexPath.section==1)
    {
        UITableViewCell *cell=nil;
                       cell = [tableView dequeueReusableCellWithIdentifier:@"versionCell"];
                if (cell == nil) {
                    cell = self.versionCell;
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
        return cell;
                

        
    }
    return nil;
}
-(UIButton *)dateButton
{
     NSString *a=NSLocalizedString(@"Exact", @"title");
    dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(0, 0, 105, 28);
    [dateButton addTarget:self action:@selector(date:) forControlEvents:UIControlEventTouchUpInside];
    [dateButton setTitle:a forState:UIControlStateNormal];
    dateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [dateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return dateButton;
}
-(UIButton *)iconsizeButton
{
    NSString *a=NSLocalizedString(@"Normal", @"title");
    iconsizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconsizeButton.frame = CGRectMake(0, 0, 105, 28);
    [iconsizeButton addTarget:self action:@selector(size:) forControlEvents:UIControlEventTouchUpInside];
    [iconsizeButton setTitle:a forState:UIControlStateNormal];
    iconsizeButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [iconsizeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return iconsizeButton;
}
-(UIButton *)albumiconButton
{    NSString *a=NSLocalizedString(@"LastPic", @"title");
    albumiconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    albumiconButton.frame = CGRectMake(0, 0, 105, 28);
    [albumiconButton addTarget:self action:@selector(icon:) forControlEvents:UIControlEventTouchUpInside];
    [albumiconButton setTitle:a forState:UIControlStateNormal];
    albumiconButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [albumiconButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return albumiconButton;
}
-(void)date:(id)sender
{
    NSString *a=NSLocalizedString(@"Exact", @"title");
    NSString *b=NSLocalizedString(@"Relative", @"title");
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:a]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:b forState:UIControlStateNormal];
        setting.dateInfo=@"Relative";
        
    }
    else if ([button.titleLabel.text isEqualToString:b]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:a forState:UIControlStateNormal];
        setting.dateInfo=@"Exact";
        
    }
    [dataSource.coreData saveContext];
    
}
-(void)icon:(id)sender
{
    NSString *a=NSLocalizedString(@"LastPic", @"title");
    NSString *b=NSLocalizedString(@"FirstPic", @"title");
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:a]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:b forState:UIControlStateNormal];
        setting.albumIcon=@"FirstPic";
        
    }
    else if ([button.titleLabel.text isEqualToString:b]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:a forState:UIControlStateNormal];
       setting.albumIcon=@"LastPic";
        
    }
    [dataSource.coreData saveContext];
    
}


-(void)size:(id)sender
{
    NSString *a=NSLocalizedString(@"Bigger", @"title");
    NSString *b=NSLocalizedString(@"Normal", @"title");
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:a]) {
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:b forState:UIControlStateNormal];
        setting.iconSize=@"Normal"; 
    }
    else if ([button.titleLabel.text isEqualToString:b]){
         button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:a forState:UIControlStateNormal];
        setting.iconSize=@"Bigger";
    }
    [dataSource.coreData saveContext];
    
}

-(IBAction)chooseLockMode:(id)sender
{
    UISwitch *newSwitcn  = (UISwitch *)sender;
    
    if (newSwitcn.on) {
        setting.lockMode=[NSNumber numberWithBool:YES];
                
    }else{
       setting.lockMode=[NSNumber numberWithBool:NO];
    }
    [dataSource.coreData saveContext];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0&&indexPath.row==4)
    {
        re=[[resetView alloc]init];
        [self.navigationController pushViewController:re animated:YES];
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    lcon.text=NSLocalizedString(@"Icon Size", @"title");
    album.text=NSLocalizedString(@"Album icon", @"title");
    lock.text=NSLocalizedString(@"Lock mode highlight", @"title");
    date.text=NSLocalizedString(@"Date info", @"title");
    reset.text=NSLocalizedString(@"Reset", @"title");
    version.text=NSLocalizedString(@"Version", @"title");
    app=[[UIApplication sharedApplication]delegate];
    dataSource=app.dataSource;
    //[self tablenew];
    
    if(setting.lockMode.boolValue||setting.lockMode==nil)
    {
        lockSW.on=YES;
    }
    else
    {
        lockSW.on=NO;
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)tablenew
{
    NSArray *tmp=[dataSource simpleQuery:@"Setting" predicate:nil sortField:nil sortOrder:YES];
    if(tmp.count!=0)
    {
        setting=[tmp objectAtIndex:0];
    }
    else
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Setting" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
        setting=[[Setting alloc]initWithEntity:entity insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
-(void)viewWillAppear:(BOOL)animated
{
    [self tablenew];
    [self.table reloadData];
}
-(void)viewWillDisappear:(BOOL)animated
{       
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
