//
//  SAData_SQLT_Database.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_SQLT_Database.h"
#import <sqlite3.h>

NSString * const kSADataSQLiteErrorDomain = @"kSADataSQLiteErrorDomain";

@interface SAData_SQLT_Database ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL databaseOpen;

@end

@implementation SAData_SQLT_Database {
    
    sqlite3 *handle;
    
}


#pragma mark Init

+ (SAData_SQLT_Database *)databaseWithURL:(NSURL *)url {
    
    SAData_SQLT_Database *db = [[SAData_SQLT_Database alloc] initWithURL:url];
    return db;
    
}

- (SAData_SQLT_Database *)initWithURL:(NSURL *)url {
    
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
    
    int err = sqlite3_open([[self.fileURL path] UTF8String], &handle);
    
    if (err != SQLITE_OK) {
        *error = [[NSError alloc] initWithDomain:kSADataSQLiteErrorDomain code:err userInfo:nil];
        return NO;
    }
    
    self.databaseOpen = YES;
    return YES;
    
}

#pragma mark Properties

- (NSURL *)fileURL {
    return _fileURL;
}

@end
