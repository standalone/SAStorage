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

@interface SAStorage_ErrorManagerTesting : SAStorage_ErrorManager
@property (nonatomic, weak) SenTestCase *target;
@end

@interface SAStorage_DatabaseTests ()
@end

@implementation SAStorage_DatabaseTests

- (void) setUp {
    [super setUp];
	[[NSFileManager defaultManager] removeItemAtURL: DATABASE_URL error: nil];
}

- (SAStorage_Schema *) testSchema {
	SAStorage_Schema		*schema = [SAStorage_Schema schemaWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"]];
	STAssertNotNil(schema, @"Failed to construct schema from sample JSON");
	return schema;
}

- (SAStorage_Database *) db {
	SAStorage_Database				*db = [SAStorage_Database databaseWithURL: DATABASE_URL ofType: SAStorage_Database_JSON basedOn: self.testSchema];
	SAStorage_ErrorManagerTesting	*mgr = [[SAStorage_ErrorManagerTesting alloc] init];
	
	db.validateSchemaFields = YES;
	db.errors = mgr;
	mgr.target = self;
	
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

	SAStorage_Record		*record = [db insertNewRecordOfType: @"Contacts" completion: nil];
	STAssertNotNil(record, @"Failed to create record in database: %@");
	
	record[@"first_name"] = @"Barack";
	record[@"last_name"] = @"Obama";
	record[@"age"] = @(52);
	record.recordHasChanges = YES;

	SAStorage_Record		*secondRecord = [db insertNewRecordOfType: @"Contacts" completion: nil];
	STAssertNotNil(record, @"Failed to create record in database: %@");
	
	secondRecord[@"first_name"] = @"Michelle";
	secondRecord[@"last_name"] = @"Obama";
	secondRecord[@"age"] = @(44);
	secondRecord[@"spouse"] = record;
	
	secondRecord.recordHasChanges = YES;

	NSError					*error = [db saveWithCompletion: nil];
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordFetching {
	SAStorage_Database		*db = self.db;
	
	[db insertNewRecordOfType: @"Contacts" completion:^(SAStorage_Record *record, NSError *error) {
		STAssertNotNil(record, @"Failed to create record in database: %@");
		
		
		
		
	}];
	[db deleteBackingStore];
}

@end


@implementation SAStorage_ErrorManagerTesting
- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSString		*message = [NSString stringWithFormat: @"%@: %@ (%@)\n%@", ConvertErrorToString(error), object, info, description ?: @""];
	NSLog(@"Message: %@", message);
	
	[self.target failWithException: [NSException exceptionWithName: @"Error Manager" reason: message userInfo: nil]];
}

@end