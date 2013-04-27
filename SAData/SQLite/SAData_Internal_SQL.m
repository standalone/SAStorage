//
//  SAData_Internal_SQL.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_Internal_SQL.h"
#import <sqlite3.h>

NSString * const kSADataSQLiteErrorDomain = @"kSADataSQLiteErrorDomain";

@interface SAData_Internal_SQL ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL databaseOpen;

@end

@implementation SAData_Internal_SQL {
    
    sqlite3 *_handle;
    
}


#pragma mark Init

+ (SAData_Internal_SQL *)databaseWithURL:(NSURL *)url {
    
    SAData_Internal_SQL *db = [[SAData_Internal_SQL alloc] initWithURL:url];
    return db;
    
}

- (SAData_Internal_SQL *)initWithURL:(NSURL *)url {
    
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        if ([url isFileURL]) {
            self.fileURL = url;
        } else {
            NSLog(@"Does not yet support http URLs.");
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
