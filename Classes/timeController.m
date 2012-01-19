//
//  timeController.m
//  PhotoApp
//
//  Created by  on 12-1-19.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "timeController.h"

@implementation timeController
@synthesize timeList;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray *Arry=[[NSMutableArray alloc]initWithObjects:@"11.2",@"3.2",@"4.15",nil];
    self.timeList=Arry;
    [Arry release];
    
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
    }
    NSString *animateString = [self.timeList objectAtIndex:indexPath.row];
    cell.textLabel.text = animateString;
     
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[self.timeList objectAtIndex:indexPath.row] forKey:@"Date"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeDate" object:nil userInfo:dictionary];

    [self.navigationController popViewControllerAnimated:YES];
}


@end
