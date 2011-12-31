//
//  SBViewController.m
//  SBTickerViewDemo
//
//  Created by Simon Blommegård on 2011-12-10.
//  Copyright (c) 2011 Simon Blommegård. All rights reserved.
//

#import "SBViewController.h"
#import "SBTickerView.h"
#import "SBTickView.h"

@implementation SBViewController

@synthesize fullTickerView;
@synthesize imageTickerView;
@synthesize clockTickerViewHour1;
@synthesize clockTickerViewHour2;
@synthesize clockTickerViewMinute1;
@synthesize clockTickerViewMinute2;
@synthesize clockTickerViewSecond1;
@synthesize clockTickerViewSecond2;

@synthesize frontView;
@synthesize backView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [fullTickerView setFrontView:frontView];
    [fullTickerView setBackView:backView];
    [fullTickerView setDuration:1.];
    [fullTickerView setPanning:YES];
    [fullTickerView setAllowedPanDirections:(SBTickerViewAllowedPanDirectionDown | SBTickerViewAllowedPanDirectionUp)];
    
    [imageTickerView setFrontView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"front.jpeg"]]];
    [imageTickerView setBackView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.jpeg"]]];
    
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(numberTick:) userInfo:nil repeats:YES];
    
    //Init
    _currentClock = @"000000";
    _clockTickers = [NSArray arrayWithObjects:
                     clockTickerViewHour1,
                     clockTickerViewHour2,
                     clockTickerViewMinute1,
                     clockTickerViewMinute2,
                     clockTickerViewSecond1,
                     clockTickerViewSecond2, nil];
    
    for (SBTickerView *ticker in _clockTickers)
        [ticker setFrontView:[SBTickView tickViewWithTitle:@"0" fontSize:45.]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)tick:(UIButton *)sender {
    if (sender.tag == 0 || sender.tag == 1)
        [imageTickerView tick:sender.tag animated:YES completion:^{
            NSLog(@"Done Down");
        }];
    
    else {
        [fullTickerView tick:(sender.tag - 2) animated:YES completion:nil];
    }
}

- (void)numberTick:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *newClock = [formatter stringFromDate:[NSDate date]];
        
    [_clockTickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![[_currentClock substringWithRange:NSMakeRange(idx, 1)] isEqualToString:[newClock substringWithRange:NSMakeRange(idx, 1)]]) {
            [obj setBackView:[SBTickView tickViewWithTitle:[newClock substringWithRange:NSMakeRange(idx, 1)] fontSize:45.]];
            [obj tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
        }
    }];
    
    _currentClock = newClock;
}

@end
