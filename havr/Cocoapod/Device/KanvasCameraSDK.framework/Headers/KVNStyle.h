//
//  KVNStyle.h
//  KanvasCameraSDK
//
//  Created by Damian Finkelstein on 6/14/17.
//  Copyright © 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVNStyle : NSObject

@property (nonatomic, readonly) NSString *serverStyleName;
@property (nonatomic, readonly) NSString *readableStyleName;
@property (nonatomic, readonly) NSURL *thumbnailURL;

- (instancetype)initWithDict:(NSDictionary *)dict basePath:(NSString *)path;

@end
