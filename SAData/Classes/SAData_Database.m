//
//  SAData_Database.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_Database.h"
#import "SAData_SQLiteDatabase.h"



@implementation SAData_Database

+ (id) databaseWithURL: (NSURL *) url ofType: (SAData_Database_Type) type basedOn: (SAData_Schema *) schema {
	SAData_Database				*db = nil;
	
	switch (type) {
		case SAData_Database_SQL:
			db = [[SAData_SQLiteDatabase alloc] initWithURL: url andSchema: schema];
			break;
			
		default:
			break;
	}
	
	return db;
}

- (id) initWithURL: (NSURL *) url andSchema: (SAData_Schema *) schema {
	if ((self = [super init])) {
		self.url = url;
		self.schema = schema;
	}
	return self;
}

- (void) recordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
}

- (void) proxiesMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
}

- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
	
}

- (void) numberOfRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCountCallback) completion {
	
}

- (SAData_Record *) resolveProxy: (SAData_Proxy *) proxy {
	return nil;
}

- (void) insertNewRecordOfType: (NSString *) recordType completion: (SAData_RecordCallback) completion {
	
}
@end
