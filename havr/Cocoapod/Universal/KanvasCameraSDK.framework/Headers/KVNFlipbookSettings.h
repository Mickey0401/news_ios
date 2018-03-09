//
//  KVNFlipbookSettings.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 3/3/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "KVNFlipbookOptionsSettings.h"

@class KVNEditSettings;

@interface KVNFlipbookSettings : NSObject

/*!
 * Image for the close button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * closeImage;

/*!
 * Image for the add frame button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * addFrameImage;

/*!
 * Image for the send button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * sendImage;

/*!
 * Image for the frame options button. It has a default value. Its dimensions must be at least 32x32
 */
@property (strong, nonatomic) UIImage * optionsImage;

/*!
 * Tint color for the close button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * closeImageTintColor;

/*!
 * Tint color for the add frame button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * addFrameImageTintColor;

/*!
 * Tint color for the send button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * sendImageTintColor;

/*!
 * Tint color for the options button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * optionsImageTintColor;

/*!
 * @description Enables/disables options selector.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableOptionsButton;

/*!
 * Selected image settings. Defaults to [KVNFlipbookOptionsSettings defaultSettings]
 * @default Defaults to YES.
 */
@property (strong, nonatomic) KVNFlipbookOptionsSettings * flipbookOptionsSettings;


/*!
 * Selected editing settings. Defaults to [KVNEditSettings defaultSettings]
 * @default Defaults to YES.
 */
@property (strong, nonatomic) KVNEditSettings * editSettings;

+ (instancetype)defaultSettings;

@end
