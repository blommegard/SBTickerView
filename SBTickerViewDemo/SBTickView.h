//
//  SBTickView.h
//  SBTickerViewDemo
//
//  Created by Simon Blommegård on 2011-12-10.
//  Copyright (c) 2011 Simon Blommegård. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SBTickView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, strong) UIColor *titleColor;
+ (id)tickViewWithTitle:(NSString *)title fontSize:(CGFloat)fontSize;
@end
