//
//  HXPDFReaderThumbRequest.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFDocument.h"

@class HXPDFReaderThumbView;

@interface HXPDFReaderThumbRequest : NSObject <NSObject>

@property (nonatomic, strong, readonly) HXPDFDocument *document;
@property (nonatomic, strong, readonly) NSString *cacheKey;
@property (nonatomic, strong, readonly) NSString *thumbName;
@property (nonatomic, strong, readwrite) UIImageView *thumbView;
@property (nonatomic, assign, readonly) NSUInteger targetTag;
@property (nonatomic, assign, readonly) NSInteger thumbPage;
@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, assign, readonly) CGFloat scale;

+ (instancetype)newForView:(UIImageView *)view document:(HXPDFDocument*)document page:(NSInteger)page size:(CGSize)size;

@end
