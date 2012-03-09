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
@synthesize musicLabel;
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
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
//        MPMusicPlayerController *musicPlayer;
//        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        NSArray *items = [mediaItemCollection items];
        MPMediaItem *item = [items objectAtIndex:0];
        //[musicPlayer play]; 
        //self.musicLabel.text = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        self.musicLabel.text = [item valueForProperty:MPMediaItemPropertyTitle]; 
        album.music = self.musicLabel.text;
    }
    [mediaPicker dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [mediaPicker dismissModalViewControllerAnimated: YES];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
