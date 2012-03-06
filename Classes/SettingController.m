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
        return @"display";
    }
    else
    {
        return @"information";
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
                    if([setting.iconSize isEqualToString:@"normal"])
                    {
                    iconsizeButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [iconsizeButton setTitle:@"normal" forState:UIControlStateNormal];
                    }
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    
                    
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"albumiconCell"];
                if (cell == nil) {
                    cell = self.albumiconCell;
                    cell.accessoryView = [self albumiconButton];
                    if([setting.albumIcon  isEqualToString:@"firstPic"])
                    {
                    albumiconButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [albumiconButton setTitle:@"firstPic" forState:UIControlStateNormal];
                    
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
                    if([setting.dateInfo isEqualToString:@"relative"])
                    {
                    dateButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
                    [dateButton setTitle:@"relative" forState:UIControlStateNormal];
                    }
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
                break;
            case 4:
                cell=[tableView dequeueReusableCellWithIdentifier:@""];
                if(cell==nil)
                {
                    cell=self.resetCell;
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
    dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(0, 0, 105, 28);
    [dateButton addTarget:self action:@selector(date:) forControlEvents:UIControlEventTouchUpInside];
    [dateButton setTitle:@"exact" forState:UIControlStateNormal];
    dateButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [dateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return dateButton;
}
-(UIButton *)iconsizeButton
{
    iconsizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconsizeButton.frame = CGRectMake(0, 0, 105, 28);
    [iconsizeButton addTarget:self action:@selector(size:) forControlEvents:UIControlEventTouchUpInside];
    [iconsizeButton setTitle:@"bigger" forState:UIControlStateNormal];
    iconsizeButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [iconsizeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return iconsizeButton;
   
}
-(UIButton *)albumiconButton
{
    albumiconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    albumiconButton.frame = CGRectMake(0, 0, 105, 28);
    [albumiconButton addTarget:self action:@selector(icon:) forControlEvents:UIControlEventTouchUpInside];
    [albumiconButton setTitle:@"lastPic" forState:UIControlStateNormal];
    albumiconButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [albumiconButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return albumiconButton;
}
-(void)date:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"exact"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"relative" forState:UIControlStateNormal];
        setting.dateInfo=@"relative";
        
    }
    else if ([button.titleLabel.text isEqualToString:@"relative"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"exact" forState:UIControlStateNormal];
        setting.dateInfo=@"exact";
        
    }
    [dataSource.coreData saveContext];
    
}
-(void)icon:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"lastPic"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"firstPic" forState:UIControlStateNormal];
        setting.albumIcon=@"firstPic";
        
    }
    else if ([button.titleLabel.text isEqualToString:@"firstPic"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"lastPic" forState:UIControlStateNormal];
       setting.albumIcon=@"lastPic";
        
    }
    [dataSource.coreData saveContext];
    
}


-(void)size:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"bigger"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"normal" forState:UIControlStateNormal];
        setting.iconSize=@"normal"; 
    }
    else if ([button.titleLabel.text isEqualToString:@"normal"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"bigger" forState:UIControlStateNormal];
        setting.iconSize=@"bigger";
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
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    app=[[UIApplication sharedApplication]delegate];
    dataSource=app.dataSource;
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
-(void)viewWillDisappear:(BOOL)animated
{       
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
}


@end
