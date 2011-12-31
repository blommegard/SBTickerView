//
//  --------------------------------------------
//  Copyright (C) 2011 by Simon Blommegård
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  --------------------------------------------
//
//  SBTickerView.m
//  SBTickerView
//
//  Created by Simon Blommegård on 2011-12-10.
//  Copyright 2011 Simon Blommegård. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SBTickerViewTickDirectionDown,
    SBTickerViewTickDirectionUp,
} SBTickerViewTickDirection;

typedef enum {
    SBTickerViewAllowedPanDirectionNone     = 0,
    SBTickerViewAllowedPanDirectionDown     = 1 << 0,
    SBTickerViewAllowedPanDirectionUp       = 1 << 1,
} SBTickerViewAllowedPanDirection;


@interface SBTickerView : UIView
@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, assign) CFTimeInterval duration; // default .5

@property (nonatomic, assign) BOOL panning; // default NO. If set to YES, this view will get an UIPanGestureRecognizer
@property (nonatomic, assign) SBTickerViewAllowedPanDirection allowedPanDirections; // default SBTickerViewAllowedPanDirectionNone

- (void)tick:(SBTickerViewTickDirection)direction animated:(BOOL)animated completion:(void (^)(void))completion;
@end
