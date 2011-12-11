//
//  SBViewController.h
//  SBTickerViewDemo
//
//  Created by Simon Blommegård on 2011-12-10.
//  Copyright (c) 2011 Simon Blommegård. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBTickerView;

@interface SBViewController : UIViewController {
    NSString *_currentClock;
    NSArray *_clockTickers;
}
@property (nonatomic, strong) IBOutlet SBTickerView *fullTickerView;
@property (nonatomic, strong) IBOutlet SBTickerView *imageTickerView;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewHour1;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewHour2;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewMinute1;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewMinute2;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewSecond1;
@property (nonatomic, strong) IBOutlet SBTickerView *clockTickerViewSecond2;

@property (nonatomic, strong) IBOutlet UIView *frontView;
@property (nonatomic, strong) IBOutlet UIView *backView;

- (IBAction)tick:(id)sender;
@end
