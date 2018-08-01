//
//  HXPDFReaderThumbView.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXPDFReaderThumbView : UIView
{
@protected // Instance variables

	UIImageView *imageView;
}

@property (atomic, strong, readwrite) NSOperation *operation;

@property (nonatomic, assign, readwrite) NSUInteger targetTag;

- (void)showImage:(UIImage *)image;

- (void)showTouched:(BOOL)touched;

- (void)reuse;

@end
