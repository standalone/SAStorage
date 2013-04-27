//
//  SAData_Internal_SQL.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSADataSQLiteErrorDomain;

@interface SAData_Internal_SQL : NSObject

+ (SAData_Internal_SQL *)databaseWithURL:(NSURL *)url;
- (SAData_Internal_SQL *)initWithURL:(NSURL *)url;

- (BOOL)openWithError:(NSError **)error;
- (BOOL)closeWithError:(NSError **)error;

@property (nonatomic, readonly) NSURL *fileURL;

@end
