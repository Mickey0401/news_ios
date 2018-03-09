//
//  KVNOutputImage.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 4/27/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KVNOutputImage : NSObject

- (instancetype)initWithImage:(UIImage *)image
            deviceOrientation:(UIDeviceOrientation)deviceOrientation
               cameraPosition:(AVCaptureDevicePosition)cameraPosition;

@property (readonly, nonatomic) UIImage *outputImage;

// The device orientation in which the image was taken
@property (readonly, nonatomic) UIDeviceOrientation deviceOrientation;

// The position of the camera (back or front) in ehich the image was taken
@property (readonly, nonatomic) AVCaptureDevicePosition cameraPosition;

@end
