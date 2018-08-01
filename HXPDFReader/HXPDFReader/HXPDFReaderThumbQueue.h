//
//  HXPDFReaderThumbQueue.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXPDFReaderThumbQueue : NSObject <NSObject>

+ (HXPDFReaderThumbQueue *)sharedInstance;

- (void)addLoadOperation:(NSOperation *)operation;

- (void)addWorkOperation:(NSOperation *)operation;

- (void)cancelOperationsWithGUID:(NSString *)guid;

- (void)cancelAllOperations;

@end

#pragma mark -

//
//	ReaderThumbOperation class interface
//

@interface HXPDFReaderThumbOperation : NSOperation

@property (nonatomic, strong, readonly) NSString *guid;

- (instancetype)initWithGUID:(NSString *)guid;

@end
