//
//  KVNFilter.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 6/13/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <GPUImage/GPUImage.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

extern NSString * KVNFilterPropertyExceptionName;
extern NSString * KVNFilterTypeExceptionName;

@interface KVNFilter : NSObject

/*!
 * Editable properties for a filter. If the filter is composed, it returns an empty array
 * as only atomic filter can have their properties edited. This properties are the ones you can
 * use as parameters for setPropertyForName:. Refer to GPUImage documentation to see each filter's
 * valid ranges.
 */
@property (readonly, nonatomic) NSArray<NSString *> * editableProperties;

/*!
 * Initializes a filter with a shader string and a dictionary that matches the shader's properties
 * with a default value. This enables to use shaders with any number of properties.
 *
 * @param shader The shader for this filter. It must be written in GLSL and supports OpenGL ES 2.
 * @param properties A NSDictionary that matches each shader property with its default value.
 * The keys of this dictionary must exist as properties in the shader.
 */
- (instancetype)initWithShader:(NSString *)shader properties:(NSDictionary<NSString *, id> *)properties;

/*!
 * Initializes a filter with a GPUImageFilter or a GPUImageFilterGroup.
 */
- (instancetype)initWithGPUImageFilter:(GPUImageOutput<GPUImageInput> *)imageFilter;

/*!
 * Creates a filter that results from the chaining of ´self´ and ´filter´
 *
 * @warning It is not adviced to compose a filter with more than one filter.
 *
 * @return A new filter that represents the composition of ´self´ and ´filter´.
 */
- (KVNFilter *)compose:(KVNFilter *)filter;

/*!
 * Sets the value of the ´propertyName´ property in the filter to ´value´.
 * The property passed to this method must exist in the filter.
 * If the filter was created with initWithShader:properties:, ´propertyName´ must match one of the
 * properties passed in that method.
 */
- (void)setPropertyForName:(NSString *)propertyName value:(CGFloat)value;

/*!
 * Removes all the targets form this Filter. It's advisable to call this method if 
 * this filter should deallocate but was composed with another one which should not.
 * This method can unchain two KVNFilters but both could still be used on their own.
 */
- (void)removeAllTargets;

@end
