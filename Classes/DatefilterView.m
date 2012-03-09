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
@synthesize table;
-(void)viewDidLoad
{   NSString *a=NSLocalizedString(@"Recent two weeks", @"title");
    NSString *b=NSLocalizedString(@"Recent month", @"title");
    NSString *c=NSLocalizedString(@"Recent three months", @"title");
    NSString *d=NSLocalizedString(@"Recent six months", @"title");
    NSString *e=NSLocalizedString(@"More than six months", @"title");
    NSString *f=NSLocalizedString(@"More than one year", @"title");
    NSString *g=NSLocalizedString(@"All", @"title");
    locate=[NSMutableArray arrayWithObjects:a,b,c,d,e,f,g,nil];
    app=[[UIApplication sharedApplication]delegate];
    dataSource=app.dataSource;
    dateList = [NSMutableArray arrayWithObjects:@"Recent two weeks",@"Recent month",@"Recent three months",@"Recent six months", @"More than six months",@"More than one year",@"All",nil];
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
    cell.textLabel.text =[locate objectAtIndex:indexPath.row];
    NSString *a=[dateList objectAtIndex:indexPath.row];
    if ([a isEqualToString:daterule.datePeriod]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

   // cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
    [self.table  deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[locate objectAtIndex:indexPath.row] forKey:@"date"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeDate" object:nil userInfo:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
