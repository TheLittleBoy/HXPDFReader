//
//  HXPDFReaderThumbQueue.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFReaderThumbQueue.h"

@implementation HXPDFReaderThumbQueue
{
	NSOperationQueue *loadQueue;

	NSOperationQueue *workQueue;
}

#pragma mark - HXPDFReaderThumbQueue class methods

+ (HXPDFReaderThumbQueue *)sharedInstance
{
	static dispatch_once_t predicate = 0;

	static HXPDFReaderThumbQueue *object = nil; // Object

	dispatch_once(&predicate, ^{
        object = [self new];
    });

	return object; // ReaderThumbQueue singleton
}

#pragma mark - HXPDFReaderThumbQueue instance methods

- (instancetype)init
{
	if ((self = [super init])) // Initialize
	{
		loadQueue = [NSOperationQueue new];

		[loadQueue setName:@"HXPDFReaderThumbLoadQueue"];

		[loadQueue setMaxConcurrentOperationCount:1];

		workQueue = [NSOperationQueue new];

		[workQueue setName:@"HXPDFReaderThumbWorkQueue"];

		[workQueue setMaxConcurrentOperationCount:1];
	}

	return self;
}

- (void)addLoadOperation:(NSOperation *)operation
{
	if ([operation isKindOfClass:[HXPDFReaderThumbOperation class]])
	{
		[loadQueue addOperation:operation]; // Add to load queue
	}
}

- (void)addWorkOperation:(NSOperation *)operation
{
	if ([operation isKindOfClass:[HXPDFReaderThumbOperation class]])
	{
		[workQueue addOperation:operation]; // Add to work queue
	}
}

- (void)cancelOperationsWithGUID:(NSString *)guid
{
	[loadQueue setSuspended:YES];
    
    [workQueue setSuspended:YES];

	for (HXPDFReaderThumbOperation *operation in loadQueue.operations)
	{
		if ([operation isKindOfClass:[HXPDFReaderThumbOperation class]])
		{
			if ([operation.guid isEqualToString:guid]) [operation cancel];
		}
	}

	for (HXPDFReaderThumbOperation *operation in workQueue.operations)
	{
		if ([operation isKindOfClass:[HXPDFReaderThumbOperation class]])
		{
			if ([operation.guid isEqualToString:guid]) [operation cancel];
		}
	}

	[workQueue setSuspended:NO];
    [loadQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
	[loadQueue cancelAllOperations];
    [workQueue cancelAllOperations];
}

@end

#pragma mark -

//
//	ReaderThumbOperation class implementation
//

@implementation HXPDFReaderThumbOperation
{
	NSString *_guid;
}

@synthesize guid = _guid;

#pragma mark - HXPDFReaderThumbOperation instance methods

- (instancetype)initWithGUID:(NSString *)guid
{
	if ((self = [super init]))
	{
		_guid = guid;
	}

	return self;
}

@end
