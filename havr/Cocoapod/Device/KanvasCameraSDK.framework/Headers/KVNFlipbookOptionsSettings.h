//
//  KVNFlipbookOptionsSettings.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 3/3/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface KVNFlipbookOptionsSettings : NSObject

/*!
 * Image for the close button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * closeImage;

/*!
 * Image for the accept button. It has a default value. Its dimensions must be at least 34x34
 */
@property (strong, nonatomic) UIImage * acceptImage;

/*!
 * Image for the duplicate option image. It has a default value. Its dimensions must be at least 24x24
 */
@property (strong, nonatomic) UIImage * duplicateImage;

/*!
 * Image for the rotate option image. It has a default value. Its dimensions must be 24x24
 */
@property (strong, nonatomic) UIImage * rotateImage;

/*!
 * Image for the delete option image. It has a default value. Its dimensions must be 24x24
 */
@property (strong, nonatomic) UIImage * deleteImage;

/*!
 * Tint color for the close button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * closeImageTintColor;

/*!
 * Tint color for the accept button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * acceptImageTintColor;

/*!
 * Tint color for the duplicate option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * duplicateImageTintColor;

/*!
 * Tint color for the rotate option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * rotateImageTintColor;

/*!
 * Tint color for the delete option button image.
 * @default Defaults to nil.
 */
@property (strong, nonatomic) UIColor * deleteImageTintColor;

/*!
 * Text color for the duplicate button title.
 * @default Defaults to RGB(169, 169, 169) #A9A9A9.
 */
@property (strong, nonatomic) UIColor * duplicateTitleColor;

/*!
 * Text color for the rotate button title.
 * @default Defaults to RGB(169, 169, 169) #A9A9A9.
 */
@property (strong, nonatomic) UIColor * rotateTitleColor;

/*!
 * Text color for the delete button title.
 * @default Defaults to RGB(169, 169, 169) #A9A9A9.
 */
@property (strong, nonatomic) UIColor * deleteTitleColor;

/*!
 * @description Enables/disables duplication of an image.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableDuplication;

/*!
 * @description Enables/disables the rotation of an image.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableRotation;

/*!
 * Enables/disables the deletion of an image.
 * @default Defaults to YES.
 */
@property (nonatomic) BOOL enableDeletion;

+ (instancetype)defaultSettings;

@end
