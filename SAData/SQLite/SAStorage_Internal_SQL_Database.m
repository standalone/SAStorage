//
//  SAStorage_Internal_SQL_Database.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Internal_SQL_Database.h"
#import "SAStorage_Internal_SQL_ResultSet.h"
#import <sqlite3.h>

NSString * const kSADataSQLiteErrorDomain = @"kSADataSQLiteErrorDomain";

static dispatch_queue_t s_queue;

@interface SAStorage_Internal_SQL_Database ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL databaseOpen;

@end

@implementation SAStorage_Internal_SQL_Database {
    
    sqlite3 *_handle;
    
}


#pragma mark Init

+ (SAStorage_Internal_SQL_Database *)databaseWithURL:(NSURL *)url {
    
    SAStorage_Internal_SQL_Database *db = [[SAStorage_Internal_SQL_Database alloc] initWithURL:url];
    return db;
    
}

- (SAStorage_Internal_SQL_Database *)initWithURL:(NSURL *)url {
    
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        if ([url isFileURL]) {
            self.fileURL = url;
            if (!s_queue) {
                s_queue = dispatch_queue_create("com.standalone.sastorage.sqlite", DISPATCH_QUEUE_SERIAL);
            }
        } else {
            NSLog(@"Does not yet support http URLs.");
            return nil;
        }
    }
    return self;
    
}

#pragma mark Database methods

- (BOOL)openWithError:(NSError **)error {
    
    if (self.databaseOpen) return YES;
    
    int err = sqlite3_open([[self.fileURL path] UTF8String], &_handle);
    
    if (err != SQLITE_OK) {
        *error = [[NSError alloc] initWithDomain:kSADataSQLiteErrorDomain code:err userInfo:nil];
        return NO;
    }
    
    self.databaseOpen = YES;
    return YES;
    
}

- (BOOL)closeWithError:(NSError **)error {
    
    if (!_handle) return NO;
    int err = sqlite3_close(_handle);
    
    if (err != SQLITE_OK) {
        *error = [[NSError alloc] initWithDomain:kSADataSQLiteErrorDomain code:err userInfo:nil];
        return NO;
    }
    
    self.databaseOpen = NO;
    _handle = NULL;
    return NO;
    
}

- (void)executeQueryWithSQL:(NSString *)sql parameters:(NSArray *)params completionBlock:(SAStorage_Internal_SQLCompletionBlock)block {
    
    SAStorage_Internal_SQLCompletionBlock completionBlock = [block copy];
    __weak SAStorage_Internal_SQL_Database *weakSelf = self;
    
    dispatch_async(s_queue, ^{
        [weakSelf.lock lock];
        
        if (!weakSelf.databaseOpen) {
            [weakSelf.lock unlock];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock([NSError errorWithDomain:kSADataSQLiteErrorDomain code:9999 userInfo:@{NSLocalizedDescriptionKey:@"Database not opened yet."}], nil);});
        }
        
        int err = 0;
        sqlite3_stmt *stmt = NULL;
        
        err = sqlite3_prepare(_handle, [sql UTF8String], -1, &stmt, NULL);
        
        if (err != SQLITE_OK) {
            [weakSelf.lock unlock];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock([NSError errorWithDomain:kSADataSQLiteErrorDomain code:err userInfo:nil], nil);});
        }
        
        if (![weakSelf bindStatement:stmt toParameters:params]) {
            sqlite3_finalize(stmt);
            [weakSelf.lock unlock];
            dispatch_async(dispatch_get_main_queue(), ^{completionBlock([NSError errorWithDomain:kSADataSQLiteErrorDomain code:8888 userInfo:@{NSLocalizedDescriptionKey:@"Array parameter count does not match SQL string parameter count."}], nil);});

        }
        
        SAStorage_Internal_SQL_ResultSet *resultSet = [SAStorage_Internal_SQL_ResultSet resultSetWithBoundStatement:stmt];
        
        sqlite3_finalize(stmt);
        
        dispatch_async(dispatch_get_main_queue(), ^{completionBlock(nil, resultSet);});
        
        [weakSelf.lock unlock];
    });
    
}

// shamelessly stolen from EGODatabase, will probably streamline later

- (BOOL)bindStatement:(sqlite3_stmt*)statement toParameters:(NSArray*)parameters {
	int index = 0;
	int queryCount = sqlite3_bind_parameter_count(statement);
    
	for(id obj in parameters) {
		index++;
		[self bindObject:obj toColumn:index inStatement:statement];
	}
    
	return index == queryCount;
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt {
	if ((!obj) || ((NSNull *)obj == [NSNull null])) {
		sqlite3_bind_null(pStmt, idx);
	} else if ([obj isKindOfClass:[NSData class]]) {
		sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
	} else if ([obj isKindOfClass:[NSDate class]]) {
		sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
	} else if ([obj isKindOfClass:[NSNumber class]]) {
		if (strcmp([obj objCType], @encode(BOOL)) == 0) {
			sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
		} else if (strcmp([obj objCType], @encode(int)) == 0) {
			sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		} else if (strcmp([obj objCType], @encode(long)) == 0) {
			sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		} else if (strcmp([obj objCType], @encode(float)) == 0) {
			sqlite3_bind_double(pStmt, idx, [obj floatValue]);
		} else if (strcmp([obj objCType], @encode(double)) == 0) {
			sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
		} else {
			sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
		}
	} else {
		sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
}


#pragma mark Properties

- (NSURL *)fileURL {
    return _fileURL;
}

@end
