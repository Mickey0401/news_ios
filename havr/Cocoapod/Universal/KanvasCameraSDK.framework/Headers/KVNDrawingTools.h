/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>

@protocol KVNDrawingTool <NSObject>

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) CGFloat lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint;
- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

- (void)draw;

@end

#pragma mark -

@interface KVNDrawingPenTool : UIBezierPath<KVNDrawingTool> {
    CGMutablePathRef path;
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint;

@end

#pragma mark -

@interface KVNDrawingEraserTool : KVNDrawingPenTool

@end

#pragma mark -

@interface KVNDrawingLineTool : NSObject<KVNDrawingTool>

@end

#pragma mark -

@interface KVNDrawingTextTool : NSObject<KVNDrawingTool>
@property (strong, nonatomic) NSAttributedString* attributedText;
@end

@interface KVNDrawingMultilineTextTool : KVNDrawingTextTool
@end

#pragma mark -

@interface KVNDrawingRectangleTool : NSObject<KVNDrawingTool>

@property (nonatomic, assign) BOOL fill;
@property (nonatomic, assign) BOOL clear;

@end

#pragma mark -

@interface KVNDrawingEllipseTool : NSObject<KVNDrawingTool>

@property (nonatomic, assign) BOOL fill;

@end

#pragma mark -

@interface KVNDrawingArrowTool : NSObject<KVNDrawingTool>
@end
