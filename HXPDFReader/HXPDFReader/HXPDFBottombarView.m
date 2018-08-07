//
//  HXPDFBottombarView.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/6.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFBottombarView.h"

@implementation HXPDFBottombarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor colorWithWhite:0.94f alpha:0.94f];
        
        CGRect lineRect = self.bounds;
        lineRect.size.height = 1.0f;
        lineRect.origin.y -= lineRect.size.height;
        
        UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
        lineView.autoresizesSubviews = NO;
        lineView.userInteractionEnabled = NO;
        lineView.contentMode = UIViewContentModeRedraw;
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lineView.backgroundColor = [UIColor colorWithWhite:0.64f alpha:0.94f];
        [self addSubview:lineView];
    }
    
    return self;
}

@end
