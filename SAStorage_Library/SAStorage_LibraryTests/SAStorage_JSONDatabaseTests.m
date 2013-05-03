//
//  SAStorage_JSONDatabase.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_JSONDatabaseTests.h"
#import "SAStorage_JSONDatabase.h"
#import "SAStorage.h"

#define DATABASE_URL			[NSURL fileURLWithPath: [@"~/Documents/Database.json" stringByExpandingTildeInPath]]

@interface SAStorage_JSONDatabaseTests ()
@end

@implementation SAStorage_JSONDatabaseTests

- (void) setUp {
    [super setUp];
    [self clearOutTestDatabase];
}

- (SAStorage_Schema *) testSchema {
	return [SAStorage_Schema schemaWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"]];
}

- (void) testDatabaseCreation {
	SAStorage_JSONDatabase		*db = [[SAStorage_JSONDatabase alloc] initWithURL: DATABASE_URL andSchema: self.testSchema];
	
	[db saveWithCompletion: ^(NSError *error) {
		STAssertNil(error, @"There was an error saving the database: %@", error);
		[self clearOutTestDatabase];
	}];
}

- (void) testRecordCreation {
	SAStorage_JSONDatabase		*db = [[SAStorage_JSONDatabase alloc] initWithURL: DATABASE_URL andSchema: self.testSchema];

	[db insertNewRecordOfType: @"Contact" completion:^(SAStorage_Record *record, NSError *error) {
		STAssertNotNil(record, @"Failed to create record in database: %@");

		record[@"first_name"] = @"Isaac";
		record[@"last_name"] = @"Newton";
		record.recordHasChanges = YES;
		
		[db saveWithCompletion: ^(NSError *error) {
			STAssertNil(error, @"There was an error saving the database: %@", error);
				
			[self clearOutTestDatabase];
		}];
	}];
}

- (void) testRecordFetching {
	SAStorage_JSONDatabase		*db = [[SAStorage_JSONDatabase alloc] initWithURL: DATABASE_URL andSchema: self.testSchema];
	
	[db insertNewRecordOfType: @"Contact" completion:^(SAStorage_Record *record, NSError *error) {
		STAssertNotNil(record, @"Failed to create record in database: %@");
		
		
		
		
	}];
}

- (void) clearOutTestDatabase {
	[[NSFileManager defaultManager] removeItemAtURL: DATABASE_URL error: nil];
}
@end
