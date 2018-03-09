//
//  KVNFilterListHandler.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 7/6/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVNFilterMapper.h"

/*!
 * This is the primary interface to get the available filters from the server.
 * The filters are in the KVNFilterMapper form, which constructs the final KVNFilter through it's buildFilter: method.
 */
@interface KVNFilterListHandler : NSObject

@property (nonatomic, readonly, copy) NSArray<KVNFilterMapper *> * allPictureFilters;
@property (nonatomic, readonly, copy) NSArray<KVNFilterMapper *> * allVideoFilters;

+ (instancetype)sharedInstance;

/*!
 * @brief Fetches the stamps from the API only once. If called again, it looks for the cache.
 * @param completion boolean for the array methods
 */
- (void)fetchFilterList:(void(^)(BOOL updated))completion;

/*!
 * @return returns a subset of the picture filters based on visibility. It overlaps with the video filters
 */
- (NSArray<KVNFilterMapper *> *)visiblePictureFilters;

/*!
 * @return returns a subset of the video filters based on visibility. It overlaps with the image filters
 */
- (NSArray<KVNFilterMapper *> *)visibleVideoFilters;
- (NSArray<KVNFilterMapper *> *)allFilters;

@end
