//
//  UIView+RenderImage.h
//  kanvas
//
//  Created by Tom Corwine on 5/30/13.
//  Copyright (c) 2013 Tracks Media, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KVNRenderImage)

- (UIImage *)screenshot;
- (UIImage *)screenToWidth:(CGFloat)length; // resizes to fixed width
- (UIImage *)screenshotWithSize:(CGSize)size;
- (UIImage *)screenshotWithoutScale;

- (UIImage *)renderThumbnail;
- (UIImage *)renderImageFromEAGLLayerWithTransparency:(BOOL)transparency;

/**
 * @brief convenience method for merging an overlay view onto another image
 *
 * @param image - the underlying image beneath the view
 * @param shouldFill - whether the overlay image should aspect fill to the size
 * @param size - size of output image
 * @param completionBlock - bool success, output UIImage
 */
- (void)mergeOntoImage:(UIImage *)image resizeToFill:(BOOL)shouldFill size:(CGSize)size completion:(void (^)(BOOL success, UIImage *outputImage))completionBlock;

@end
