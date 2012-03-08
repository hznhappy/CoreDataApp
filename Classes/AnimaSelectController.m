//
//  AnimaSelectController.m
//  PhotoApp
//
//  Created by Andy on 11/4/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "AnimaSelectController.h"
#import "PlaylistDetailController.h"
#import "PhotoAppDelegate.h"

@implementation AnimaSelectController
@synthesize animaArray;
@synthesize tranStyle,Trans_list,album,Text;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSString *a=NSLocalizedString(@"fade", @"title");
    NSString *b=NSLocalizedString(@"cube", @"title");
    NSString *c=NSLocalizedString(@"reveal", @"title");
    NSString *d=NSLocalizedString(@"push", @"title");
    NSString *e=NSLocalizedString(@"moveIn", @"title");
    NSString *f=NSLocalizedString(@"suckEffect", @"title");
    NSString *g=NSLocalizedString(@"oglFlip", @"title");
    NSString *h=NSLocalizedString(@"rippleEffect", @"title");
    NSString *i=NSLocalizedString(@"pageCurl", @"title");
     NSString *j=NSLocalizedString(@"pageUnCurl", @"title");
   
    self.Trans_list =  [[NSMutableArray alloc]initWithObjects:@"fade",@"cube",@"reveal",@"push",@"moveIn",@"suckEffect",@"oglFlip",@"rippleEffect",@"pageCurl",@"pageUnCurl",nil];
    self.animaArray = [[NSMutableArray alloc]initWithObjects:a,b,c,d,e,f,g,h,i,
                       j,nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TableView delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [animaArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *animateString = [animaArray objectAtIndex:indexPath.row];
    cell.textLabel.text = animateString;
    if ([animateString isEqualToString:self.tranStyle]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if(album!=nil)
    {
        album.transitType = [Trans_list objectAtIndex:indexPath.row];
        [delegate.dataSource.coreData saveContext];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:cell.textLabel.text forKey:@"tranStyle"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeTransitionLabel" object:nil userInfo:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    tranStyle = nil;
    animaArray = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
