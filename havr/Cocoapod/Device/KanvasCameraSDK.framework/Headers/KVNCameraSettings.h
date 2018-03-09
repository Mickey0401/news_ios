//
//  KVNCameraSettings.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 3/2/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <AVFoundation/AVCaptureDevice.h>

#import "KVNEditSettings.h"

/*!
 * kCameraSettingMode None uses the last used option in previous sessions
 */
typedef enum {
    kCameraSettingModeNone,
    kCameraSettingModePhoto,
    kCameraSettingModeGif,
    kCameraSettingModeVideo,
    kCameraSettingModeStopMotion
} kCameraSettingMode;

@interface KVNCameraSettings : NSObject

/*!
 * Duration for stop motion frame (tapping on button). Default value is 0.1
 */
@property (nonatomic) NSTimeInterval stopMotionFrameDuration;

/*!
 * Image for the stop motion delete button. It has a default value. Its dimensions must be at least 34x34
 */
@property (nonatomic, strong) UIImage * cameraSegmentDeleteIcon;

/*!
 * Image for the stop motion delete pressed button. It has a default value. Its dimensions must be at least 34x34
 */
@property (nonatomic, strong) UIImage * cameraSegmentDeleteIconPressed;

/*!
 * Image for the stop motion arrow icon. Its dimensions must be at least 34x34
 */
@property (nonatomic, strong) UIImage * nextArrowIcon;

/*!
 * Image for the stop motion on button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * stopMotionOnImage;

/*!
 * Image for the stop motion off button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * stopMotionOffImage;

/*!
 * Image for the first grid state button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * grid2LinesEqualImage;

/*!
 * Image for the second grid state button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * grid3LinesEqualImage;

/*!
 * Image for the third grid state button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * gridCenteredImage;

/*!
 * Image for the grid off button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * gridOffImage;

/*!
 * Image for the flash on button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * flashOnImage;

/*!
 * Image for the flash off button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * flashOffImage;

/*!
 * Image for the timer off button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * timerOffImage;

/*!
 * Image for the first value of the timer on button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * timerOn0Image;

/*!
 * Image for the second value of the timer on button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * timerOn1Image;

/*!
 * Image for the close button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * closeImage;

/*!
 * Image for the camera rotation (front-rear) button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * rotateImage;

/*!
 * Image for the camera shoot mode button. It has a default value. Its dimensions must be at least 30x30
 */
@property (strong, nonatomic) UIImage * cameraImage;

/*!
 * Image for the video mode button. It has a default value. Its dimensions must be at least 30x30
 */
@property (strong, nonatomic) UIImage * videoImage;

/*!
 * Image for the gif button. It has a default value. Its dimensions must be at least 30x30
 */
@property (strong, nonatomic) UIImage * gifImage;

/*!
 * Image for the filters button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * filtersImage;

/*!
 * Tint color for the camera button press circle.
 * @default Defaults to green-blue.
 */
@property (strong, nonatomic) UIColor * selectedCameraColor;

/*!
 * Tint color for the stop motion on button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * stopMotionOnImageTintColor;

/*!
 * Tint color for the stop motion off button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * stopMotionOffImageTintColor;

/*!
 * Tint color for the first grid option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * grid2LinesEqualImageTintColor;

/*!
 * Tint color for the second grid option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * grid3LinesEqualImageTintColor;

/*!
 * Tint color for the third grid option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * gridCenteredImageTintColor;

/*!
 * Tint color for the grid off button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * gridOffImageTintColor;

/*!
 * Tint color for the flash on button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * flashOnImageTintColor;

/*!
 * Tint color for the flash off button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * flashOffImageTintColor;

/*!
 * Tint color for the timer off button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * timerOffImageTintColor;

/*!
 * Tint color for the first timer on button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * timerOn0ImageTintColor;

/*!
 * Tint color for the second timer on button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * timerOn1ImageTintColor;

/*!
 * Tint color for the close button image. 
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * closeImageTintColor;

/*!
 * Tint color for the camera rotation (front-back) button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * rotateImageTintColor;

/*!
 * Tint color for the camera shoot mode button image. 
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * cameraImageTintColor;

/*!
 * Tint color for the video mode button image. 
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * videoImageTintColor;

/*!
 * Tint color for the gif mode button image. 
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * gifImageTintColor;

/*!
 * Tint color for the filters button image. 
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * filtersImageTintColor;

/*!
 * Color for the border of the selected camera mode. 
 * @default Defaults to white.
 */
@property (strong, nonatomic) UIColor * selectedBorderColor;

/*!
 * Color for the timer bar color of the selected video modes.
 * @default Defaults to the teal color.
 */
@property (strong, nonatomic) UIColor * timerBarColor;

/*!
 * Enables/disables selected camera mode's border.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableSelectedBorder;

/*!
 * Enables/disables stop motion option.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableStopMotion;

/*!
 * Enables/disables grid option.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableGrid;

/*!
 * Enables/disables flash option.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableFlash;

/*!
 * Enables/disables timer button.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableTimer;

/*!
 * Enables/disables changing the default camera view (front-back).
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableCameraRotation;

/*!
 * Enables/disables camera shoot mode.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableCameraMode;

/*!
 * Enables/disables video mode.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableVideoMode;

/*!
 * Enables/disables gif mode.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableGifMode;

/*!
 * Enables/disables filter selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableFilters;

/*!
 * Enables/disables border selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableBorders;

/*!
 * Enables/disables asset picker.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableAssetPicker;

/*!
 * This bool toggles whether the scaling mode should be set to the kEditScaleMode specified in KVNEditSettings for library items. By default, the scaling mode will be changed to kEditScaleModeFit for convenience
 * @default Defaults to NO.
 */
@property (nonatomic) BOOL retainScaleModeForAssetItems;

/*!
 * Camera default position (front or back).
 * @default Defaults to AVCaptureDevicePositionBack.
 */
@property (nonatomic) AVCaptureDevicePosition defaultCameraPosition;

/*!
 * @default Defaults to kCameraSettingNone. Otherwise, it will go down the list to the next available option
 */
@property (nonatomic) kCameraSettingMode defaultCameraMode;

/*!
 * determines whether the default recording action is holding or tapping to Record.
 * @default Defaults to true
 */
@property (nonatomic) BOOL tapToRecord;

/*!
 * number of frames captured for gifs. Defaults to 10
 */
@property (nonatomic) NSUInteger numOfFrames;

// change this before presenting the camera. Defaults to 15 seconds
@property (nonatomic) NSTimeInterval maxVideoDuration;

// the time between shots from the input camera. defaults to 0.05f
@property (nonatomic) NSTimeInterval burstInputInterval;

// the frames per second for the output burst video. defaults to 0.05f
@property (nonatomic) NSTimeInterval burstOutputInterval;

/*!
 * Edit controller settings. Defaults to [KVNEditSettings defaultSettings]
 */

@property (strong, nonatomic) KVNEditSettings * editSettings;

+ (instancetype)defaultSettings;

@end
