//
//  sortOrderView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "sortOrderView.h"
#import "PhotoAppDelegate.h"
@implementation sortOrderView
@synthesize orderCell;
@synthesize album;
@synthesize table;

-(void)viewDidLoad
{index=-1;
    app=[[UIApplication sharedApplication]delegate];
    dataSource=app.dataSource;
   SortList = [NSMutableArray arrayWithObjects:@"date",@"numOfLike",@"numPeopleTag",nil];
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    NSString *b=NSLocalizedString(@"Back", @"title");
    [backButton setTitle:b forState:UIControlStateNormal];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =backItem;
    
}
-(void)back
{
    NSLog(@"back");
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:album.sortKey,@"sort",album.sortOrder,@"order",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSort" object:nil userInfo:dictionary];

    [self.navigationController popViewControllerAnimated:YES];
   
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
    return SortList.count;
    }
    else
        return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
    NSString *a=@"Sort";
        return a;
    }
    else
    {
    NSString *b=@"Order";
        return b;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	
    
    if(indexPath.section==0)
    {static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier];
        }
    cell.textLabel.text =[SortList objectAtIndex:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if ([cell.textLabel.text isEqualToString:album.sortKey]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

                  
    return cell;
    }
    else
    {
        UITableViewCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
    if (cell == nil) {
        cell=self.orderCell;
        cell.accessoryView = [self orderButton];
        if(![album.sortOrder boolValue])
        {
            orderButton.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
            [orderButton setTitle:@"DSC" forState:UIControlStateNormal];
        }
    }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
}
-(UIButton *)orderButton{
    orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    orderButton.frame = CGRectMake(0, 0, 105, 28);
    [orderButton addTarget:self action:@selector(order:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setTitle:@"ASC" forState:UIControlStateNormal];
    orderButton.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
    [orderButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    return orderButton;
}
-(void)order:(id)sender
{
//    if(bum==nil)
//    {
//        [self album];
//    }
    UIButton *button = (UIButton *)sender;
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    if ([button.titleLabel.text isEqualToString:@"ASC"]) {
        button.backgroundColor = [UIColor colorWithRed:44/255.0 green:100/255.0 blue:196/255.0 alpha:1.0];
        [button setTitle:@"DSC" forState:UIControlStateNormal];
        album.sortOrder=[NSNumber numberWithBool:NO];
        
    }
    else if ([button.titleLabel.text isEqualToString:@"DSC"]){
        button.backgroundColor = [UIColor colorWithRed:167/255.0 green:124/255.0 blue:83/255.0 alpha:1.0];
        [button setTitle:@"ASC" forState:UIControlStateNormal];
      album.sortOrder=[NSNumber numberWithBool:YES];
        
    }
  [dataSource.coreData saveContext];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  index=indexPath.row;
    NSLog(@"INDEX %d",index);
    if(indexPath.section==0)
    {
   album.sortKey=[SortList objectAtIndex:index];
   [dataSource.coreData saveContext];
    [self.table reloadData];
    }
    else
    {
        
    }
      
//    PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    if(album!=nil)
//    {
//        //album.chooseType=[type objectAtIndex:indexPath.row];
//        [delegate.dataSource.coreData saveContext];
//    }
//   // NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[type objectAtIndex:indexPath.row] forKey:@"TypeStyle"];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeType" object:nil userInfo:dictionary];
//    [self.navigationController popViewControllerAnimated:YES];
}



@end
