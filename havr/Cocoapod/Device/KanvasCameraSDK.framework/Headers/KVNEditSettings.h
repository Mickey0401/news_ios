//
//  KVNEditSettings.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 2/23/17.
//
//

#import <Foundation/Foundation.h>
#import "KVNStampsPickerMode.h"
#import <KanvasCameraSDK/KVNGifCreator.h>
#import <UIKit/UIImage.h>

typedef enum {
    kEditScaleModeFill,
    kEditScaleModeFit
} kEditScaleMode;

@interface KVNEditSettings : NSObject <NSCopying>

/*
 * @description Settings for scale mode. Only applies to images currently.
 * @default This defaults to scale mode kEditScaleModeFill
 */
@property (nonatomic) kEditScaleMode defaultScaleMode;

/*!
 * @description Settings for gif export size. As quality increases, memory load and processing time increases. kKVNGifQualityLow is equivalent to setting gifCompressionFactor to 0.25, kKVNGifQualityMedium == 0.5, kKVNGifQualityHighest = 1.0f;
 * @default Defaults to kKVNGifQualityLow.
 */
@property (nonatomic) kKVNGifQuality gifQuality;

/*!
 * @description Settings for gif export compression. This is a value between 0.0 and 1.0. 1.0 represents full screen size;
 * @default Defaults to nil.
 */
@property (nonatomic, strong) NSNumber *gifCompressionFactor;

/*!
 * @description Enables/disables filters selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableFilters;

/*!
 * Enables/disables border selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableBorders;

/*!
 * @description Enables/disables text selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableText;

/*!
 * @description Enables/disables drawing selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableDrawing;

/*!
 * @description Enables/disables image editor.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableImageEditor;

/*!
 * @description Enables/disables time selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableTiming;

/*!
 * @description Enables/disables image scaling button.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableScaling;

/*!
 * @description Enables/disables image rotation button.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableRotation;

/*!
 * @description Enables/disables styles selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableStyles;

/*!
 * Enables/disables stamp selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableStamps;

/*!
 * Enables/disables mirroring selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableMirroring;

/*!
 * Enables/disables grid selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableGrid;

/*!
 * Indicates which views inside mode are visible. Ignored if enabledStamps is NO.
 * @default Defaults to KVNStampsPickerModeAll.
 */
@property (nonatomic) KVNStampsPickerMode stampsPickerMode;

/*!
 * Image for the scale button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * scaleImage;

/*!
 * Image for the back button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * backImage;

/*!
 * Image for the filter selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * filtersImage;

/*!
 * Image for the text selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * textImage;

/*!
 * Image for the drawing selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * drawingImage;

/*!
 * Image for the image editor selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * imageEditorImage;

/*!
 * Image for the stamp selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * stampsImage;


/*!
 * Image for the styles selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * stylesImage;


/*!
 * Image for the timer selector. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * timingImage;

/*!
 * Image for the rotate button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * rotateImage;

/*!
 * Image for the mirroring button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * mirroringImage;

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
 * Image for the trash button. It has a default value. Its dimensions must be at least 60x60
 */
@property (strong, nonatomic) UIImage * trashImage;

/*!
 * Image for the selected trash button. Defaults to trashImage. Ignored if there's no trashImage. 
 * Its dimensions must be at least 60x60
 */
@property (strong, nonatomic) UIImage * selectedTrashImage;

/*!
 * Image for the send button. It has a default value. Its dimensions must be at least 60x60
 */
@property (strong, nonatomic) UIImage * sendImage;

/*!
 * Tint color for the back button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * backImageTintColor;

/*!
 * Tint color for the filters button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * filtersImageTintColor;

/*!
 * Tint color for the stamps button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * stampsImageTintColor;

/*!
 * Tint color for the styles button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * stylesImageTintColor;


/*!
 * Tint color for the text button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * textImageTintColor;

/*!
 * Tint color for the drawing button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * drawingImageTintColor;

/*!
 * Tint color for the image editor button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * imageEditorImageTintColor;

/*!
 * Tint color for the send button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * sendImageTintColor;

/*!
 * Tint color for the trash button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * trashImageTintColor;

/*!
 * Tint color for the selected trash button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * selectedTrashImageTintColor;

/*!
 * Tint color for the timing button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * timingImageTintColor;

/*!
 * Tint color for the rotate button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * rotateImageTintColor;

/*!
 * Tint color for the mirroring button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * mirroringImageTintColor;

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
 * If set, watermarkImage is applied to all exported images, gifs, and videos
 * @default Defaults to nil
 */
@property (nonatomic, strong) UIImage *watermarkImage;

/*!
 * If true, the picker will have an extra section at the beginning that contains the most recently used stickers and
 * overlays
 * @default Defauls to false
 */
@property (nonatomic) BOOL enableRecentStamps;

typedef enum {
    kEditWatermarkTopLeft,
    kEditWatermarkTopRight,
    kEditWatermarkBottomLeft,
    kEditWatermarkBottomRight
} kEditWatermarkGravity;
/*!
 * @brief determines the location of the watermark. Defaults to kEditWatermarkBottomRight
 */
@property (nonatomic) kEditWatermarkGravity watermarkGravity;

+ (instancetype)defaultSettings;

/*!
 * @return a copy with references to original UIColor and UIImage items
 */
- (KVNEditSettings *)shallowCopy;

@end
