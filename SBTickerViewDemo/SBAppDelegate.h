//
//  SBAppDelegate.h
//  SBTickerViewDemo
//
//  Created by Simon Blommegård on 2011-12-11.
//  Copyright (c) 2011 Doubleint. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBViewController;

@interface SBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SBViewController *viewController;

@end
