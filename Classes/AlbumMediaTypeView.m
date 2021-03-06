//
//  AlbumMediaTypeView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "AlbumMediaTypeView.h"
#import "PhotoAppDelegate.h"

@implementation AlbumMediaTypeView
@synthesize album;
@synthesize chooseType;
@synthesize table;
-(void)viewDidLoad
{
    NSString *a=NSLocalizedString(@"Photos only", @"title");
    NSString *b=NSLocalizedString(@"Videos only", @"title");
    NSString *c=NSLocalizedString(@"All", @"title");
    locate=[[NSMutableArray alloc]initWithObjects:a,b,c,nil];
    type=[[NSMutableArray alloc]initWithObjects:@"Photos only",@"Videos only",@"All",nil];
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [type count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	// Add disclosure triangle to cell
    
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
	}
    NSString *type1=[locate objectAtIndex:indexPath.row];
    cell.textLabel.text =type1;
    if ([type1 isEqualToString:self.chooseType]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if(album!=nil)
    {
        album.chooseType=[type objectAtIndex:indexPath.row];
        [delegate.dataSource.coreData saveContext];
    }
    [self.table  deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[locate objectAtIndex:indexPath.row] forKey:@"TypeStyle"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeType" object:nil userInfo:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
