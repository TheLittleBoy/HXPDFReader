//
//  HXTestViewController.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXTestViewController.h"
#import "HXPDFReaderView.h"
#import "HXPDFDetailViewController.h"

@interface HXTestViewController ()<HXPDFReaderViewDelegate>
{
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
        HXPDFReaderView *readerView = [[HXPDFReaderView alloc] initWithFrame:CGRectMake(50, 0, 300, self.view.bounds.size.height)];
        readerView.document = document;
        readerView.delegate = self;
        [self.view addSubview:readerView];
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HXPDFReaderViewDelegate

- (void)didSelectPDFDocument:(HXPDFDocument *)document withPage:(int)page {
    
    HXPDFDetailViewController *detailVC = [[HXPDFDetailViewController alloc] initWithReaderDocument:document];
    
    [self presentViewController:detailVC animated:NO completion:^{
        
    }];
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
