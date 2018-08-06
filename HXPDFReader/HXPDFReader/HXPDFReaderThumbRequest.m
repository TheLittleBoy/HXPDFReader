//
//  HXPDFReaderThumbRequest.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFReaderThumbRequest.h"
#import "HXPDFReaderThumbView.h"

@implementation HXPDFReaderThumbRequest
{
    HXPDFDocument *_document;
    
	NSString *_cacheKey;

	NSString *_thumbName;

	UIImageView *_thumbView;

	NSUInteger _targetTag;

	NSInteger _thumbPage;

	CGSize _thumbSize;

	CGFloat _scale;
}

#pragma mark - Properties

@synthesize document = _document;
@synthesize thumbView = _thumbView;
@synthesize thumbPage = _thumbPage;
@synthesize thumbSize = _thumbSize;
@synthesize thumbName = _thumbName;
@synthesize targetTag = _targetTag;
@synthesize cacheKey = _cacheKey;
@synthesize scale = _scale;

#pragma mark - HXPDFReaderThumbRequest class methods

+ (instancetype)newForView:(UIImageView *)view document:(HXPDFDocument*)document page:(NSInteger)page size:(CGSize)size
{
	return [[HXPDFReaderThumbRequest alloc] initForView:view document:document page:page size:size];
}

#pragma mark - HXPDFReaderThumbRequest instance methods

- (instancetype)initForView:(UIImageView *)view document:(HXPDFDocument*)document page:(NSInteger)page size:(CGSize)size
{
	if ((self = [super init])) // Initialize object
	{
		NSInteger w = size.width;
        
        NSInteger h = size.height;

        _document = document;
        
		_thumbView = view;
        
        _thumbPage = page;
        
        _thumbSize = size;

		_thumbName = [[NSString alloc] initWithFormat:@"%07i-%04ix%04i", (int)page, (int)w, (int)h];

		_cacheKey = [[NSString alloc] initWithFormat:@"%@+%@", _thumbName, _document.guid];

		_targetTag = [_cacheKey hash];
        
        _thumbView.tag = _targetTag;

		_scale = [[UIScreen mainScreen] scale]; // Thumb screen scale
	}

	return self;
}

@end
