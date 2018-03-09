//
//  KVNImageProcessor.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 6/13/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KVNFilter.h"

@interface KVNImageProcessor : NSObject

/*!
 * Resolution size of resulting image. Default value is the inputImage's size.
 * This size has a cap of 1024x1024 for devices smaller or equal than Iphone5, and a cap of 2048x2048
 * for devices bigger than those. This is due to performance reasons.
 */
@property (nonatomic) CGSize processingSize;

/*!
 * processingSize is used for older devices. Defaults to NO;
 */
@property (nonatomic) BOOL ignoreProcessingSize;

/*!
 * force it to use the CGSize without distorting
 */
@property (nonatomic) BOOL forceProcessingSize;

/*!
 * View where the output with the processed image will be shown.
 */
@property (weak, nonatomic) UIView * outputView;

/*!
 * Filter with which the image will be processed.
 */
@property (strong, nonatomic) KVNFilter * filter;

/*!
 * CGAffineTransform that is applied to the output image.
 */
@property (nonatomic) CGAffineTransform imageTransform;

/*!
 * Creates a KVNImageProcessor.
 *
 * @warning It's not adviced to use the same instance of KVNFilter in more than one processor. Neither is adviced
 * to use a KVNFilter composed by an instance of KVNFilter which is used in another processor.
 *
 * @param inputImage The image to process.
 * @param filter A filter to apply to the image.
 * @param outputView The view where the processed image will be shown. Its reference is weak to 
 * avoid retain issues.
 */
- (instancetype)initWithImage:(UIImage *)inputImage filter:(KVNFilter *)filter outputView:(UIView *)outputView;

/*!
 * replaces the current image
 */
- (void)setImage:(UIImage *)image;

/*!
 * Processes the input image with the passed filter. The result is shown in the ouputView.
 * After the processing is done, the completion block is called. 
 * 
 * @param completion Block that is executed after processing. It can be nil.
 */
- (void)processImageWithCompletionHandler:(void(^)())completion;

/*!
 * Rotates the output image to the given orientation. Note that this method does not change the inputImage
 * orientation, as this class doesn't hold a reference to it.
 */
- (void)rotateWithOrientation:(UIImageOrientation)orientation;

/*!
 * Returns the processed image as a UIImage. This method processes the image,
 * so there's no need to call ´processImageWithCompletionHandler:´.
 * As long as you don't need the UIImage, avoid using this method as it's less performant.
 */
- (void)getFilteredImage:(void (^)(UIImage *))completion;

/*!
 * Set the frame in which the output will be displayed. By default, the outputView's frame will be used.
 */
- (void)setDisplayFrame:(CGRect)frame;

/*!
 * Set the output's display mode.
 */
- (void)setDisplayMode:(GPUImageFillModeType)displayMode;

@end
