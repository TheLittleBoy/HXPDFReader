//
//  HXPDFDocument.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFDocument.h"
#import <QuartzCore/QuartzCore.h>

@interface HXPDFDocument ()
{
    CGPDFDocumentRef currentDocRef;
}
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong, readwrite) NSString *filePath;

@end

@implementation HXPDFDocument
{
    NSString *_guid;
    
    NSNumber *_fileSize;
    
    NSNumber *_pageCount;
    
    NSNumber *_pageNumber;
    
    NSString *_password;
    
    NSString *_fileName;
    
    NSString *_filePath;
    
    NSURL *_fileURL;
    
    NSMutableArray *_aspectRatio;
}

#pragma mark - Properties

@synthesize guid = _guid;
@synthesize fileSize = _fileSize;
@synthesize pageCount = _pageCount;
@synthesize pageNumber = _pageNumber;
@synthesize password = _password;
@synthesize filePath = _filePath;
@synthesize aspectRatio = _aspectRatio;
@dynamic fileName, fileURL;

#pragma mark - HXPDFDocument class methods

+ (NSString *)GUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    
    CFStringRef theString = CFUUIDCreateString(NULL, theUUID);
    
    NSString *unique = [NSString stringWithString:(__bridge id)theString];
    
    CFRelease(theString);
    CFRelease(theUUID); // Cleanup CF objects
    
    return unique;
}

+ (NSString *)archiveFilePath:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton
    
    NSString *cacheDir = NSTemporaryDirectory();
    
    NSString *archivePath = [cacheDir stringByAppendingPathComponent:@"PDF Metadata"];
    
    [fileManager createDirectoryAtPath:archivePath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    NSString *archiveName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    
    return [archivePath stringByAppendingPathComponent:archiveName]; // "{archivePath}/'fileName'.plist"
}

+ (HXPDFDocument *)unarchiveFromFileName:(NSString *)filePath password:(NSString *)phrase
{
    HXPDFDocument *document = nil; // HXPDFDocument object
    
    NSString *fileName = [filePath lastPathComponent]; // File name only
    
    NSString *archiveFilePath = [HXPDFDocument archiveFilePath:fileName];
    
    @try // Unarchive an archived HXPDFDocument object from its property list
    {
        document = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        
        if (document != nil) // Set the document's file path and password properties
        {
            document.filePath = [filePath copy];
            
            document.password = [phrase copy];
        }
    }
    @catch (NSException *exception) // Exception handling (just in case O_o)
    {
#ifdef DEBUG
        NSLog(@"%s Caught %@: %@", __FUNCTION__, [exception name], [exception reason]);
#endif
    }
    
    return document;
}

+ (HXPDFDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase
{
    HXPDFDocument *document = nil; // HXPDFDocument object
    
    document = [HXPDFDocument unarchiveFromFileName:filePath password:phrase];
    
    if (document == nil) // Unarchive failed so create a new HXPDFDocument object
    {
        document = [[HXPDFDocument alloc] initWithFilePath:filePath password:phrase];
    }
    
    return document;
}

+ (BOOL)isPDF:(NSString *)filePath
{
    if (filePath != nil) // Must have a file path
    {
        NSString *extension = [filePath pathExtension];
        return [[extension lowercaseString] isEqualToString:@"pdf"];
    }
    return NO;
}

#pragma mark - HXPDFDocument instance methods

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)phrase
{
    if ((self = [super init])) // Initialize superclass first
    {
        if ([HXPDFDocument isPDF:filePath] == YES) // Valid PDF
        {
            _guid = [HXPDFDocument GUID]; // Create document's GUID
            
            _password = [phrase copy]; // Keep copy of document password
            
            _filePath = [filePath copy]; // Keep copy of document file path
            
            _pageNumber = [NSNumber numberWithInteger:1]; // Start on page one
            
            CGPDFDocumentRef thePDFDocRef = [self thePDFDocRef];
            
            if (thePDFDocRef != NULL) // Get the total number of pages in the document
            {
                NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);
                
                _pageCount = [NSNumber numberWithInteger:pageCount];
                
                _aspectRatio = [NSMutableArray arrayWithCapacity:pageCount];
                
                for (int page = 1; page<=pageCount; page++) {
                    
                    CGPDFPageRef thePDFPageRef = CGPDFDocumentGetPage(thePDFDocRef, page);

                    CGRect cropBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFCropBox);
                    CGRect mediaBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFMediaBox);
                    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
                    
                    NSInteger pageRotate = CGPDFPageGetRotationAngle(thePDFPageRef); // Angle
                    
                    CGFloat page_w = 0.0f;
                    CGFloat page_h = 0.0f; // Rotated page size
                    
                    switch (pageRotate) // Page rotation (in degrees)
                    {
                        default: // Default case
                        case 0: case 180: // 0 and 180 degrees
                        {
                            page_w = effectiveRect.size.width;
                            page_h = effectiveRect.size.height;
                            break;
                        }
                            
                        case 90: case 270: // 90 and 270 degrees
                        {
                            page_h = effectiveRect.size.width;
                            page_w = effectiveRect.size.height;
                            break;
                        }
                    }
                    
                    CGFloat scale = page_h/page_w; // Width scale
                    
                    [_aspectRatio addObject:[NSNumber numberWithFloat:scale]];
                    
                }
                
                //CGPDFDocumentRelease(thePDFDocRef); // Cleanup
            }
            else // Cupertino, we have a problem with the document
            {
                NSLog(@"读取PDF文件失败！");
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton
            
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_filePath error:NULL];
            
            _fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)
            
            [self archiveDocumentProperties]; // Archive HXPDFDocument object
        }
        else // Not a valid PDF file
        {
            self = nil;
        }
    }
    
    return self;
}

- (NSString *)fileName
{
    if (_fileName == nil) {
        _fileName = [_filePath lastPathComponent];
    }
    
    return _fileName;
}

- (NSURL *)fileURL
{
    if (_fileURL == nil) {
        _fileURL = [[NSURL alloc] initFileURLWithPath:_filePath isDirectory:NO];
    }
    
    return _fileURL;
}

- (BOOL)archiveDocumentProperties
{
    NSString *archiveFilePath = [HXPDFDocument archiveFilePath:[self fileName]];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:archiveFilePath];
}

#pragma mark - NSCoding protocol methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_guid forKey:@"FileGUID"];
    
    [encoder encodeObject:_pageCount forKey:@"PageCount"];
    
    [encoder encodeObject:_pageNumber forKey:@"PageNumber"];
    
    [encoder encodeObject:_fileSize forKey:@"FileSize"];
    
    [encoder encodeObject:_aspectRatio forKey:@"AspectRatio"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) // Superclass init
    {
        _guid = [decoder decodeObjectForKey:@"FileGUID"];
        
        _pageCount = [decoder decodeObjectForKey:@"PageCount"];
        
        _pageNumber = [decoder decodeObjectForKey:@"PageNumber"];
        
        _fileSize = [decoder decodeObjectForKey:@"FileSize"];
        
        _aspectRatio = [decoder decodeObjectForKey:@"AspectRatio"];
        
        if (_guid == nil) {
            _guid = [HXPDFDocument GUID];
        }
    }
    return self;
}

- (CGPDFDocumentRef)thePDFDocRef {
    
    if (currentDocRef == NULL) {
        
        CFURLRef docURLRef = (__bridge CFURLRef)[self fileURL]; // CFURLRef from NSURL
        
        currentDocRef = [self CGPDFDocumentCreateUsingUrl:docURLRef password:_password];
    }
    
    return currentDocRef;
}

- (void)dealloc
{
    if (currentDocRef != NULL) {
        CGPDFDocumentRelease(currentDocRef); // Cleanup
    }
}


/**
 读取PDF资源

 @param theURL 路径
 @param password 文件密码
 @return CGPDFDocumentRef
 */
- (CGPDFDocumentRef)CGPDFDocumentCreateUsingUrl:(CFURLRef)theURL password:(NSString *)password {
    
    CGPDFDocumentRef thePDFDocRef = NULL; // CGPDFDocument
    
    if (theURL != NULL) // Check for non-NULL CFURLRef
    {
        thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);
        
        if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
        {
            if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) // Encrypted
            {
                // Try a blank password first, per Apple's Quartz PDF example
                
                if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE)
                {
                    // Nope, now let's try the provided password to unlock the PDF
                    
                    if ((password != nil) && (password.length > 0)) // Not blank?
                    {
                        char text[128]; // char array buffer for the string conversion
                        
                        [password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];
                        
                        if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE) // Log failure
                        {
#ifdef DEBUG
                            NSLog(@"CGPDFDocumentCreateUsingUrl: Unable to unlock [%@] with [%@]", theURL, password);
#endif
                        }
                    }
                }
                
                if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) // Cleanup unlock failure
                {
                    CGPDFDocumentRelease(thePDFDocRef);
                    thePDFDocRef = NULL;
                }
            }
        }
    }
    else // Log an error diagnostic
    {
#ifdef DEBUG
        NSLog(@"CGPDFDocumentCreateUsingUrl: theURL == NULL");
#endif
    }
    
    return thePDFDocRef;
}

@end

