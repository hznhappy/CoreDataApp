//
//  PopupPanelView.m
//  PhotoApp
//
//  Created by apple on 11-10-9.
//  Copyright 2011年 chinarewards. All rights reserved.
//

#import "PopupPanelView.h"
#import "TagManagementController.h"
#import "PhotoViewController.h"
#import "Asset.h"
#import "PeopleTag.h"
#import "PhotoAppDelegate.h"
@implementation PopupPanelView
@synthesize isOpen;
@synthesize rectForOpen;
@synthesize rectForClose;
@synthesize list;
@synthesize myscroll;
- (id)initWithFrame:(CGRect)frame andAsset:(Asset *)asset{
    self = [super initWithFrame:frame];
    if (self) {
        ass = asset;
		isOpen = NO;
		rectForOpen = self.frame;
		rectForClose = CGRectMake(0 ,440, rectForOpen.size.width, 0);
		
		[self setBackgroundColor:[UIColor whiteColor]];
        self.alpha=0.4;
		[self.layer setCornerRadius:10.0];
		[self setClipsToBounds:YES];   
		myscroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 347)];
        [self addSubview:myscroll]; 
        [myscroll setBackgroundColor:[UIColor clearColor]];
        PhotoAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        dataSource=delegate.dataSource;
        [self selectTagPeople];
        [myscroll setContentSize:CGSizeMake(320, 45*[self.list count])];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Buttons) name:@"edit" object:nil];
    }
   
    return self;
}
-(void)selectTagPeople
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"conAsset == %@",ass];
    self.list = [dataSource simpleQuery:@"PeopleTag" predicate:pre sortField:nil sortOrder:NO];
    
}

-(void)Buttons
{
    for(UIButton *button in self.myscroll.subviews)
    {
        [button removeFromSuperview];
    }
    [self selectTagPeople];
    [myscroll setContentSize:CGSizeMake(320, 45*[self.list count])];
    NSString *buttonName = nil;
	UIButton *button = nil;
    CGFloat btx = self.frame.size.width - 110;
    CGFloat bty = 20;
    CGFloat btwidth = 120;
    CGFloat byheight = 30;
    for(int i=0; i<[self.list count]; i++){
        button = [UIButton buttonWithType:UIButtonTypeCustom]; 
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
       PeopleTag *peopleTag =[self.list objectAtIndex:i];
        NSString *firstName = peopleTag.conPeople.firstName;
        NSString *lastName = peopleTag.conPeople.lastName;
        if (lastName.length == 0 || lastName == nil) {
            buttonName = firstName;
        }else{
            buttonName = [firstName stringByAppendingFormat:@"%@",peopleTag.conPeople.lastName];
        }
		button.frame = CGRectMake(btx, bty, btwidth, byheight);
		[button setTitle:buttonName forState:UIControlStateNormal];
		button.tag = i;
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
        [myscroll addSubview:button];
		bty += 35;
	}
	bty = 20;
 }
-(void)buttonPressed:(UIButton *)button{
	int tag = button.tag;
    PeopleTag *pt = [self.list objectAtIndex:tag];
    [pt.conPeople removeConPeopleTagObject:pt];
    [ass removeConPeopleTagObject:pt];
    ass.numPeopleTag = [NSNumber numberWithInt:[ass.numPeopleTag intValue]-1];
    [dataSource.coreData saveContext];
    [self selectTagPeople];
    [self Buttons];
    NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPhotoTag" 
                                                       object:self 
                                                     userInfo:dic];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"def",@"name",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addplay" 
                                                       object:self 
                                                     userInfo:dic1];
    
   }
-(void)viewOpen{
	isOpen = YES;
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[self setFrame:rectForOpen];
	[UIView commitAnimations];
}

-(void)viewClose{
	isOpen = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[self setFrame:rectForClose];
	[UIView commitAnimations];
}


@end
