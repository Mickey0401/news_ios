//
// Created by Tony Cheng on 12/29/14.
// Copyright (c) 2014 Tracks Media, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KVNFlipbookSettings;
@class KVNFlipbookViewController;

@protocol KVNFlipbookViewControllerDelegate <NSObject>
- (void)flipbookViewController:(KVNFlipbookViewController *)flipbookViewController addMoreButtonPressed:(id)sender;
- (void)flipbookViewController:(KVNFlipbookViewController *)flipbookViewController dismissButtonPressed:(id)sender;
- (void)flipbookViewController:(KVNFlipbookViewController *)flipbookViewController finishedGifWithURL:(NSURL *)gifURL;
@end

@interface KVNFlipbookViewController : UIViewController

@property (nonatomic, weak) id <KVNFlipbookViewControllerDelegate> delegate;

@property (strong, nonatomic) KVNFlipbookSettings * settings;

+ (KVNFlipbookViewController *)verifiedViewController;
+ (KVNFlipbookViewController *)verifiedViewControllerWithSettings:(KVNFlipbookSettings *)settings;

- (void)addImages:(NSArray <UIImage *> *)images;

@end
