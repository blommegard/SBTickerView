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

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

- (void)_setup;
- (void)_initializeTick:(SBTickerViewTickDirection)direction;
- (void)_finalizeTick:(void (^)(void))completion;
- (void)_pan:(UIPanGestureRecognizer *)gestureRecognizer;
@end

@implementation SBTickerView {
    struct {
        unsigned int ticking:1;
        unsigned int panning:1;
    } _flags;
    
    SBTickerViewTickDirection _panningDirection;
    
    CGPoint _initialPanPosition;
    CGPoint _lastPanPosition;
}

@synthesize topFaceLayer = _topFaceLayer;
@synthesize bottomFaceLayer = _bottomFaceLayer;
@synthesize tickLayer = _tickLayer;
@synthesize flipLayer = _flipLayer;

@synthesize frontView = _frontView;
@synthesize backView = _backView;
@synthesize duration = _duration;

@synthesize panning = _panning;
@synthesize allowedPanDirections = _allowedPanDirections;
@synthesize panGestureRecognizer = _panGestureRecognizer;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
        [self _setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) 
        [self _setup];
    return self;
}

- (id)init {
    if ((self = [super init]))
        [self _setup];
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

- (void)setPanning:(BOOL)panning {
    if (_panning != panning) {
        _panning = panning;
        
        if (_panning)
            [self addGestureRecognizer:self.panGestureRecognizer];
        else
            [self removeGestureRecognizer:self.panGestureRecognizer];
    }
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
    }
    
    return _panGestureRecognizer;
}

#pragma mark - Private

- (void)_setup {
    _duration = .5;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)_initializeTick:(SBTickerViewTickDirection)direction {
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
    }
    else if (direction == SBTickerViewTickDirectionUp) {
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
}

- (void)_finalizeTick:(void (^)(void))completion {
    UIView *frontView = self.frontView;
    [self setFrontView:self.backView];
    [self setBackView:frontView];
    
    if (completion)
        completion();
    
    _flags.ticking = NO;
}

- (void)_pan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.allowedPanDirections == SBTickerViewAllowedPanDirectionNone)
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        _initialPanPosition = [gestureRecognizer locationInView:self];
    
    _lastPanPosition = [gestureRecognizer locationInView:self];
    
    // Start
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged && !_flags.panning) {
        // Down
        if (self.allowedPanDirections & SBTickerViewAllowedPanDirectionDown && _initialPanPosition.y < _lastPanPosition.y) {
            NSLog(@"Start down");
            _panningDirection = SBTickerViewTickDirectionDown;
            _flags.panning = YES;
        }
        // Up
        if (self.allowedPanDirections & SBTickerViewAllowedPanDirectionUp && _initialPanPosition.y > _lastPanPosition.y) {
            NSLog(@"Start up");
            _panningDirection = SBTickerViewTickDirectionUp;
            _flags.panning = YES;
        }
        
        return;
    }
    
    // Pan
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged && _flags.panning) {
        // Nop
        if (!(_panningDirection == SBTickerViewTickDirectionDown && _initialPanPosition.y >= _lastPanPosition.y) &&
            !(_panningDirection == SBTickerViewTickDirectionUp && _initialPanPosition.y <= _lastPanPosition.y)) {

            NSLog(@"Pan!");
        }
    }
    
    // End
    if ((gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateEnded)
        && _flags.panning) {
        NSLog(@"End");
        _flags.panning = NO;
    }
}

- (CGPoint)_invalidPanPosition {
    return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
}

#pragma mark - Public

- (void)tick:(SBTickerViewTickDirection)direction animated:(BOOL)animated completion:(void (^)(void))completion {
    if (_flags.ticking || !_frontView || !_backView)
        return;
    _flags.ticking = YES;
    
    if (!animated) {
        [self _finalizeTick:completion];
        return;
    }
    
    [self _initializeTick:direction];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .01 * NSEC_PER_SEC); // WTF!
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:_duration];
        
        [CATransaction setCompletionBlock:^{
            [_flipLayer removeFromSuperlayer], _flipLayer = nil;
            [_topFaceLayer removeFromSuperlayer], _topFaceLayer = nil;
            [_bottomFaceLayer removeFromSuperlayer], _bottomFaceLayer = nil;
            [_tickLayer removeFromSuperlayer], _tickLayer = nil;

            [self _finalizeTick:completion];
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
