//
//  SAStorage_Internal_SQL_Database.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSADataSQLiteErrorDomain;
extern NSString * const kSADataSQLiteMetadataTableName;

@class SAStorage_Internal_SQL_ResultSet;

typedef void(^SAStorage_Internal_SQLCompletionBlock)(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet);

@interface SAStorage_Internal_SQL_Database : NSObject

+ (SAStorage_Internal_SQL_Database *)databaseWithURL:(NSURL *)url;
- (SAStorage_Internal_SQL_Database *)initWithURL:(NSURL *)url;

- (BOOL)openWithError:(NSError **)error;
- (BOOL)closeWithError:(NSError **)error;

- (void)executeQueryWithSQL:(NSString *)sql parameters:(NSArray *)params completionBlock:(SAStorage_Internal_SQLCompletionBlock)block;

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) BOOL databaseOpen;

@end
