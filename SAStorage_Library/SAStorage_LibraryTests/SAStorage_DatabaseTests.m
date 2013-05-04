//
//  SAStorage_JSONDatabase.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_DatabaseTests.h"
#import "SAStorage_Database.h"
#import "SAStorage.h"

#define DATABASE_URL			[NSURL fileURLWithPath: [@"~/Documents/Database.json" stringByExpandingTildeInPath]]

@interface SAStorage_ErrorManagerTesting : SenTestCase
@end

@interface SAStorage_DatabaseTests ()
@end

@implementation SAStorage_DatabaseTests

- (void) setUp {
    [super setUp];
	[[NSFileManager defaultManager] removeItemAtURL: DATABASE_URL error: nil];
}

- (SAStorage_Schema *) testSchema {
	return [SAStorage_Schema schemaWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"]];
}

- (SAStorage_Database *) db {
	SAStorage_Database		*db = [SAStorage_Database databaseWithURL: DATABASE_URL ofType: SAStorage_Database_JSON basedOn: self.testSchema];
	
	db.validateSchemaFields = YES;
	db.errors = (id) [[SAStorage_ErrorManagerTesting alloc] init];
	return db;
}

- (void) testDatabaseCreation {
	SAStorage_Database		*db = self.db;
	NSError					*error = [db saveWithCompletion: nil];
	
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordCreation {
	SAStorage_Database		*db = self.db;

	SAStorage_Record		* record = [db insertNewRecordOfType: @"Contacts" completion: nil];
	STAssertNotNil(record, @"Failed to create record in database: %@");

	record[@"first_name"] = @"Isaac";
	record[@"last_name"] = @"Newton";
	record[@"last_name"] = @(44);
	record.recordHasChanges = YES;
	
	NSError					*error = [db saveWithCompletion: nil];
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordFetching {
	SAStorage_Database		*db = self.db;
	
	[db insertNewRecordOfType: @"Contact" completion:^(SAStorage_Record *record, NSError *error) {
		STAssertNotNil(record, @"Failed to create record in database: %@");
		
		
		
		
	}];
	[db deleteBackingStore];
}

@end


@implementation SAStorage_ErrorManagerTesting
- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info {
	[self handleFatal: fatal error: error onObject: object userInfo: info description: nil];
}

- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSString		*message = [NSString stringWithFormat: @"%@: %@ (%@)\n%@", ConvertErrorToString(error), object, info, description ?: @""];
	NSLog(@"Message: %@", message);
	STAssertFalse(YES, message);
}

@end