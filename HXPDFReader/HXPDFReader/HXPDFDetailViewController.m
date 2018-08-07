//
//  HXPDFDetailViewController.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/6.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFDetailViewController.h"
#import "HXPDFTopbarView.h"
#import "HXPDFBottombarView.h"
#import "HXPDFDetailContentView.h"
#import "HXPDFReaderThumbCache.h"
#import "HXPDFReaderThumbQueue.h"

@interface HXPDFDetailViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate,HXPDFTopbarViewDelegate, HXPDFBottombarViewDelegate, HXPDFDetailContentViewDelegate>
@end

@implementation HXPDFDetailViewController
{
    HXPDFDocument *document;
    
    UIScrollView *theScrollView;
    
    HXPDFTopbarView *mainToolbar;
    
    HXPDFBottombarView *mainPagebar;
    
    NSMutableDictionary *contentViews;
    
    UIUserInterfaceIdiom userInterfaceIdiom;
    
    NSInteger currentPage, minimumPage, maximumPage;
    
    CGFloat scrollViewOutset;
    
    CGSize lastAppearSize;
    
    NSDate *lastHideTime;
    
    BOOL ignoreDidScroll;
}

#pragma mark - Constants

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f


#pragma mark - HXPDFDetailViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
    CGFloat contentHeight = scrollView.bounds.size.height; // Height
    
    CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);
    
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    [self updateContentSize:scrollView]; // Update content size first
    
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(NSNumber *key, HXPDFDetailContentView *contentView, BOOL *stop)
     {
         NSInteger page = [key integerValue]; // Page number value
         
         CGRect viewRect = CGRectZero;
         viewRect.size = scrollView.bounds.size;
         viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
         contentView.frame = CGRectInset(viewRect, self->scrollViewOutset, 0.0f);
     }
     ];
    
    NSInteger page = currentPage; // Update scroll view offset to current page
    
    CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
    {
        scrollView.contentOffset = contentOffset; // Update content offset
    }
    
    [mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
    CGRect viewRect = CGRectZero;
    viewRect.size = scrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (page - 1));
    viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    
    HXPDFDetailContentView *contentView = [[HXPDFDetailContentView alloc] initWithFrame:viewRect document:document page:page];
    
    contentView.message = self;
    
    [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]];
    
    [scrollView addSubview:contentView];
    
    [contentView showPageThumbWithDocument:document page:page]; // Request page preview thumb
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // View width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages
    
    NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages
    
    if (pageA < minimumPage) pageA = minimumPage;
    
    if (pageB > maximumPage) pageB = maximumPage;
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
    
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
    {
        NSInteger page = [key integerValue]; // Page number value
        
        if ([pageSet containsIndex:page] == NO) // Remove content view
        {
            HXPDFDetailContentView *contentView = [contentViews objectForKey:key];
            
            [contentView removeFromSuperview];
            
            [contentViews removeObjectForKey:key];
        }
        else // Visible content view - so remove it from page set
        {
            [pageSet removeIndex:page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) // We have pages to add
    {
        NSEnumerationOptions options = 0; // Default
        
        if (pages == 2) // Handle case of only two content views
        {
            if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
        }
        else if (pages == 3) // Handle three content views - show the middle one first
        {
            NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;
            
            [workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];
            
            [self addContentView:scrollView page:page];
        }
        
        [pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
         ^(NSUInteger page, BOOL *stop)
         {
             [self addContentView:scrollView page:page];
         }
         ];
    }
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger page = (contentOffsetX / viewWidth); page++; // Page number
    
    if (page != currentPage) // Only if on different page
    {
        currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, HXPDFDetailContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

/**
 直接跳转到第几页
 
 @param page 页码
 */
- (void)showDocumentPage:(NSInteger)page
{
    if (page != currentPage) // Only if on different page
    {
        if ((page < minimumPage) || (page > maximumPage)) return;
        
        currentPage = page;
        
        document.pageNumber = [NSNumber numberWithInteger:page];
        
        CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
            [self layoutContentViews:theScrollView];
        else
            [theScrollView setContentOffset:contentOffset];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, HXPDFDetailContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)showDocument
{
    [self updateContentSize:theScrollView]; // Update content size first
    
    [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
}

- (void)closeDocument
{
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    [[HXPDFReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];
    
    [[HXPDFReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(HXPDFDocument *)object
{
    if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
    {
        if ((object != nil) && ([object isKindOfClass:[HXPDFDocument class]])) // Valid object
        {
            userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
            
            scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);
            
            document = object; // Retain the supplied ReaderDocument object for our use
            
            [HXPDFReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
        }
        else // Invalid ReaderDocument object
        {
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    mainToolbar = nil;
    mainPagebar = nil;
    theScrollView = nil;
    contentViews = nil;
    lastHideTime = nil;
    
    lastAppearSize = CGSizeZero;
    currentPage = 0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    assert(document != nil); // Must have a valid ReaderDocument
    
    self.view.backgroundColor = [UIColor grayColor]; // Neutral gray
    
    CGRect viewRect = self.view.bounds; // View bounds
    
    CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
    theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // All
    theScrollView.autoresizesSubviews = NO;
    theScrollView.contentMode = UIViewContentModeRedraw;
    theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
    theScrollView.scrollsToTop = NO;
    theScrollView.delaysContentTouches = NO;
    theScrollView.pagingEnabled = YES;
    theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    theScrollView.backgroundColor = [UIColor clearColor];
    theScrollView.delegate = self;
    [self.view addSubview:theScrollView];
    
    CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
    mainToolbar = [[HXPDFTopbarView alloc] initWithFrame:toolbarRect]; // ReaderMainToolbar
    mainToolbar.delegate = self; // ReaderMainToolbarDelegate
    [self.view addSubview:mainToolbar];
    
    CGRect pagebarRect = self.view.bounds;
    pagebarRect.size.height = PAGEBAR_HEIGHT;
    pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
    mainPagebar = [[HXPDFBottombarView alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
    mainPagebar.delegate = self; // ReaderMainPagebarDelegate
    [self.view addSubview:mainPagebar];
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
    [self.view addGestureRecognizer:singleTapOne];
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
    [self.view addGestureRecognizer:doubleTapOne];
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
    [self.view addGestureRecognizer:doubleTapTwo];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    contentViews = [NSMutableDictionary new];
    
    lastHideTime = [NSDate date];
    
    minimumPage = 1;
    
    maximumPage = [document.pageCount integerValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
    {
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
        {
            [self updateContentViews:theScrollView]; // Update content views
        }
        
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
    {
        [self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    lastAppearSize = self.view.bounds.size; // Track view size
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
    {
        [self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ignoreDidScroll = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
    return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != minimumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x -= theScrollView.bounds.size.width; // View X--
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)incrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != maximumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x += theScrollView.bounds.size.width; // View X++
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect
        
        if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            HXPDFDetailContentView *targetView = [contentViews objectForKey:key]; // View
            
            id target = [targetView processSingleTap:recognizer]; // Target object
            
            if (target != nil) // Handle the returned target object
            {
                if ([target isKindOfClass:[NSURL class]]) // Open a URL
                {
                    NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
                    if (url.scheme == nil) // Handle a missing URL scheme
                    {
                        NSString *www = url.absoluteString; // Get URL string
                        
                        if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
                        {
                            NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];
                            
                            url = [NSURL URLWithString:http]; // Proper http-based URL
                        }
                    }
                    
                    if ([[UIApplication sharedApplication] openURL:url] == NO)
                    {
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
                    }
                }
                else // Not a URL, so check for another possible object type
                {
                    if ([target isKindOfClass:[NSNumber class]]) // Goto page
                    {
                        NSInteger number = [target integerValue]; // Number
                        
                        [self showDocumentPage:number]; // Show the page
                    }
                }
            }
            else // Nothing active tapped in the target content view
            {
                if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
                {
                    if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
                    {
                        [mainToolbar showToolbar];
                        
                        [mainPagebar showPagebar]; // Show
                    }
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
        
        if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            HXPDFDetailContentView *targetView = [contentViews objectForKey:key]; // View
            
            switch (recognizer.numberOfTouchesRequired) // Touches count
            {
                case 1: // One finger double tap: zoom++
                {
                    [targetView zoomIncrement:recognizer]; break;
                }
                    
                case 2: // Two finger double tap: zoom--
                {
                    [targetView zoomDecrement:recognizer]; break;
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

#pragma mark - HXPDFDetailContentViewDelegate methods

- (void)contentView:(HXPDFDetailContentView *)contentView touchesBegan:(NSSet *)touches
{
    if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
    {
        if (touches.count == 1) // Single touches only
        {
            UITouch *touch = [touches anyObject]; // Touch info
            
            CGPoint point = [touch locationInView:self.view]; // Touch location
            
            CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
            if (CGRectContainsPoint(areaRect, point) == false) return;
        }
        
        [mainToolbar hideToolbar];
        
        [mainPagebar hidePagebar]; // Hide
        
        lastHideTime = [NSDate date]; // Set last hide time
    }
}

#pragma mark - HXPDFTopbarViewDelegate methods

- (void)tappedInToolbar:(HXPDFTopbarView *)toolbar doneButton:(UIButton *)button
{
    [self closeDocument];
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(HXPDFBottombarView *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
}

@end
