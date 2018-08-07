//
//  HXPDFTopbarView.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/6.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXPDFTopbarView;

@protocol HXPDFTopbarViewDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(HXPDFTopbarView *)toolbar doneButton:(UIButton *)button;

@end


@interface HXPDFTopbarView : UIView

@property (nonatomic, weak, readwrite) id <HXPDFTopbarViewDelegate> delegate;

- (void)hideToolbar;
- (void)showToolbar;

@end
