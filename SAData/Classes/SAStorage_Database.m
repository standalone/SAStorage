//
//  SAStorage_Database.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Headers.h"
#import "SAStorage_SQLiteDatabase.h"


@implementation SAStorage_Database

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema {
	SAStorage_Database				*db = nil;
	
	switch (type) {
		case SAStorage_Database_SQL:
			db = [[SAStorage_SQLiteDatabase alloc] initWithURL: url andSchema: schema];
			break;
			
		default:
			break;
	}
	
	return db;
}

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema {
	if ((self = [super init])) {
		self.url = url;
		self.schema = schema;
	}
	return self;
}

- (void) postInitSetup {
	_uuid = [self metadataValueForKey: @"uuid"];
	if (self.uuid == nil) {
		_uuid = [SAStorage uuid];
		[self setMetadataValue: _uuid forKey: @"uuid"];
	}
}

//=============================================================================================================================
#pragma mark Record Changes
- (void) markRecord: (SAStorage_Record *) record changed: (BOOL) changed {
	if (changed && self.changedRecords == nil) self.changedRecords = [NSMutableSet set];
	
	if (changed)
		[self.changedRecords addObject: record];
	else
		[self.changedRecords removeObject: record];
}

//=============================================================================================================================
#pragma mark Overrides
- (void) saveWithCompletion: (SAStorage_ErrorCallback) completion {
	
}

- (void) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	
}

- (void) proxiesMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	
}

- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	
	
}

- (void) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	
}

- (SAStorage_Record *) resolveProxy: (SAStorage_Proxy *) proxy {
	return nil;
}

- (void) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion {
	
}

- (NSString *) metadataValueForKey: (NSString *) key {
	return nil;
}

- (void) setMetadataValue: (NSString *) value forKey: (NSString *) key {
	
}

- (void) deleteRecord: (id) record {
	
}
@end
