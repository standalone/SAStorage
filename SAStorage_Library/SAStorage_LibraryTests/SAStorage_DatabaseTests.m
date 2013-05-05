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
	[[NSFileManager defaultManager] removeItemAtURL: self.databaseURL error: nil];
}

- (NSURL *) databaseURL { return DATABASE_URL; }
- (NSString *) databaseExtension { return @"json"; }

- (SAStorage_Schema *) testSchema {
	SAStorage_Schema		*schema = [SAStorage_Schema schemaWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"]];
	STAssertNotNil(schema, @"Failed to construct schema from sample JSON");
	return schema;
}

- (SAStorage_Database *) emptyDB {
	SAStorage_Database				*db = [SAStorage_Database databaseWithURL: self.databaseURL ofType: self.databaseType basedOn: self.testSchema];
	SAStorage_ErrorManagerTesting	*mgr = [[SAStorage_ErrorManagerTesting alloc] init];
	
	db.validateSchemaFields = YES;
	db.errors = mgr;
	mgr.target = self;
	
	return db;
}

- (SAStorage_Database *) filledDB {
	SAStorage_Database				*db = [SAStorage_Database databaseWithURL: [[NSBundle mainBundle] URLForResource: @"sample_database" withExtension: self.databaseExtension] ofType: self.databaseType basedOn: self.testSchema];
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
	
	
	//set up contacts
	NSMutableArray			*contacts = [NSMutableArray array];
	NSArray					*contactFields = @[
	   @{@"first_name": @"Barack", @"last_name": @"Obama", @"age": @(52)},
	   @{@"first_name": @"Michelle", @"last_name": @"Obama", @"age": @(48)},
	   @{@"first_name": @"Sasha", @"last_name": @"Obama", @"age": @(6)},
	   @{@"first_name": @"Malia", @"last_name": @"Obama", @"age": @(8)},
	];
	
	for (NSDictionary *fieldSet in contactFields) {
		SAStorage_Record		*record = [db insertNewRecordOfType: @"Contact" withFields: fieldSet completion: nil];
		STAssertNotNil(record, @"Failed to create record in database: %@");
		[contacts addObject: record];
	}
	
	contacts[0][@"spouse"] = contacts[1];
	STAssertNotNil(contacts[1][@"spouse"], @"Failed to create back link when creating 1-1 relationship");
	
	contacts[0][@"kids"] = @[ contacts[2], contacts[3] ];
	STAssertTrue([contacts[2][@"parents"] count] > 0, @"Failed to create back link when creating many-to-many relationship");

	contacts[1][@"kids"] = @[ contacts[2], contacts[3] ];
	contacts[2][@"parents"] = @[ contacts[0], contacts[1] ];
	contacts[3][@"parents"] = @[ contacts[0], contacts[1] ];

	//set up vehicles
	NSMutableArray			*vehicles = [NSMutableArray array];
	NSArray					*vehicleFields = @[
			@{@"name": @"Marine One", @"make": @"Sikorsky", @"model": @"VH-60N"},
			@{@"name": @"Air Force One", @"make": @"Boeing", @"model": @"747"},
			@{@"name": @"Limo", @"make": @"GM", @"model": @"Stretch Limo"},
			@{@"name": @"Bike", @"make": @"Schwinn", @"model": @"Roadmaster"},
		];
	
	for (NSDictionary *fieldSet in vehicleFields) {
		SAStorage_Record		*record = [db insertNewRecordOfType: @"Vehicle" withFields: fieldSet completion: nil];
		STAssertNotNil(record, @"Failed to create record in database: %@");
		[vehicles addObject: record];
	}
	
	contacts[0][@"vehicles"] = [vehicles subarrayWithRange: NSMakeRange(0, 3)];
	contacts[2][@"vehicles"] = @[ vehicles[3] ];

	
	NSError					*error = [db saveWithCompletion: nil];
	STAssertNil(error, @"There was an error saving the database: %@", error);
	[db deleteBackingStore];
}

- (void) testRecordFetching {
	SAStorage_Database		*db = self.filledDB;
	SAStorage_Query			*query = [SAStorage_Query queryInTable: @"Contact" withPredicate: [NSPredicate predicateWithFormat: @"first_name == %@", @"Barack"]];
	SAStorage_Record		*record = [db anyRecordMatchingQuery: query completion: nil];
	
	STAssertNotNil(record, @"Record Fetch Failed");
	STAssertNotNil(record[@"spouse"], @"1-1 Relationship Fetch Failed");
	STAssertTrue([record[@"vehicles"] count] > 0, @"1-Many Relationship Fetch Failed");
	STAssertTrue([record[@"kids"] count] > 0, @"Many-to-Many Relationship Fetch Failed");
	
}

@end


@implementation SAStorage_ErrorManagerTesting
- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSString		*message = [NSString stringWithFormat: @"%@: %@ (%@)\n%@", ConvertErrorToString(error), object, info, description ?: @""];
	NSLog(@"Message: %@", message);
	
	[self.target failWithException: [NSException exceptionWithName: @"Error Manager" reason: message userInfo: nil]];
}

@end