//
//  SAData_SQLT_Database.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSADataSQLiteErrorDomain;

@interface SAData_SQLT_Database : NSObject

+ (SAData_SQLT_Database *)databaseWithURL:(NSURL *)url;
- (SAData_SQLT_Database *)initWithURL:(NSURL *)url;

- (BOOL)openWithError:(NSError **)error;

@property (nonatomic, readonly) NSURL *fileURL;

@end
