//
//  resetView.m
//  PhotoApp
//
//  Created by  on 12-3-2.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "resetView.h"

@implementation resetView
@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
    resetList=[[NSMutableArray alloc]initWithObjects:@"reset All",@"reset password",@"reset event tags",@"reset person tags",
               @"reset favorite list",@"reset like counts",@"reset my favorite", nil];
    // Do any additional setup after loading the view from its nib.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resetList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	// Add disclosure triangle to cell
    
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
	}
    cell.textLabel.text=[resetList objectAtIndex:indexPath.row];
//    NSString *type1=[type objectAtIndex:indexPath.row];
//    cell.textLabel.text =type1;
//    if ([type1 isEqualToString:self.chooseType]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }else{
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
	return cell;
}

@end
