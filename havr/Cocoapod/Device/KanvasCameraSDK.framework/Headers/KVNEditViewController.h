//
// Created by Tony Cheng on 8/15/16.
// Copyright (c) 2016 Kanvas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KVNGifCreator.h"
#import "KVNEditSettings.h"
#import "KVNOutputImage.h"

@class KVNEditViewController;
@class KVNComposeDrawView;
@class KVNTextInputView;
@class KVNStampsPickerView;
@class KVNImageLinesView;
@class KVNLoadingView;
@class KVNFilterPickerViewController;
@class GPUImageFilter;
@class KVNStylesPickerViewController;
@class GPUImagePicture;
@class GPUImageMovie;
@class KVNOutputData;
@class KVNStyle;
@class KVNCSBView;
@class GPUImageContrastFilter;
@class GPUImageBrightnessFilter;
@class GPUImageSaturationFilter;

@protocol KVNEditViewControllerDelegate <NSObject>

- (void)editViewController:(KVNEditViewController *)viewController backButtonPressed:(id)sender;
- (void)editViewController:(KVNEditViewController *)viewController createdImage:(KVNOutputImage *)image;
- (void)editViewController:(KVNEditViewController *)viewController createdVideo:(NSURL *)videoDataURL;
- (void)editViewController:(KVNEditViewController *)viewController createdGif:(NSURL *)gifDataURL;

@optional

- (void)editViewController:(KVNEditViewController *)viewController didFinishWithOutputData:(KVNOutputData *)outputData;

@end

@interface KVNEditViewController : UIViewController

+ (KVNEditViewController *)verifiedViewController;
+ (KVNEditViewController *)verifiedViewControllerWithSettings:(KVNEditSettings *)settings;

/*
 * internal call from the camera to initialize with output data
 */
- (void)loadWithMetadata:(KVNOutputData *)outputData;

@property (nonatomic, weak) id <KVNEditViewControllerDelegate> delegate;

// should set one of these
@property (nonatomic, strong) UIImage *image; // for photo
@property (nonatomic, strong) NSURL *url; // for video
@property (nonatomic, strong) NSArray *imagesArray; // for gifs / burst

@property (nonatomic, strong) NSNumber *burstInterval; // controls gif burst speed
@property (nonatomic) BOOL shouldFit;

@property (nonatomic) AVCaptureDevicePosition originalCameraPosition;
@property (nonatomic) UIDeviceOrientation originalDeviceOrientation;

// just for analytics purposes
@property (nonatomic) BOOL comingFromCamera;
@property (nonatomic, copy) NSString *analyticsCategory;

// Replace to customize which options to show. By default, it shows all options.
@property (nonatomic) KVNEditSettings * settings;

@property (nonatomic, strong) NSURL *borderURL;
@property (nonatomic, strong) UIColor *borderColor;

@end
