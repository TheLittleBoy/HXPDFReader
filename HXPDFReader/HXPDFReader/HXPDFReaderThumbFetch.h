//
//  HXPDFReaderThumbFetch.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXPDFReaderThumbQueue.h"

@class HXPDFReaderThumbRequest;

@interface HXPDFReaderThumbFetch : HXPDFReaderThumbOperation

- (instancetype)initWithRequest:(HXPDFReaderThumbRequest *)options;

@end
