//
//  HXPDFDetailContentPage.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/7.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFDocument.h"

@interface HXPDFDetailContentPage : UIView

- (instancetype)initWithDocument:(HXPDFDocument *)document page:(NSInteger)page;

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer;

@end

#pragma mark -

//
//    HXPDFDocumentLink class interface
//

@interface HXPDFDocumentLink : NSObject <NSObject>

@property (nonatomic, assign, readonly) CGRect rect;

@property (nonatomic, assign, readonly) CGPDFDictionaryRef dictionary;

+ (instancetype)newWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

@end
