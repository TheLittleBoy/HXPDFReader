//
//  HXPDFReaderThumbCache.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFReaderThumbRequest.h"

@interface HXPDFReaderThumbCache : NSObject <NSObject>

+ (HXPDFReaderThumbCache *)sharedInstance;

+ (void)touchThumbCacheWithGUID:(NSString *)guid;

+ (void)createThumbCacheWithGUID:(NSString *)guid;

+ (void)removeThumbCacheWithGUID:(NSString *)guid;

+ (void)purgeThumbCachesOlderThan:(NSTimeInterval)age;

+ (NSString *)thumbCachePathForGUID:(NSString *)guid;

- (id)thumbRequest:(HXPDFReaderThumbRequest *)request priority:(BOOL)priority;

- (void)setObject:(UIImage *)image forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeNullForKey:(NSString *)key;

- (void)removeAllObjects;

@end
