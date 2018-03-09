//
// Created by Cheng, Tony on 3/16/17.
// Copyright (c) 2017 Tony Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kKVNOutputTypeKey; // this is the type of output
extern NSString * const kKVNOutputStickersKey;
extern NSString * const kKVNOutputTextsKey;
extern NSString * const kKVNOutputFiltersKey;
extern NSString * const kKVNOutputBordersKey;
extern NSString * const kKVNOutputStyleKey;

typedef enum {
    kKVNOutputEditImage,
    kKVNOutputEditGif,
    kKVNOutputEditVideo
} kKVNOutputEditType;

@interface KVNOutputData : NSObject

@property (readonly, nonatomic) NSNumber * createdAt;
@property (readonly, nonatomic) NSNumber * hitage;

- (id)initWithDictionary:(NSDictionary *)dictionary;

// updates internal dictionary
- (void)updateStickers:(NSArray <NSString *> *)stickers;
- (void)updateTexts:(NSArray <NSString *> *) texts;
- (void)updateFilters:(NSArray <NSString *> *) filters;
- (void)updateBorders:(NSArray <NSString *> *) borders;
- (void)updateStyle:(NSString *)style;

// convenience methods
- (NSString *)outputType;
- (NSString *)style;
- (NSArray <NSString *> *)stickers;
- (NSArray <NSString *> *)texts;
- (NSArray <NSString *> *)filters;
- (NSArray <NSString *> *)borders;

// This sets the hitage
- (void)setSendDate:(NSDate *)sendDate;
- (NSDictionary *)encode;

@end
