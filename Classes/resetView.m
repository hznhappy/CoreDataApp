//
//  resetView.m
//  PhotoApp
//
//  Created by  on 12-3-2.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "resetView.h"
#import "PhotoAppDelegate.h"
#import "People.h"
#import "Asset.h"
#import "PeopleTag.h"
#import "Album.h"
#import "Event.h"
#import "EventRule.h"
#import "DateRule.h"
#import "AssetRule.h"
#import "PeopleRule.h"
#import "PeopleRuleDetail.h"
@implementation resetView
@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
    app=[[UIApplication sharedApplication] delegate];
    dataSource=app.dataSource;
    resetList=[[NSMutableArray alloc]initWithObjects:@"reset All",@"reset password",@"reset event tags",@"reset person tags",
               @"reset favorite list",@"reset like counts",@"reset my favorite", nil];
    selectImg = [UIImage imageNamed:@"Selected.png"];
    unselectImg = [UIImage imageNamed:@"Unselected.png"];
    NSString *a=NSLocalizedString(@"reset All", @"title");
    NSString *g=NSLocalizedString(@"reset password", @"title");
    NSString *c=NSLocalizedString(@"reset event tags", @"title");
    NSString *d=NSLocalizedString(@"reset person tags", @"title");
    NSString *e=NSLocalizedString(@"reset favorite list", @"title");
    NSString *f=NSLocalizedString(@"reset like counts", @"title");
    NSString *h=NSLocalizedString(@"reset my favorite", @"title");
    locate=[[NSMutableArray alloc]initWithObjects:a,g,c,d,e,f,h,nil];
    
    
    NSString *b=NSLocalizedString(@"Choose", @"button");
    
    chooseButton = [[UIBarButtonItem alloc] initWithTitle:b style:UIBarButtonItemStyleBordered target:self action:@selector(togglechoose:)];
    
    chooseButton.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.rightBarButtonItem = chooseButton;
    choose=NO;
    needreset=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)togglechoose:(id)sender
{
    self.table.allowsMultipleSelectionDuringEditing=YES;
    NSString *a=NSLocalizedString(@"Done", @"button");
    NSString *b=NSLocalizedString(@"Choose", @"button");
    if([chooseButton.title isEqualToString:b])
    {
        chooseButton.style=UIBarButtonItemStyleDone;         
       chooseButton.title=a;
        choose=YES;
    }
    else
    {
        chooseButton.style=UIBarButtonItemStyleBordered;
        chooseButton.title=b;
        choose=NO;
        [self reset:needreset];
        [needreset removeAllObjects];
       
        
    }
        
 [self.table setEditing:!self.table.editing animated:YES];
    [self.table reloadData];
    
    
}
-(void)reset:(NSMutableArray *)resetList1
{
    NSArray *list=[[NSArray alloc]init];
    if([resetList1 containsObject:@"reset All"])
    {
        NSLog(@"yes");
        [self resetAll];
    }
    else
    {
        NSLog(@"no");
    for(NSString *re in resetList1)
    {
        if([re isEqualToString: @"reset favorite list"])
        {
            NSPredicate *favor=[NSPredicate predicateWithFormat:@"favorite==%@ and addressBookId!=%d",[NSNumber numberWithBool:YES],-1];
            NSArray *fa2 = [dataSource simpleQuery:@"People" predicate:favor sortField:nil sortOrder:YES];
            for(People *po in fa2)
            {
                po.favorite=[NSNumber numberWithBool:NO];
            }
        }
        else if([re isEqualToString:@"reset password"])
        {
            dataSource.password=nil;
        }
        else if([re isEqualToString:@"reset my favorite"])
        {
            NSPredicate * result=[NSPredicate predicateWithFormat:@"isFavorite==%@",[NSNumber numberWithBool:YES]];
            NSArray *fa3 = [dataSource simpleQuery:@"Asset" predicate:result sortField:nil sortOrder:YES];
            for(Asset *at in fa3)
            {
                at.isFavorite=[NSNumber numberWithBool:NO];
            }
        }
        else if([re isEqualToString:@"reset like counts"])
        {
            NSPredicate * result=[NSPredicate predicateWithFormat:@"numOfLike!=0"];
            NSArray *fa4 = [dataSource simpleQuery:@"Asset" predicate:result sortField:nil sortOrder:YES];
            for(Asset *at1 in fa4)
            {
                at1.numOfLike=[NSNumber numberWithInt:0];
            }
        }
        else if([re isEqualToString:@"reset event tags"])
        {
            NSPredicate * result=[NSPredicate predicateWithFormat:@"conEvent!=nil"];
            NSArray *fa5 = [dataSource simpleQuery:@"Asset" predicate:result sortField:nil sortOrder:YES];
            for(Asset *at2 in fa5)
            {
                at2.conEvent=nil; 
            }
        }
        else if([re isEqualToString:@"reset person tags"])
        {
            NSPredicate * result=[NSPredicate predicateWithFormat:@"some conPeopleTag!=nil"];
            NSArray *fa6 = [dataSource simpleQuery:@"Asset" predicate:result sortField:nil sortOrder:YES];
            for(Asset *at3 in fa6)
            {
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",at3];
                list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
                for(PeopleTag *ptag in list)
                {
                    [at3 removeConPeopleTagObject:ptag];
                    at3.numPeopleTag=[NSNumber numberWithInt:0];
                }
            }
            NSPredicate * result1=[NSPredicate predicateWithFormat:@"some conPeopleTag!=nil"];
            NSArray *fa7 = [dataSource simpleQuery:@"People" predicate:result1 sortField:nil sortOrder:YES];
            for(People *p1 in fa7)
            {
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople == %@",p1];
                NSArray *list1 = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
                for(PeopleTag *ptag1 in list1)
                {
                    [p1 removeConPeopleTagObject:ptag1];
                }
            }
            for(PeopleTag *pt in list)
            {
                [dataSource.coreData.managedObjectContext deleteObject:pt];
            }
        }
    }
    [dataSource.coreData saveContext];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"add" 
                                                       object:self 
                                                     userInfo:dic2];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"editplay" 
                                                       object:self 
                                                     userInfo:dic1];
    }
    
}
-(void)resetAll
{
    NSArray *list=[[NSArray alloc]init];
    NSArray *tmp=[dataSource simpleQuery:@"Album" predicate:nil sortField:nil sortOrder:YES];
    for(Album *album in tmp)
    {
        [dataSource.coreData.managedObjectContext deleteObject:album];
    }
    NSPredicate * result7=[NSPredicate predicateWithFormat:@"isprotected==%@",[NSNumber numberWithBool:YES]];
    NSArray *fa7 = [dataSource simpleQuery:@"Asset" predicate:result7 sortField:nil sortOrder:YES];
    for(Asset *at7 in fa7)
    {
        at7.isprotected=[NSNumber numberWithBool:NO];
        at7.numPeopleTag=[NSNumber numberWithInt:0];
    }
    dataSource.password=nil;
    
    NSPredicate * result=[NSPredicate predicateWithFormat:@"isFavorite==%@",[NSNumber numberWithBool:YES]];
    NSArray *fa3 = [dataSource simpleQuery:@"Asset" predicate:result sortField:nil sortOrder:YES];
    for(Asset *at in fa3)
    {
        at.isFavorite=[NSNumber numberWithBool:NO];
    }
    
        
    NSPredicate * result1=[NSPredicate predicateWithFormat:@"numOfLike!=0"];
    NSArray *fa4 = [dataSource simpleQuery:@"Asset" predicate:result1 sortField:nil sortOrder:YES];
    for(Asset *at1 in fa4)
    {
        at1.numOfLike=[NSNumber numberWithInt:0];
    }
    
    NSPredicate * result2=[NSPredicate predicateWithFormat:@"conEvent!=nil"];
    NSArray *fa5 = [dataSource simpleQuery:@"Asset" predicate:result2 sortField:nil sortOrder:YES];
    for(Asset *at2 in fa5)
    {
        at2.conEvent=nil; 
    }
    
    
    NSPredicate * result3=[NSPredicate predicateWithFormat:@"some conPeopleTag!=nil"];
    NSArray *fa6 = [dataSource simpleQuery:@"Asset" predicate:result3 sortField:nil sortOrder:YES];
    for(Asset *at3 in fa6)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",at3];
        list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
        for(PeopleTag *ptag in list)
        {
            [at3 removeConPeopleTagObject:ptag];
            at3.numPeopleTag=[NSNumber numberWithInt:0];
        }
        
        NSPredicate * result4=[NSPredicate predicateWithFormat:@"some conPeopleTag!=nil"];
        NSArray *fa7 = [dataSource simpleQuery:@"People" predicate:result4 sortField:nil sortOrder:YES];
        for(People *p1 in fa7)
        {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople == %@",p1];
            NSArray *list1 = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
            for(PeopleTag *ptag1 in list1)
            {
                [p1 removeConPeopleTagObject:ptag1];
            }
        }
        for(PeopleTag *pt in list)
        {
            [dataSource.coreData.managedObjectContext deleteObject:pt];
        }
    }
    NSArray *tmp6=[dataSource simpleQuery:@"Event" predicate:nil sortField:nil sortOrder:YES];
    for(Event *Ev in tmp6)
    {
        [dataSource.coreData.managedObjectContext deleteObject:Ev];
    }
    NSArray *tmp1=[dataSource simpleQuery:@"DateRule" predicate:nil sortField:nil sortOrder:YES];
    for(DateRule *date in tmp1)
    {
        [dataSource.coreData.managedObjectContext deleteObject:date];
    }
    NSArray *tmp2=[dataSource simpleQuery:@"AssetRule" predicate:nil sortField:nil sortOrder:YES];
    for(AssetRule *asset in tmp2)
    {
        [dataSource.coreData.managedObjectContext deleteObject:asset];
    }
    NSArray *tmp3=[dataSource simpleQuery:@"PeopleRule" predicate:nil sortField:nil sortOrder:YES];
    for(PeopleRule *PR in tmp3)
    {
        [dataSource.coreData.managedObjectContext deleteObject:PR];
    }
    NSArray *tmp4=[dataSource simpleQuery:@"PeopleRuleDetail" predicate:nil sortField:nil sortOrder:YES];
    for(PeopleRuleDetail *PRD in tmp4)
    {
        [dataSource.coreData.managedObjectContext deleteObject:PRD];
    }
    NSArray *tmp5=[dataSource simpleQuery:@"EventRule" predicate:nil sortField:nil sortOrder:YES];
    for(EventRule *ER in tmp5)
    {
        [dataSource.coreData.managedObjectContext deleteObject:ER];
    }
    NSPredicate *favor=[NSPredicate predicateWithFormat:@"addressBookId!=%d",-1];
    NSArray *fa2 = [dataSource simpleQuery:@"People" predicate:favor sortField:nil sortOrder:YES];
    for(People *po in fa2)
    {
        [dataSource.coreData.managedObjectContext deleteObject:po];
    }



    
    [dataSource.coreData saveContext];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"add" 
                                                       object:self 
                                                     userInfo:dic2];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"editplay" 
                                                       object:self 
                                                     userInfo:dic1];
    
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
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.textLabel.text=[locate objectAtIndex:indexPath.row];
    if(choose)
    {
     cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
   
	return cell;
}
-(void)restState:(id)sender{
    
    UIButton *button = (UIButton *)sender;
//UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
//NSIndexPath *index = [table indexPathForCell:cell];
//NSInteger Row=index.row;
    
    if ([button.currentImage isEqual:selectImg]) {
        [button setImage:unselectImg forState:UIControlStateNormal];
//        cell.accessoryView = nil;
//        NSManagedObjectContext *managedObjectsContext = [dataSource.coreData managedObjectContext];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:managedObjectsContext];
//        NSFetchRequest *request = [[NSFetchRequest alloc]init];
//        [request setEntity:entity];
//        NSPredicate *pre = [NSPredicate predicateWithFormat:@"conEvent==%@ and conAlbum==%@",[eventsName objectAtIndex:Row],album];
//        [request setPredicate:pre];
//        NSError *error = nil;
//        NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
//        EventRule *e0=[A objectAtIndex:0];
//        [album removeConEventRuleObject:e0];
//        [[eventsName objectAtIndex:Row] removeConEventRuleObject:e0];
//        [dataSource.coreData.managedObjectContext deleteObject:e0];
//        [dataSource.coreData saveContext];  
    }
    else{
        [button setImage:selectImg forState:UIControlStateNormal];
//        NSEntityDescription *entity6 = [NSEntityDescription entityForName:@"EventRule" inManagedObjectContext:[dataSource.coreData managedObjectContext]]; 
//        EventRule *e1=[[EventRule alloc]initWithEntity:entity6 insertIntoManagedObjectContext:[dataSource.coreData managedObjectContext]];
//        e1.conEvent=[eventsName objectAtIndex:Row];
//        [album addConEventRuleObject:e1];
//        [dataSource.coreData saveContext];
        
    }
    //[self.tableView reloadData];
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.table deselectRowAtIndexPath:indexPath animated:YES];
    if(choose)
    {
    NSLog(@"insertindex:%d",indexPath.row);
    [needreset addObject:[resetList objectAtIndex:indexPath.row]];
    }
    else
    {
        NSLog(@"no");
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deleteindex:%d",indexPath.row);
    [needreset removeObject:[resetList objectAtIndex:indexPath.row]];
}

@end
