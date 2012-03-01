//
//  EffectsView.m
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import "EffectsView.h"
#import "AnimaSelectController.h"

@implementation EffectsView
@synthesize transilationCell;
@synthesize palymusicCell;
@synthesize musicCell;
@synthesize playTable;
@synthesize transLabel;
@synthesize album;
-(void)viewDidLoad
{
    self.transLabel.text=album.transitType;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTransition:) name:@"changeTransitionLabel" object:nil];
}
-(void)changeTransition:(NSNotification *)note{
    NSDictionary *dic = [note userInfo];
    NSString *labelText = [dic objectForKey:@"tranStyle"];
     self.transLabel.text = labelText;
}

-(IBAction)updateTable:(id)sender{
    mySwc=NO;
    UISwitch *newSwitcn  = (UISwitch *)sender;
    mySwc = newSwitcn.on;
    if (newSwitcn.on) {
        [playTable beginUpdates];
        [playTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [playTable endUpdates];
    }else{
        [playTable beginUpdates];
        [playTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [playTable endUpdates];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(mySwc)
        return 3;
    else
        return 2;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int rowNum=indexPath.row;
            UITableViewCell *cell=nil;
            switch (rowNum) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"transilationCell"];
                    if (cell == nil) {
                        cell = self.transilationCell;
                         cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    }
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"palymusicCell"];
                    if (cell == nil) {
                        cell = self.palymusicCell;
                        cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    }
                    break;
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
                    if (cell == nil) {
                        cell = self.musicCell;
                        cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    }
                    break;
                    
        default:
            break;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  if(indexPath.row==0)
  {
      AnimaSelectController *animateController = [[AnimaSelectController alloc]init];
      animateController.tranStyle = self.transLabel.text;
//      animateController.Text=textField.text;
       animateController.album = album;
      [self.navigationController pushViewController:animateController animated:YES];
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

  }
    else if(indexPath.row==1)
    {
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = @"Select songs";
        
        [self presentModalViewController:mediaPicker animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
//    [self.textField resignFirstResponder];
//    if (indexPath.section ==7 && indexPath.row == 0) {
//        if(bum==nil)
//        {
//            [self album];
//        }
//    }
//    if (indexPath.section ==7 && indexPath.row == 1)
//    {
//        [textField resignFirstResponder];
//    }
//    if (indexPath.section ==7 && indexPath.row == 2) {
//        if(bum==nil)
//        {
//            [self album];
//        }
//        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
//        
//        mediaPicker.delegate = self;
//        mediaPicker.allowsPickingMultipleItems = YES;
//        mediaPicker.prompt = @"Select songs";
//        
//        [self presentModalViewController:mediaPicker animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    if (indexPath.section == 2) {
//        if(bum==nil)
//        {
//            [self album];
//        }
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        UIButton *button1 = [self getStateButton];
//        if (cell.accessoryView==nil) {
//            cell.accessoryView = button1;
//        }else{
//            cell.accessoryView = nil;
//        }
//        for (UIButton *button in cell.contentView.subviews) {
//            
//            if ([button isKindOfClass:[UIButton class]]) {
//                if ([button.currentImage isEqual:unselectImg]) {
//                    [button setImage:selectImg forState:UIControlStateNormal]; 
//                    NSString *rule=@"INCLUDE";
//                    [self insert:indexPath.row rule:rule];
//                    [selectedIndexPaths addObject:indexPath];
//                }
//                else
//                {
//                    [button setImage:unselectImg forState:UIControlStateNormal];
//                    People *p1 = (People *)[list objectAtIndex:indexPath.row];
//                    NSManagedObjectContext *managedObjectsContext = [appDelegate.dataSource.coreData managedObjectContext];
//                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PeopleRuleDetail" inManagedObjectContext:managedObjectsContext];
//                    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//                    [request setEntity:entity];
//                    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conPeople==%@ AND conPeopleRule == %@",p1,bum.conPeopleRule];
//                    [request setPredicate:pre];
//                    NSError *error = nil;
//                    NSArray *A=[managedObjectsContext executeFetchRequest:request error:&error];
//                    PeopleRuleDetail *p=[A objectAtIndex:0];
//                    [bum.conPeopleRule removeConPeopleRuleDetailObject:p];
//                    [appDelegate.dataSource.coreData saveContext];
//                    
//                }
//            }
//        }
//        
//    }
//    if(indexPath.section==5)
//    {  
//        if(bum==nil)
//        {
//            [self album];
//        }
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        for (UIButton *button in cell.contentView.subviews) {
//            
//            if ([button isKindOfClass:[UIButton class]]) {
//                if ([button.currentImage isEqual:unselectImg]) {
//                    [button setImage:selectImg forState:UIControlStateNormal]; 
//                    bum.isFavorite=[NSNumber numberWithBool:YES];
//                }
//                else
//                {
//                    [button setImage:unselectImg forState:UIControlStateNormal];
//                    bum.isFavorite=nil;
//                    [appDelegate.dataSource.coreData saveContext];
//                    
//                }
//            }
//        }
//        
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
