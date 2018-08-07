//
//  HXPDFBottombarView.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/6.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFReaderThumbView.h"
#import "HXPDFDocument.h"

@class HXPDFBottombarView;
@class HXPDFReaderTrackControl;
@class HXPDFReaderPagebarThumb;

@protocol HXPDFBottombarViewDelegate <NSObject>

@required // Delegate protocols

- (void)pagebar:(HXPDFBottombarView *)pagebar gotoPage:(NSInteger)page;

@end

@interface HXPDFBottombarView : UIView

@property (nonatomic, weak, readwrite) id <HXPDFBottombarViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame document:(HXPDFDocument *)object;

- (void)updatePagebar;

- (void)hidePagebar;
- (void)showPagebar;

@end

#pragma mark -

//
//    HXPDFReaderTrackControl class interface
//

@interface HXPDFReaderTrackControl : UIControl

@property (nonatomic, assign, readonly) CGFloat value;

@end

#pragma mark -

//
//    HXPDFReaderPagebarThumb class interface
//

@interface HXPDFReaderPagebarThumb : HXPDFReaderThumbView

- (instancetype)initWithFrame:(CGRect)frame small:(BOOL)small;

@end
