//
//  HXPDFReaderView.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/3.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFReaderView.h"
#import "HXPDFReaderViewCell.h"
#import "HXPDFReaderThumbRequest.h"
#import "HXPDFReaderThumbCache.h"

@interface HXPDFReaderView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;

@end

@implementation HXPDFReaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCollectionView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCollectionView];
    }
    return self;
}

- (void)initCollectionView {
    
    if (!self.collectionView) {
        
        self.collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionLayout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor grayColor];
        self.collectionView.alwaysBounceVertical = YES;
        [self.collectionView registerClass:[HXPDFReaderViewCell class] forCellWithReuseIdentifier:@"HXPDFReaderViewCell"];

        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.offset(0);
            make.right.offset(0);
            make.bottom.offset(0);
        }];
    }
}

- (void)setDocument:(HXPDFDocument *)document {
    _document = document;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *scale = [self.document.aspectRatio objectAtIndex:indexPath.row];
    
    CGFloat width = self.bounds.size.width-40;
    
    return CGSizeMake(width, width*scale.floatValue);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 20);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.document) {
        return self.document.pageCount.integerValue;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HXPDFReaderViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPDFReaderViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor greenColor];
    
    CGSize size = CGSizeMake(256, 256);
    
    NSInteger page = (indexPath.row + 1);
    
    HXPDFReaderThumbRequest *thumbRequest = [HXPDFReaderThumbRequest newForView:cell.imageView document:self.document page:page size:size];
    
    UIImage *image = [[HXPDFReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail
    
    if ([image isKindOfClass:[UIImage class]]) {
        cell.imageView.image = image;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPDFDocument:withPage:)]) {
        [self.delegate didSelectPDFDocument:self.document withPage:indexPath.row];
    }
}

@end
