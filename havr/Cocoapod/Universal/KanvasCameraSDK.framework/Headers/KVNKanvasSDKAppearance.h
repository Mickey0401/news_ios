//
//  KVNKanvasSDKAppearance.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 3/2/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIFont.h>

/*!
 * Class that has some styles to override throughout the whole app.
 * It is recommended to do so in the AppDelegate or somewhere before the views are loaded,
 * to avoid runtime changes in the app's UI.
 */

@interface KVNKanvasSDKAppearance : NSObject

/*!
 * Regular font name. Defaults to nil.
 */
@property (strong, nonatomic) NSString * regularFontName;

/*!
 * Medium font name. Defaults to nil.
 */
@property (strong, nonatomic) NSString * mediumFontName;

/*!
 * Bold font name. Defaults to nil.
 */
@property (strong, nonatomic) NSString * boldFontName;

+ (instancetype)sharedInstance;

/*!
 * Returns a font with the given size. The font name is the one set in `regularFontSize`. 
 * If `regularFontSize` is nil, defaults to the system regular font.
 */
- (UIFont *)regularFontWithSize:(CGFloat)size;

/*!
 * Returns a font with the given size. The font name is the one set in `mediumFontSize`.
 * If `mediumFontSize` is nil, defaults to the system medium font.
 */
- (UIFont *)mediumFontWithSize:(CGFloat)size;

/*!
 * Returns a font with the given size. The font name is the one set in `boldFontSize`.
 * If `boldFontSize` is nil, defaults to the system bold font.
 */
- (UIFont *)boldFontWithSize:(CGFloat)size;

@end
