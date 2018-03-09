//
//  WaveformView.h
//  Waveform
//
//  Created by Adam Kaplan on 3/5/16.
//  Copyright © 2016. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveformView : UIView

/**
 *  The number of bars that this instance was initialized with
 */
@property (nonatomic, readonly) NSUInteger numberOfBars;

/**
 *  The corner radius for the bars. The corner radius height and width must be within 0 and
 *  twice the `barSize` height and width, respectively. Values outside of this range will be clamped
 *  to the nearest limit value: either 0, `2.0 * self.barSize.height` (or width, whichever applies).
 *  Default is `(CGSize){1.25, 1.25}`.
 *
 *  If this value is set while animations are active, the new value is animated to during the next
 *  animation step. This property is animatable.
 */
@property (nonatomic) CGSize barCornerRadius UI_APPEARANCE_SELECTOR;

/**
 *  The size of the bars. This value _must not_ be negative or exceed twice the respective `barCornerRadius`
 *  value for the width or height. Default is `(CGSize){10.0, 30.0}`
 *
 *  If this value is set while animations are active, the new value is animated to during the next
 *  animation step. This property is animatable.
 */
@property (nonatomic) CGSize barSize UI_APPEARANCE_SELECTOR;

/**
 *  The spacing between successive bars. When the value is negative, behavior is undefined. Default
 *  is 2.0.
 *
 *  This value is not implicitely animated. Bar spacing is adjust during the next layout pass.
 *  This property is animatable.
 */
@property (nonatomic) CGFloat barSpacing UI_APPEARANCE_SELECTOR;

/**
 *  The color used to fill the bars. A `nil` value will render transparent bars. Default is white.
 *
 *  This property is animatable.
 */
@property (nonatomic, nullable) UIColor *barColor UI_APPEARANCE_SELECTOR;

/**
 *  The minimum animation duration for bar size changes. The animation duration used for any bar
 *  changes is a random value chosed between `minimumBarAnimationDuration` and
 *  `maximumBarAnimationDuration`. For a constant duration, set these values to be the same. Default
 *  is 0.4s.
 *
 *  If the minimum duration exceeds the maximum duration, the minimum duration is used.
 *
 *  This takes effect during the next animation phase.
 */
@property (nonatomic) CFTimeInterval minimumBarAnimationDuration UI_APPEARANCE_SELECTOR;

/**
 *  The maximum animation duration for bar size changes. The animation duration used for any bar
 *  changes is a random value chosed between `minimumBarAnimationDuration` and
 *  `maximumBarAnimationDuration`. For a constant duration, set these values to be the same. default
 *  is 1.0s.
 *
 *  If the minimum duration exceeds the maximum duration, the minimum duration is used.
 *
 *  This takes effect during the next animation phase.
 */
@property (nonatomic) CFTimeInterval maximumBarAnimationDuration UI_APPEARANCE_SELECTOR;

/**
 *  The vertical alignment of the bars. Supported values are UIControlContentVerticalAlignmentCenter,
 *  UIControlContentVerticalAlignmentTop, and UIControlContentVerticalAlignmentBottom. These values
 *  control the point at which the bars appear to "grow" from. With the center alignment, the bars
 *  will grow equally upward and downward. Default is UIControlContentVerticalAlignmentTop.
 *
 *  If this value is set while animations are active, the new value is animated to during the next
 *  animation step.
 */
@property (nonatomic) UIControlContentVerticalAlignment barVerticalAlignment UI_APPEARANCE_SELECTOR;

/**
 *  Initializes a WaveformView with the specified number of bars and frame set to CGRectZero.
 *
 *  @param barCount The number of bars to display.
 *
 *  @return An initialized WaveformView
 */
- (_Nullable instancetype)initWithBarCount:(NSUInteger)barCount NS_DESIGNATED_INITIALIZER;

/**
 *  Start all bar animations.
 */
- (void)startAnimating;

/**
 *  Immediately removes all in-flight bar animations.
 */
- (void)stopAnimating;

@end
