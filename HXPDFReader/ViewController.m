//
//  ViewController.m
//  HXPDFReader
//
//  Created by Mac on 2018/7/21.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "ViewController.h"
#import "ReaderViewController.h"

@interface ViewController () <ReaderViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor]; // Transparent
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.title = [[NSString alloc] initWithFormat:@"%@ v%@", name, version];
    
    CGSize viewSize = self.view.bounds.size;
    CGRect labelRect = CGRectMake(0.0f, 0.0f, 300.0f, 32.0f);
    UILabel *tapLabel = [[UILabel alloc] initWithFrame:labelRect];
    tapLabel.userInteractionEnabled = YES;
    tapLabel.text = NSLocalizedString(@"Tap--PDFReader", @"text");
    tapLabel.textAlignment = NSTextAlignmentCenter;
    tapLabel.backgroundColor = [UIColor clearColor];
    tapLabel.font = [UIFont systemFontOfSize:24.0f];
    tapLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    tapLabel.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tapLabel.center = CGPointMake(viewSize.width * 0.5f, viewSize.height * 0.5f-40);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [tapLabel addGestureRecognizer:singleTap];
    
    [self.view addSubview:tapLabel];
    
    
    UILabel *tapLabel2 = [[UILabel alloc] initWithFrame:labelRect];
    tapLabel2.userInteractionEnabled = YES;
    tapLabel2.text = NSLocalizedString(@"Tap--HXPDFReader", @"text");
    tapLabel2.textAlignment = NSTextAlignmentCenter;
    tapLabel2.backgroundColor = [UIColor clearColor];
    tapLabel2.font = [UIFont systemFontOfSize:24.0f];
    tapLabel2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    tapLabel2.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tapLabel2.center = CGPointMake(viewSize.width * 0.5f, viewSize.height * 0.5f+40);
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap2:)];
    [tapLabel2 addGestureRecognizer:singleTap2];
    
    [self.view addSubview:tapLabel2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - UIGestureRecognizer methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"pdf"];
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        [self.navigationController pushViewController:readerViewController animated:YES];

    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

- (void)handleSingleTap2:(UITapGestureRecognizer *)recognizer
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSString *filePath = filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"pdf"];
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        [self.navigationController pushViewController:readerViewController animated:YES];
        
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

#pragma mark - ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
