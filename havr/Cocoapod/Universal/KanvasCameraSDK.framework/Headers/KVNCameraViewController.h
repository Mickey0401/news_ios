//
// Created by Cheng, Tony on 8/11/16.
// Copyright (c) 2016 Kanvas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KVNGifCreator.h"
#import "KVNCameraSettings.h"

@class KVNCameraViewController;
@class KVNJSTGradientView;
@class AVCaptureStillImageOutput;
@class AVCaptureVideoDataOutput;
@class AVAssetWriter;
@class AVAssetWriterInput;
@class AVAssetWriterInputPixelBufferAdaptor;
@class KVNLoadingView;
@class SWAVSource;
@class SWRecordingEngine;
@class SCNView;
@class GPUImageMovieWriter;
@class GPUImageMovie;
@class GPUImagePixellateFilter;
@class KVNFilterPickerViewController;
@class GPUImageFilter;
@class KVNImageLinesView;
@class KVNOutputData;

@protocol KVNCameraViewControllerDelegate <NSObject>
// called when camera is finished with output. Need to manually implement dismissal
- (void)cameraViewController:(KVNCameraViewController *)cameraViewController didFinishWithImage:(UIImage *)image;

- (void)cameraViewController:(KVNCameraViewController *)cameraViewController didFinishWithVideo:(NSURL *)fileURL;

- (void)cameraViewController:(KVNCameraViewController *)cameraViewController didFinishWithGifURL:(NSURL *)fileURL;

// called when the dismiss button is pressed. Need to manually implement dismissal
- (void)cameraViewController:(KVNCameraViewController *)cameraViewController willDismiss:(id)sender;

@optional
- (void)cameraViewController:(KVNCameraViewController *)cameraViewController didFinishWithOutputData:(KVNOutputData *)outputData;
@end

@interface KVNCameraViewController : UIViewController
@property (nonatomic, weak) id <KVNCameraViewControllerDelegate> delegate;

+ (KVNCameraViewController *)verifiedViewController;
+ (KVNCameraViewController *)verifiedViewControllerWithSettings:(KVNCameraSettings *)settings;

/*
 * interface for breaking down the camera. only call when dismissing the camera
 */
- (void)stopCameraCaptureAndRecording;

@property (nonatomic, copy) NSString *shaderString;

// mute audio. change this before starting recording. Otherwise, the value will not change
@property (nonatomic) BOOL muteAudio;

// Replace to customize which edit options to show. By default, it shows all options.
@property (nonatomic, strong) KVNCameraSettings * settings;

@end
