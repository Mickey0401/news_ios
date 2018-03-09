//
//  KVNStampPack.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 4/17/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVNSticker.h"

@class KVNStampProvider;

// @warning Abstract class. Do not instantiate.
@interface KVNStampPack : NSObject {
    @protected
    NSUInteger _count;
    KVNStampProvider * _provider;
}

@property (readonly, nonatomic) NSString * name;
@property (readonly, nonatomic) NSNumber * order;
@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic) KVNStampProvider * provider;
@property (readonly, nonatomic) NSString * thumbURL;

- (instancetype)initWithJSON:(NSDictionary *)json;

// @warning Abstract methods. Redefine in subclasses.
- (void)fetchStickers:(void(^)(NSArray<KVNSticker *> *))completion;

@end
