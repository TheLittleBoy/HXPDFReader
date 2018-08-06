//
//  HXPDFReaderView.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/3.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPDFDocument.h"

@class HXPDFReaderView;

@protocol HXPDFReaderViewDelegate <NSObject>

@optional // Delegate protocols

- (void)didSelectPDFDocument:(HXPDFDocument *)document withPage:(int)page;

@end

@interface HXPDFReaderView : UIView

@property (nonatomic, weak) id <HXPDFReaderViewDelegate> delegate;

@property(nonatomic, strong) HXPDFDocument *document;

@end
