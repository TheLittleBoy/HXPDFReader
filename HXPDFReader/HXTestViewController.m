//
//  HXTestViewController.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXTestViewController.h"
#import "HXPDFDocument.h"
#import "HXPDFReaderThumbsView.h"
#import "ThumbsViewController.h"
#import "HXPDFReaderThumbRequest.h"
#import "HXPDFReaderThumbCache.h"

@interface HXTestViewController ()<HXPDFReaderThumbsViewDelegate>
{
    HXPDFReaderThumbsView *theThumbsView;
    HXPDFDocument *document;
}
@end

@implementation HXTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = filePath = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"pdf"];
    
    document = [HXPDFDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        UIEdgeInsets scrollViewInsets = UIEdgeInsetsZero; // Scroll view toolbar insets
        
        theThumbsView = [[HXPDFReaderThumbsView alloc] initWithFrame:CGRectMake(0, 0, 300, self.view.bounds.size.height)]; // ReaderThumbsView
        theThumbsView.contentInset = scrollViewInsets;
        theThumbsView.scrollIndicatorInsets = scrollViewInsets;
        theThumbsView.delegate = self; // HXPDFReaderThumbsViewDelegate
        [self.view addSubview:theThumbsView];
        
        [theThumbsView setThumbSize:CGSizeMake(256, 256)];
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [theThumbsView reloadThumbsCenterOnIndex:([document.pageNumber integerValue] - 1)]; // Page
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - HXPDFReaderThumbsViewDelegate methods

- (NSUInteger)numberOfThumbsInThumbsView:(HXPDFReaderThumbsView *)thumbsView
{
    return [document.pageCount integerValue];
}

- (id)thumbsView:(HXPDFReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
    return [[HXPDFReaderThumbView alloc] initWithFrame:frame];
}

- (void)thumbsView:(HXPDFReaderThumbsView *)thumbsView updateThumbCell:(HXPDFReaderThumbView *)thumbCell forIndex:(NSInteger)index
{
    CGSize size = CGSizeMake(256, 256);
    
    NSInteger page = (index + 1);
    
    NSURL *fileURL = document.fileURL;
    
    NSString *guid = document.guid;
    
    NSString *phrase = document.password; // Document info
    
    HXPDFReaderThumbRequest *thumbRequest = [HXPDFReaderThumbRequest newForView:thumbCell fileURL:fileURL password:phrase guid:guid page:page size:size];
    
    UIImage *image = [[HXPDFReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail
    
    if ([image isKindOfClass:[UIImage class]]) {
        [thumbCell showImage:image]; // Show image from cache
    }
}

- (void)thumbsView:(HXPDFReaderThumbsView *)thumbsView refreshThumbCell:(id)thumbCell forIndex:(NSInteger)index
{

}

- (void)thumbsView:(HXPDFReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
    NSInteger page = (index + 1);
    
    NSLog(@"%ld",(long)page);
    
    //[delegate thumbsViewController:self gotoPage:page]; // Show the selected page
    
    //[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

- (void)thumbsView:(HXPDFReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
