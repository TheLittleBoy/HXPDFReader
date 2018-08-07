//
//  HXPDFReaderViewCell.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/3.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFReaderViewCell.h"

@interface HXPDFReaderViewCell ()
{
    UIView *tintView;
}

@end

@implementation HXPDFReaderViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backView = [[UIView alloc] init];
        backView.autoresizesSubviews = NO;
        backView.userInteractionEnabled = NO;
        backView.contentMode = UIViewContentModeRedraw;
        backView.autoresizingMask = UIViewAutoresizingNone;
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        backView.layer.shadowRadius = 3.0f;
        backView.layer.shadowOpacity = 1.0f;
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        self.thumbView = [[HXPDFReaderThumbView alloc] init];
        [self.contentView addSubview:self.thumbView];
        [self.thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        tintView = [[UIView alloc] init];
        tintView.hidden = YES;
        tintView.autoresizesSubviews = NO;
        tintView.userInteractionEnabled = NO;
        tintView.contentMode = UIViewContentModeRedraw;
        tintView.autoresizingMask = UIViewAutoresizingNone;
        tintView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        [self.thumbView addSubview:tintView];
        
        [tintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.thumbView reuse];
}


#pragma mark - UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event]; // Message superclass
    
    tintView.hidden = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event]; // Message superclass
    
    tintView.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event]; // Message superclass
    
    tintView.hidden = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event]; // Message superclass
}

@end
