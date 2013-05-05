//
//  SAStorage_FSDatabaseTests.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/5/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_FSDatabaseTests.h"

#define DATABASE_URL			[NSURL fileURLWithPath: [@"~/Documents/Database.fsdb" stringByExpandingTildeInPath]]

@implementation SAStorage_FSDatabaseTests

- (void) setUp {
    [super setUp];
	self.databaseType = SAStorage_Database_FS;
	[[NSFileManager defaultManager] removeItemAtURL: self.databaseURL error: nil];
}

- (NSURL *) databaseURL { return DATABASE_URL; }
- (NSString *) databaseExtension { return @"fsdb"; }

@end
