//
// Created by Tony Cheng on 3/1/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KVNStyle.h"

typedef void (^KVNStylesHandlerCompletionBlock)(BOOL success, UIImage *image);

@interface KVNStylesHandler : NSObject

/*
 * Saved styles. When an object of this class is instanced, local styles are saved in this array.
 * Calling fetchRemoteStyles:failure: is recommended, as it will update these styles.
 */
@property (nonatomic, readonly) NSArray<KVNStyle *> *styles;

+ (KVNStylesHandler *)sharedInstance;

/*
 * Fetches remote styles. If it succeedes, this method updates ´styles´. If it fails, it doesn't modify
 * ´styles´, so the cached styles can still be used.
 */
- (void)fetchRemoteStyles:(void(^)(NSArray<KVNStyle *> *))success failure:(void(^)(NSError *))failure;

/*
 * Sends the image to be processed remotely with a style. If an image has already been passed in, it will not upload again until reset is called.
 */
- (void)processImage:(UIImage *)image withStyle:(KVNStyle *)style withCompletionBlock:(KVNStylesHandlerCompletionBlock)completionBlock;

/*
 * Cancels the image uploading process. Also resets the cache
 */
- (void)reset;

@end
