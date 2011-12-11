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

#import "SBTickerView.h"
#import "SBDoubleSidedLayer.h"
#import "UIView+SBExtras.h"
#import "SBGradientOverlayLayer.h"

@interface SBTickerView ()
@property (nonatomic, strong) SBGradientOverlayLayer *topFaceLayer;
@property (nonatomic, strong) SBGradientOverlayLayer *bottomFaceLayer;
@property (nonatomic, strong) SBDoubleSidedLayer *tickLayer;
@property (nonatomic, strong) CALayer *flipLayer;

- (void)setup;
@end

@implementation SBTickerView {
    struct {
        unsigned int ticking:1;
    } _flags;
}

@synthesize topFaceLayer = _topFaceLayer;
@synthesize bottomFaceLayer = _bottomFaceLayer;
@synthesize tickLayer = _tickLayer;
@synthesize flipLayer = _flipLayer;

@synthesize frontView = _frontView;
@synthesize backView = _backView;
@synthesize duration = _duration;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
        [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) 
        [self setup];
    return self;
}

- (id)init {
    if ((self = [super init]))
        [self setup];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_frontView setFrame:self.bounds];
    [_backView setFrame:self.bounds];
}

#pragma mark - Properties

- (void)setFrontView:(UIView *)frontView {
    if (_frontView.superview)
        [_frontView removeFromSuperview];
    
    _frontView = frontView;
    [self addSubview:frontView];
}

#pragma mark - Private

- (void)setup {
    _duration = .5;
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Public

- (void)tick:(SBTickerViewTickDirection)direction animated:(BOOL)animated completion:(void (^)(void))completion {
    if (_flags.ticking || !_frontView || !_backView)
        return;
    _flags.ticking = YES;
    
    void (^block)(void) = [completion copy];
    
    [self setFlipLayer:[CALayer layer]];
    [_flipLayer setFrame:self.layer.bounds];
    
    CATransform3D perspective = CATransform3DIdentity;
    float zDistanse = 400.;
    perspective.m34 = 1. / -zDistanse;
    [_flipLayer setSublayerTransform:perspective];
    
    [self.layer addSublayer:_flipLayer];
    
    UIImage *frontImage = [_frontView image];
    UIImage *backImage = [_backView image];
    
    // Face layers
    // Top
    [self setTopFaceLayer:[[SBGradientOverlayLayer alloc] initWithStyle:SBGradientOverlayLayerTypeFace
                                                                segment:SBGradientOverlayLayerSegmentTop]];
    
    [_topFaceLayer setFrame:CGRectMake(0., 0., _flipLayer.frame.size.width, floorf(_flipLayer.frame.size.height/2))];
    
    // Bottom
    [self setBottomFaceLayer:[[SBGradientOverlayLayer alloc] initWithStyle:SBGradientOverlayLayerTypeFace
                                                                   segment:SBGradientOverlayLayerSegmentBottom]];
    
    [_bottomFaceLayer setFrame:CGRectMake(0., floorf(_flipLayer.frame.size.height / 2), _flipLayer.frame.size.width, floorf(_flipLayer.frame.size.height/2))];

    // Tick layer
    [self setTickLayer:[[SBDoubleSidedLayer alloc] init]];
    
    [_tickLayer setAnchorPoint:CGPointMake(1., 1.)];
    [_tickLayer setFrame:CGRectMake(0., 0., _flipLayer.frame.size.width, floorf(_flipLayer.frame.size.height/2))];
    [_tickLayer setZPosition:1.]; // Above the other ones
    
    [_tickLayer setFrontLayer:[[SBGradientOverlayLayer alloc] initWithStyle:SBGradientOverlayLayerTypeTick
                                                                    segment:SBGradientOverlayLayerSegmentTop]];

    [_tickLayer setBackLayer:[[SBGradientOverlayLayer alloc] initWithStyle:SBGradientOverlayLayerTypeTick
                                                                    segment:SBGradientOverlayLayerSegmentBottom]];
    
    
    // Images
    if (direction == SBTickerViewTickDirectionDown) {
        [_topFaceLayer setContents:(__bridge id)backImage.CGImage];
        [_bottomFaceLayer setContents:(__bridge id)frontImage.CGImage];
        [_tickLayer.frontLayer setContents:(__bridge id)frontImage.CGImage];
        [_tickLayer.backLayer setContents:(__bridge id)backImage.CGImage];
        
        [_topFaceLayer setGradientOpacity:1.];
        
        [_tickLayer setTransform:CATransform3DIdentity];
    } else {
        [_topFaceLayer setContents:(__bridge id)frontImage.CGImage];
        [_bottomFaceLayer setContents:(__bridge id)backImage.CGImage];
        [_tickLayer.frontLayer setContents:(__bridge id)backImage.CGImage];
        [_tickLayer.backLayer setContents:(__bridge id)frontImage.CGImage];
        
        [_bottomFaceLayer setGradientOpacity:1.];
        
        [_tickLayer setTransform:CATransform3DMakeRotation(-M_PI, 1., 0., 0.)];
    }

    // Add layers
    [_flipLayer addSublayer:_topFaceLayer];
    [_flipLayer addSublayer:_bottomFaceLayer];
    [_flipLayer addSublayer:_tickLayer];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .01 * NSEC_PER_SEC); // WTF!
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:(animated? _duration:0)];
        
        [CATransaction setCompletionBlock:^{
            [_flipLayer removeFromSuperlayer], _flipLayer = nil;
            [_topFaceLayer removeFromSuperlayer], _topFaceLayer = nil;
            [_bottomFaceLayer removeFromSuperlayer], _bottomFaceLayer = nil;
            [_tickLayer removeFromSuperlayer], _tickLayer = nil;
            
            _flags.ticking = NO;
            UIView *frontView = self.frontView;
            [self setFrontView:self.backView];
            [self setBackView:frontView];
            
            if (block)
                block();
        }];
        
        CGFloat angle = (M_PI) * (1-direction);
        _tickLayer.transform = CATransform3DMakeRotation(angle, 1., 0., 0.);
        
        _topFaceLayer.gradientOpacity = direction;
        _bottomFaceLayer.gradientOpacity = 1. - direction;
        
        ((SBGradientOverlayLayer*)_tickLayer.frontLayer).gradientOpacity = 1. - direction;
        ((SBGradientOverlayLayer*)_tickLayer.backLayer).gradientOpacity = direction;
        
        [CATransaction commit];
    });

}

@end
