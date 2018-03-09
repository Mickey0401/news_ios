//
//  KanvasSDK.h
//  KanvasSDK
//
//  Created by Cheng, Tony on 8/1/16.
//  Copyright © 2016 Kanvas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KanvasSDK : NSObject

+ (BOOL)initializeWithClientID:(NSString *)clientID signature:(NSString *)signature;

+ (BOOL)clientVerified;
+ (NSString *)clientID;
+ (NSString *)sdkVersion;

@end
