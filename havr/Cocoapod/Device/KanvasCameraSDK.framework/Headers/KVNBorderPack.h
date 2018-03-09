//
//  KVNBorderPack.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 6/12/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVNBorderPack : NSObject

@property (readonly, nonatomic) NSUInteger count;
@property (readonly, nonatomic) NSString * name;

- (instancetype)initWithJSON:(NSDictionary *)json;

- (NSURL *)thumbURLForBorderAtIndex:(NSUInteger)index;
- (NSURL *)URLForBorderAtIndex:(NSUInteger)index;
- (NSString *)nameForBorderAtIndex:(NSUInteger)index;

@end
