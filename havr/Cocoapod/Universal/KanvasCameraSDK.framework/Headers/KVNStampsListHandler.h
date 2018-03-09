//
//  KVNStampsListHandler.h
//  KVNCameraSDK
//
//  Created by Tony Cheng on 9/30/16.
//
//

#import <Foundation/Foundation.h>
#import "KVNStampPack.h"
#import "KVNBorderPack.h"

#define kStampsFetchedNotification @"kStampsFetchedNotification"

@interface KVNStampsListHandler : NSObject

@property (nonatomic, readonly, copy) NSArray<KVNStampPack *> *stickerPackList;
@property (nonatomic, readonly, copy) NSArray<KVNBorderPack *> * borderPackList;
@property (nonatomic, readonly, copy) NSArray<KVNStampPack *> * overlayPackList;

+ (KVNStampsListHandler *)sharedInstance;

// Fetches the stamps from the API only once. If called again, it looks for the cache.
- (void)fetchStampsList:(void(^)(BOOL updated))completion;

// Provide an URL for custom content.
// Must be done before creating any of the SDK's visual screens.
- (void)setCustomContentFile:(NSString *)filename;

@end
