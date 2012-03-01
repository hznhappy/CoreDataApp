//
//  EffectsView.h
//  PhotoApp
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 chinarewards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Album.h"

@interface EffectsView : UIViewController<UITableViewDelegate,UITableViewDataSource,MPMediaPickerControllerDelegate>
{
    UITableViewCell *transilationCell;
    UITableViewCell *palymusicCell;
    UITableViewCell *musicCell;
    UITableView *playTable;
    BOOL mySwc;
    UILabel *transLabel;
    Album *album;
    
}

@property(nonatomic,strong)IBOutlet  UITableViewCell *transilationCell;
@property(nonatomic,strong)IBOutlet  UITableViewCell *palymusicCell;
@property(nonatomic,strong)IBOutlet  UITableViewCell *musicCell;
@property(nonatomic,strong)IBOutlet  UITableView *playTable;
@property(nonatomic,strong)IBOutlet UILabel *transLabel;
@property(nonatomic,strong)Album *album;
-(IBAction)updateTable:(id)sender;
-(void)changeTransition:(NSNotification *)note;
@end
