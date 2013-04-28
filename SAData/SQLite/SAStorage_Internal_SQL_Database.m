//
//  SAStorage_Internal_SQL_Database.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Internal_SQL_Database.h"
#import <sqlite3.h>

NSString * const kSADataSQLiteErrorDomain = @"kSADataSQLiteErrorDomain";

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

#pragma mark Properties

- (NSURL *)fileURL {
    return _fileURL;
}

@end
