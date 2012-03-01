//
//  DatefilterView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "DatefilterView.h"
#import "PhotoAppDelegate.h"

@implementation DatefilterView
@synthesize album;
-(void)viewDidLoad
{
    app=[[UIApplication sharedApplication]delegate];
    dataSource=app.dataSource;
    dateList = [NSMutableArray arrayWithObjects:@"Recent two weeks",@"Recent month",@"Recent three months",@"Recent six months", @"More than six months",@"More than one year",nil];
    daterule = [NSEntityDescription insertNewObjectForEntityForName:@"DateRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]];
    
    if(album.conDateRule!=nil)
    {
        daterule=album.conDateRule;
    }

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dateList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
	}
    cell.textLabel.text =[dateList objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:daterule.datePeriod]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
	return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
//        album.chooseType=[type objectAtIndex:indexPath.row];
//        [delegate.dataSource.coreData saveContext];
//  
//    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[type objectAtIndex:indexPath.row] forKey:@"TypeStyle"];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeType" object:nil userInfo:dictionary];
    daterule.datePeriod=[dateList objectAtIndex:indexPath.row];
    album.conDateRule=daterule;
    daterule.conAlbum=album;
    [dataSource.coreData saveContext];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:daterule.datePeriod forKey:@"date"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeDate" object:nil userInfo:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
