//
//  HXPDFTopbarView.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/6.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFTopbarView.h"

@implementation HXPDFTopbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithWhite:0.94f alpha:0.94f];
        
        CGRect lineRect = self.bounds;
        lineRect.origin.y += lineRect.size.height;
        lineRect.size.height = 1.0f;
        
        UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
        lineView.autoresizesSubviews = NO;
        lineView.userInteractionEnabled = NO;
        lineView.contentMode = UIViewContentModeRedraw;
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lineView.backgroundColor = [UIColor colorWithWhite:0.64f alpha:0.94f];
        [self addSubview:lineView];
        
        UIFont *doneButtonFont = [UIFont systemFontOfSize:15];
        NSString *doneButtonText = NSLocalizedString(@"Done", @"button text");
        CGFloat doneButtonWidth = 50;
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(12, 8, doneButtonWidth, 30);
        [doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [doneButton setTitle:doneButtonText forState:UIControlStateNormal]; doneButton.titleLabel.font = doneButtonFont;
        [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [doneButton setBackgroundImage:nil forState:UIControlStateNormal];
        doneButton.autoresizingMask = UIViewAutoresizingNone;
        doneButton.exclusiveTouch = YES;
        
        [self addSubview:doneButton];
    }
    
    return self;
}


- (void)hideToolbar
{
    if (self.hidden == NO)
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
    }
}

- (void)showToolbar
{
    if (self.hidden == YES)
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
    }
}

#pragma mark - UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tappedInToolbar:doneButton:)]) {
        [self.delegate tappedInToolbar:self doneButton:button];
    }
}

@end
