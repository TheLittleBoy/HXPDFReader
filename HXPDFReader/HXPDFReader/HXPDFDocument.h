//
//  HXPDFDocument.h
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXPDFDocument : NSObject <NSObject, NSCoding>

@property (nonatomic, strong, readonly) NSString *guid;
@property (nonatomic, strong, readonly) NSNumber *fileSize;
@property (nonatomic, strong, readonly) NSNumber *pageCount;
@property (nonatomic, strong, readwrite) NSNumber *pageNumber;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSURL *fileURL;

+ (HXPDFDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase;

+ (HXPDFDocument *)unarchiveFromFileName:(NSString *)filePath password:(NSString *)phrase;

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)phrase;

- (BOOL)archiveDocumentProperties;

@end
