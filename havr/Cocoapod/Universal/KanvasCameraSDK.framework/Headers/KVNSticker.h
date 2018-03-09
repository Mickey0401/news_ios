//
//  KVNSticker.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 4/12/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KVNStampProvider;

@interface KVNSticker : NSObject <NSCoding>

@property (readonly, nonatomic) NSString * imageURL;
@property (nonatomic, strong) KVNStampProvider *provider;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *packName;

- (instancetype)initWithURL:(NSString *)string;

@end
