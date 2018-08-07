//
//  HXPDFDetailContentView.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/7.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFReaderThumbView.h"
#import "HXPDFDocument.h"

@class HXPDFDetailContentView;

@protocol HXPDFDetailContentViewDelegate <NSObject>

@required // Delegate protocols

- (void)contentView:(HXPDFDetailContentView *)contentView touchesBegan:(NSSet *)touches;

@end

@interface HXPDFDetailContentView : UIScrollView

@property (nonatomic, weak, readwrite) id <HXPDFDetailContentViewDelegate> message;

- (instancetype)initWithFrame:(CGRect)frame document:(HXPDFDocument *)document page:(NSUInteger)page;

- (void)showPageThumbWithDocument:(HXPDFDocument *)document page:(NSInteger)page;

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer;

- (void)zoomIncrement:(UITapGestureRecognizer *)recognizer;
- (void)zoomDecrement:(UITapGestureRecognizer *)recognizer;
- (void)zoomResetAnimated:(BOOL)animated;

@end

#pragma mark -

//
//    ReaderContentThumb class interface
//

@interface HXPDFReaderContentThumb : HXPDFReaderThumbView

@end
