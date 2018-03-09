//
//  KVNGifCreator.h
//  KVNCameraSDK
//
//  Created by Tony Cheng on 8/24/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @brief These enums are only used as a shorthand for the quality param in the creation methods
 */
typedef enum {
    kKVNGifQualityLow, // 0.25
    kKVNGifQualityMedium, // 0.5
    kKVNGifQualityHighest // 1.0
} kKVNGifQuality;

typedef void (^KVNGifImageCompletionBlock)(BOOL success, NSURL *fileURL);

@interface KVNGifCreator : NSObject

//
/*!
 * @brief These next two methods create gifs or videos given a UIImage array.
 *
 * @imagesArray
 * array of UIImage. If the UIImages are different sizes, it will take the size of the first image and the remaining images are scaled to fill
 *
 * @overlayView
 * If present, the overlay view determines the size of the gif. The overlay view is superimposed on top of each frame of the gif.
 *
 * @param autoreverse
 * determines whether the gif will autoreverse, essentially doubling duration
 *
 * @param quality
 * value from 0.0 to 1.0 that determines the scaling and file size. 0.0 will fail with no dimensions
 *
 * @param duration
 * duration in seconds for each frame
 *
 * @param completionBlock
 * callback that returns a bool for success and a fileURL pointing to either a gif or a video
 *
 */
+ (void)createGifFromImagesArray:(NSArray *)imagesArray overlayView:(UIView *)overlayView shouldAutoReverse:(BOOL)autoreverse quality:(float)quality frameLength:(NSTimeInterval)duration completionBlock:(KVNGifImageCompletionBlock)completionBlock;
+ (void)createVideoFromImagesArray:(NSArray <UIImage *>*)imagesArray shouldAutoReverse:(BOOL)autoreverse fps:(NSTimeInterval)fps completionBlock:(KVNGifImageCompletionBlock)completionBlock;


/*!
 * @brief convenience method to create a video from a single image
 *
 * @param image
 * @param duration
 * @param completionBlock
 */
+ (void)createVideoFromImage:(UIImage *)image duration:(NSTimeInterval)duration completionBlock:(KVNGifImageCompletionBlock)completionBlock;

@end
