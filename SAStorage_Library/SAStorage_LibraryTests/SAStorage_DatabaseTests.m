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
	self.databaseType = SAStorage_Database_JSON;
	[[NSFileManager defaultManager] removeItemAtURL: DATABASE_URL error: nil];
}

- (SAStorage_Schema *) testSchema {
	SAStorage_Schema		*schema = [SAStorage_Schema schemaWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"]];
	STAssertNotNil(schema, @"Failed to construct schema from sample JSON");
	return schema;
}

- (SAStorage_Database *) emptyDB {
	SAStorage_Database				*db = [SAStorage_Database databaseWithURL: DATABASE_URL ofType: self.databaseType basedOn: self.testSchema];
	SAStorage_ErrorManagerTesting	*mgr = [[SAStorage_ErrorManagerTesting alloc] init];
	
	db.validateSchemaFields = YES;
	db.errors = mgr;
	mgr.target = self;
	
	return db;
}

- (SAStorage_Database *) filledDB {
	SAStorage_Database				*db = [SAStorage_Database databaseWithURL: [[NSBundle mainBundle] URLForResource: @"sample_database" withExtension: @"json"] ofType: self.databaseType basedOn: self.testSchema];
	SAStorage_ErrorManagerTesting	*mgr = [[SAStorage_ErrorManagerTesting alloc] init];
	
	db.validateSchemaFields = YES;
	db.errors = mgr;
	mgr.target = self;
	
	return db;
}

- (void) testDatabaseCreation {
	SAStorage_Database		*db = self.emptyDB;
	NSError					*error = [db saveWithCompletion: nil];
	
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordCreation {
	SAStorage_Database		*db = self.emptyDB;
	
	SAStorage_Record		*record = [db insertNewRecordOfType: @"Contact" completion: nil];
	STAssertNotNil(record, @"Failed to create record in database: %@");
	
	record[@"first_name"] = @"Barack";
	record[@"last_name"] = @"Obama";
	record[@"age"] = @(52);
	record.recordHasChanges = YES;
	
	NSError					*error = [db saveWithCompletion: nil];
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordRelationships {
	SAStorage_Database		*db = self.emptyDB;
	
	NSMutableArray			*contacts = [NSMutableArray array];
	NSArray					*fields = @[
	   @{@"first_name": @"Barack", @"last_name": @"Obama", @"age": @(52)},
	   @{@"first_name": @"Michelle", @"last_name": @"Obama", @"age": @(48)},
	   @{@"first_name": @"Sasha", @"last_name": @"Obama", @"age": @(6)},
	   @{@"first_name": @"Malia", @"last_name": @"Obama", @"age": @(8)},
	];
	
	for (NSDictionary *fieldSet in fields) {
		SAStorage_Record		*record = [db insertNewRecordOfType: @"Contact" withFields: fieldSet completion: nil];
		STAssertNotNil(record, @"Failed to create record in database: %@");
		[contacts addObject: record];
	}
	
	contacts[0][@"spouse"] = contacts[1];
	contacts[0][@"kids"] = @[ contacts[2], contacts[3] ];
	contacts[2][@"parents"] = @[ contacts[0], contacts[1] ];
	contacts[3][@"parents"] = @[ contacts[0], contacts[1] ];

	NSError					*error = [db saveWithCompletion: nil];
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordFetching {
	SAStorage_Database		*db = self.filledDB;
	SAStorage_Query			*query = [SAStorage_Query queryInTable: @"Contact" withPredicate: [NSPredicate predicateWithFormat: @"first_name == %@", @"Barack"]];
	SAStorage_Record		*record = [db anyRecordMatchingQuery: query completion: nil];
	
	NSLog(@"Record: %@", record);
//	STAssertNotNil(record, @"Record Fetch Failed");
}

@end


@implementation SAStorage_ErrorManagerTesting
- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSString		*message = [NSString stringWithFormat: @"%@: %@ (%@)\n%@", ConvertErrorToString(error), object, info, description ?: @""];
	NSLog(@"Message: %@", message);
	
	[self.target failWithException: [NSException exceptionWithName: @"Error Manager" reason: message userInfo: nil]];
}

@end