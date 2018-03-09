//
//  WaveformView.m
//  Waveform
//
//  Created by Adam Kaplan on 3/5/16.
//  Copyright © 2016. All rights reserved.
//

#import "WaveformView.h"

static NSString * const kYFWaveformAnimationKey = @"yf_anim_wave";
static NSString * const kYFWaveformLayerReferenceKey = @"yf_animation_layer";

@interface WaveformView ()
@property (nonatomic, readonly) CALayer *waveFormLayer;
@property (nonatomic, readonly) NSMutableArray<CAShapeLayer *> *barLayers;
@property (nonatomic) NSMutableDictionary *barLayersByLayerId;
@property (nonatomic) NSMutableDictionary *barAnimationsByLayerId;
@end

@implementation WaveformView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithBarCount:18];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithBarCount:(NSUInteger)barCount
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        
        _numberOfBars = barCount;
        _barCornerRadius = CGSizeMake(0, 0);
        _barSpacing = 3.0;
        _barSize = CGSizeMake(3.0, 22.0);
        _barColor = [UIColor whiteColor];
        _minimumBarAnimationDuration = 0.4;
        _maximumBarAnimationDuration = 1.0;
        _barVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        _barLayersByLayerId = [NSMutableDictionary dictionary];
        _barAnimationsByLayerId = [NSMutableDictionary dictionary];
        
        _waveFormLayer = [CALayer layer];
        [self.layer addSublayer:_waveFormLayer];
        
        _barLayers = [NSMutableArray array];
        [self addBarCount:_numberOfBars fromIndex:0];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    UIEdgeInsets margins = self.layoutMargins;
    CGSize size = CGSizeMake((self.barSize.width + self.barSpacing) * self.numberOfBars + margins.left + margins.right,
                             self.barSize.height + margins.top + margins.bottom);
    return size;
}

- (void)setLayoutMargins:(UIEdgeInsets)layoutMargins
{
    super.layoutMargins = layoutMargins;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    UIEdgeInsets margins = self.layoutMargins;
    CGFloat totalWidth = self.numberOfBars * (self.barSpacing + self.barSize.width) + self.barSpacing;
    self.waveFormLayer.frame = CGRectMake(margins.left, margins.top, totalWidth, self.barSize.height);
    
    const CGRect barRect = CGRectMake(0, 0, self.barSize.width, self.barSize.height);
    CGFloat xOffset = 0;
    for (CALayer *barLayer in [self.waveFormLayer sublayers]) {
        barLayer.frame = CGRectOffset(barRect, xOffset, 0);
        xOffset += self.barSpacing + barRect.size.width;
    }
}

#pragma mark - Animation Control

- (void)startAnimating
{
    for (NSNumber *layerId in self.barLayersByLayerId) {
        CAShapeLayer *barLayer = self.barLayersByLayerId[layerId];
        [self animateLayer:barLayer withLayerId:layerId];
    }
}

- (void)stopAnimating
{
    for (CAShapeLayer *barLayer in self.barLayers) {
        [barLayer removeAnimationForKey:kYFWaveformAnimationKey];
    }
    [self.barAnimationsByLayerId removeAllObjects];
}

#pragma mark - Public properties

- (void)setBarColor:(UIColor *)barColor
{
    _barColor = barColor;
    for (CAShapeLayer *barLayer in self.barLayers) {
        barLayer.fillColor = barColor.CGColor;
    }
}

- (void)setBarCornerRadius:(CGSize)barCornerRadius
{
    CGSize cornerRadius = barCornerRadius;
    if (barCornerRadius.width < 0) {
        cornerRadius.width = 0;
    } else if (2.0 * barCornerRadius.width > self.barSize.width) {
        cornerRadius.width = self.barSize.width / 2.0;
    }
    
    if (barCornerRadius.height < 0) {
        cornerRadius.height = 0;
    } else if (2.0 * barCornerRadius.height > self.barSize.height) {
        cornerRadius.height = self.barSize.height / 2.0;
    }
    
    _barCornerRadius = cornerRadius;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setBarSize:(CGSize)barSize
{
    if (barSize.height < 0 || barSize.height < 2.0 * self.barCornerRadius.height) {
        NSAssert(false, @"Bar size height assertion failed: (barSize.height >= 2.0 * self.barCornerRadius.height)");
        return;
    }
    
    if (barSize.width < 0 || barSize.width < 2.0 * self.barCornerRadius.width) {
        NSAssert(false, @"Bar size width assertion failed: (barSize.width >= 2.0 * self.barCornerRadius.width)");
        return;
    }
    
    _barSize = barSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setBarSpacing:(CGFloat)barSpacing
{
    _barSpacing = barSpacing;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setBarVerticalAlignment:(UIControlContentVerticalAlignment)barVerticalAlignment
{
    _barVerticalAlignment = barVerticalAlignment;
    
    switch (barVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
        case UIControlContentVerticalAlignmentBottom:
            self.waveFormLayer.transform = CATransform3DMakeScale(1., -1., 1.); // flip so bars move up, not down
            break;
        
        case UIControlContentVerticalAlignmentTop:
            self.waveFormLayer.transform = CATransform3DIdentity;
            break;
            
        default:
            NSAssert(false, @"Unsupported barVerticalAlignment: only bottom, top and center are supported");
            break;
    }
}

#pragma mark - Private Animation

- (void)addBarCount:(NSUInteger)barCount fromIndex:(NSUInteger)index
{
    for (NSUInteger i = index; i < barCount; i++) {
        NSNumber *barId = @(i);
        if (_barLayersByLayerId[barId]) {
            NSAssert(false, @"Bar layer with ID %@ already exists.", barId);
            continue;
        }
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = self.barColor.CGColor;
        _barLayersByLayerId[barId] = layer;
        [_barLayers addObject:layer];
        [_waveFormLayer addSublayer:layer];
    }
}

- (void)animateLayer:(CAShapeLayer *)layer withLayerId:(id<NSCopying>)layerId
{
    if (self.barAnimationsByLayerId[layerId]) {
        NSAssert(false, @"Animation already in progress on %@: %@", layer, layerId);
        return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.delegate = self;
    animation.duration = self.minimumBarAnimationDuration;
    
    CGPathRef startPath = CGPathCreateWithRoundedRect(CGRectMake(0, 0, self.barSize.width, 2.5), 1.25, 1.25, NULL);
    animation.fromValue = (__bridge id)startPath;
    CGPathRelease(startPath);
    
    CGPathRef path = [self newPathForBarLayer:layer];
    animation.toValue = (__bridge id)path;
    layer.path = path;
    CGPathRelease(path);
    
    // save the reference to the animated layer so that the layer delegate methods can operate on it
    [animation setValue:layerId forKey:kYFWaveformLayerReferenceKey];
    
    // Save a reference to the animation for this layer so that we can re-use it later.
    self.barAnimationsByLayerId[layerId] = animation;
    
    [layer addAnimation:animation forKey:kYFWaveformAnimationKey];
}

- (CFTimeInterval)randomDuration
{
    NSInteger modulo = (self.maximumBarAnimationDuration - self.minimumBarAnimationDuration) * 100;
    if (modulo <= 0) {
        return self.minimumBarAnimationDuration;
    }
    return self.minimumBarAnimationDuration + (rand() % modulo / 100.0);
}

- (CGPathRef)newPathForBarLayer:(CAShapeLayer *)waveLayer
{
    CGFloat layerHeight = waveLayer.bounds.size.height;
    
    // Calculate the minimum allowed height for the rectangle so that it has room for the rounded corners.
    // This formula was copied from a note in an assertion thrown by CGPathCreateWithRoundedRect :P
    NSInteger minValue = ceil((2.0 * self.barCornerRadius.height / layerHeight) * 1000.0);
    
    // Pick a target scale for the volume bar clamped to the range 5-50%. If the scale is currently
    // under 50%, we'll add 50% so that it's clamped from 55-100%. This prevents bars from ever
    // appearing to vanish completely.
    CGFloat targetScale;
    if (minValue >= 1000) {
        targetScale = 1.0;
    } else {
        targetScale = ((rand() % (1000 - minValue)) + minValue + 1) / 1000.0;
    }
    
    CGFloat barHeight = layerHeight * targetScale;
    
    CGFloat barY = 0;
    if (self.barVerticalAlignment == UIControlContentVerticalAlignmentCenter) {
        barY = (layerHeight - barHeight) / 2.0;
    }
    
    CGPathRef toPath = CGPathCreateWithRoundedRect(CGRectMake(0, barY, self.barSize.width, barHeight),
                                                   self.barCornerRadius.width,
                                                   self.barCornerRadius.height,
                                                   NULL);
    return toPath;
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    if (!flag) {
        return; // Don't re-animate if the animation was interrupted
    }
    
    id<NSCopying> layerId = [anim valueForKey:kYFWaveformLayerReferenceKey];
    if (!layerId) {
        return;
    }
    
    CAShapeLayer *barLayer = self.barLayersByLayerId[layerId];
    if (!barLayer) {
        return;
    }
    
    CABasicAnimation *animationTemplate = self.barAnimationsByLayerId[layerId];
    if (!animationTemplate) {
        return;
    }
    
    // To achieve smooth animations with no flickering, set the layer's properties as you want them
    // to be after the animation has completed. Then, in the same layout pass, add the animation from
    // the old/previous property value to the new/current property value. This way, the new value is
    // already available for display as soon as the animation has completed.
    // Basically the key understanding is that there are 2 sub-layers in every CALayer: one model and
    // another for presentation. Animations affect the presentation layer. Properties that are not set
    // in the presentation layer fall back to the model layer, and then to the base layer itself.
    // Just after the animation completes, it is removed, which causes the empty presentation layer
    // to fall all the way through the now empty model layer to the original layer properties... voila!
    
    CGPathRef path = [self newPathForBarLayer:barLayer];
    barLayer.path = path;
    animationTemplate.toValue = (__bridge id)path;
    animationTemplate.fromValue = anim.toValue;
    animationTemplate.duration = [self randomDuration];
    
    [barLayer addAnimation:animationTemplate forKey:kYFWaveformAnimationKey];
    CGPathRelease(path);
}

@end
