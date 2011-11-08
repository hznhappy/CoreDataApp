//
//  ContactsController.m
//  PhotoApp
//
//  Created by apple on 11-11-8.
//  Copyright 2011年 chinarewards. All rights reserved.
//
#import "ContactsController.h"
@implementation ContactsController
@synthesize ContractTable,list; 
@synthesize names;  
@synthesize keys,array,fu;  
-(void)viewDidLoad
 {
 list=[[NSMutableArray alloc]init];
 fu=[[NSMutableArray alloc]init];

 NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];  
 self.names = dict;
[dict release];
 ABAddressBookRef addressBook =ABAddressBookCreate();
 CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople (addressBook);
 CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
 for (id person in (NSArray *) allPeople)
 [self logContact:person];
 for (id group in (NSArray *) allGroups)
 [self logGroups:group];
 CFRelease(allGroups);
 CFRelease(allPeople);
 CFRelease(addressBook);
 array=[fu sortedArrayUsingSelector:  
                     @selector(compare:)];
     NSLog(@"tttt%@",array);
     self.keys=array;
 [super viewDidLoad];
 
 }
 -(void)logContact:(id)person
 {
 CFStringRef name = ABRecordCopyCompositeName(person);
 ABRecordID recId = ABRecordGetRecordID(person);
 NSLog(@"Person Name: %@ RecordID:%d",name, recId);
 NSString *newname=[NSString stringWithFormat:@"%@",name];
  //   NSString *newid=[NSString stringWithFormat:@"%d",recId];
 [list addObject:newname];
 NSLog(@"EWEW%@",list);
    // for (NSString * word in newname) {
     NSString * firstLetter;
         if ([newname length] > 0) {
             firstLetter = [newname substringToIndex:1];
             NSLog(@"WW%@",firstLetter);
         }
     if([fu containsObject:firstLetter])
     {}
     else
     {
         [fu addObject:firstLetter];
     }
     [self.names setObject:newname forKey:firstLetter];

 }
 -(void)logGroups:(id)group
 {
 CFStringRef name = ABRecordCopyValue(group,kABGroupNameProperty);
 ABRecordID recId = ABRecordGetRecordID(group);
 NSLog(@"Group Name: %@ RecordID:%d",name, recId);
 }
 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{  
    return [keys count];  
    //[list count];
}  
/* - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 
 return[list count];
 }*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  
{  
    NSLog(@"%d",[keys count]);
    NSString *key = [keys objectAtIndex:section];
    NSLog(@"RREREEEEER%@",key);//section为其中一个分区，获取section的索引 
    NSLog(@"%@",names);
    NSString *nameSection = [names objectForKey:key];
    NSMutableArray *nameSe=[[NSMutableArray alloc]init];
    [nameSe addObject:nameSection];
    NSLog(@"%d",[nameSe count]);//根据索引获取分区里面的所有数据  
    return [nameSe count];   
    //return [list count];//返回分区里的行的数量  
}  
- (UITableViewCell *)tableView:(UITableView *)tableView   
         cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
    //NSLog(@"tianshi\n");  
    NSUInteger section = [indexPath section];//返回第几分区  
    NSUInteger row = [indexPath row];//获取第几分区的第几行  
    NSString *key = [keys objectAtIndex:section]; //返回 分区的索引key  
    NSArray *nameSection = [names objectForKey:key];
    NSMutableArray *nameSe=[[NSMutableArray alloc]init];
    [nameSe addObject:nameSection];//返回 根据key获得：当前分区的所有内容，  
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";  
    //判断cell是否存在，如果没有，则新建一个  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:  
                             SectionsTableIdentifier ];  
    if (cell == nil) {  
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault   
                                       reuseIdentifier: SectionsTableIdentifier ] autorelease];  
    }  
    //给cell赋值  
    cell.textLabel.text = [nameSe objectAtIndex:row];  
    return cell;  
}  

 
 - (void)dealloc
 {
 [super dealloc];
 }




- (NSString *)tableView:(UITableView *)tableView   
titleForHeaderInSection:(NSInteger)section  
{  
    NSString *key = [keys objectAtIndex:section];  
    return key;  
}   
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView  
{  
    return keys;  
} 

@end
