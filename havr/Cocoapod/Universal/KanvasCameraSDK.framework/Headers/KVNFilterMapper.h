//
//  KVNFilterMapper.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 7/6/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVNFilter.h"

@class KVNFilterRepository;


/*!
 * KVNFilterMapper is a model that exposes some of the metadata for the underlying KVNFilter.
 */
@interface KVNFilterMapper : NSObject

@property (readonly, nonatomic) NSString * thumbnail;
@property (readonly, nonatomic) NSURL * thumbnailURL;
@property (readonly, nonatomic) NSString * name;
@property (readonly, nonatomic) BOOL isGroup;
@property (readonly, nonatomic) BOOL enabled;
@property (readonly, nonatomic) BOOL visible;
@property (readonly, nonatomic) NSString * type;
@property (readonly, nonatomic) BOOL availableForPictures;
@property (readonly, nonatomic) BOOL availableForVideos;

/*!
 * @brief convenience construction method for an empty filter (if something requires it).
 * @return An empty filter
 */
+ (instancetype)emptyFilter;


/*!
 * @brief This method requires network access to download the necessary shader code and any textures associated with the image. Once downloaded, that data is cached
 * @param success on completion, it will return a KVNFilter, which in turn wraps a GPUImageFilterGroup or GPUImageFilter
 * @param failure on failure, it will return the error.
 */
- (void)buildFilter:(void(^)(KVNFilter *))success failure:(void(^)(NSError *))failure;

/*!
 * @brief This method is the exact same as above, but without KVNFilter in the completion
 * @param success on completion, it will return a GPUImageFilterGroup or GPUImageFilter
 */
- (void)buildGPUImageFilter:(void(^)(GPUImageOutput<GPUImageInput> *))success failure:(void(^)(NSError *))error;

@end
