//
//  KVNVideoProcessor.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 6/15/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KVNFilter.h"

@interface KVNVideoProcessor : NSObject

/*!
 * Size of resulting video. Default value is the inputVideo's size.
 * This size has a cap of 1024x1024 for devices smaller or equal than Iphone5, and a cap of 2048x2048
 * for devices bigger than those. This is due to performance issues.
 */
@property (nonatomic) CGSize processingSize;

/*!
 * View where the output with the processed video will be shown.
 */
@property (weak, nonatomic) UIView * outputView;

/*!
 * Filter with which the image will be processed.
 */
@property (strong, nonatomic) KVNFilter * filter;

/*!
 * Creates a KVNVideoProcessor.
 *
 * @warning It's not adviced to use the same instance of KVNFilter in more than one processor. Neither is adviced
 * to use a KVNFilter composed by an instance of KVNFilter which is used in another processor.
 *
 * @param playerItem The video to process.
 * @param filter A filter to apply to the video.
 * @param outputView The view where the processed video will be shown. Its reference is weak to
 * avoid retain issues.
 */
- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem filter:(KVNFilter *)filter outputView:(UIView *)outputView;

/*!
 * Processes the input video with the passed filter. The result is shown in the ouputView.
 * After the processing is done, the completion block is called.
 *
 * @param completion Block that is executed after processing. It can be nil.
 */
- (void)processVideoWithCompletionHandler:(void(^)())completion;

/*!
 * Cancels the processing.
 */
- (void)cancelProcessing;

/*!
 * Exports the result of applying the passed filter to the video into newURL.
 * The resulting file will have ´size´ size as long as that size is a multiple of 16. If it's not, 
 * it will be enlargened to the closest multiple of 16.
 */
- (void)exportVideoAtURL:(NSURL *)url withSize:(CGSize)size toURL:(NSURL *)newURL completion:(void(^)(NSURL *))completionHandler;

@end
