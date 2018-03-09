//
// Created by Tony Cheng on 9/22/17.
// Copyright (c) 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kWatermarkHandlerTopLeft,
    kWatermarkHandlerTopRight,
    kWatermarkHandlerBottomLeft,
    kWatermarkHandlerBottomRight
} kWatermarkHandlerGravity;

@interface KVNWatermarkHandler : NSObject

+ (UIImage *)watermarkWithBaseImage:(UIImage *)image watermark:(UIImage *)watermark gravity:
        (kWatermarkHandlerGravity)gravity;

+ (void)watermarkGifAtURL:(NSURL *)gifURL watermark:(UIImage *)watermark gravity:
        (kWatermarkHandlerGravity)gravity completion:(void (^)(NSURL *))completionBlock;

// not yet implemented
+ (NSURL *)watermarkVideoAtURL:(NSURL *)videoURL watermark:(UIImage *)watermark gravity:
        (kWatermarkHandlerGravity)gravity;

@end
