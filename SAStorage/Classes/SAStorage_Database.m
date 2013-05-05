//
//  SAStorage_Database.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage.h"
#import "SAStorage_SQLiteDatabase.h"
#import "SAStorage_JSONDatabase.h"
#import "SAStorage_FSDatabase.h"

@implementation SAStorage_Database
- (void) dealloc {
	#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
		if (_completionQueue) dispatch_release(_completionQueue);
	#endif
}

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema {
	return [self databaseWithURL: url ofType: type basedOn: schema flags: 0];
}

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema flags: (SAStorage_Database_Flags) flags {
	SAStorage_Database				*db = nil;
	
	switch (type) {
		case SAStorage_Database_JSON:
			db = [[SAStorage_JSONDatabase alloc] initWithURL: url andSchema: schema];
			break;
			
		case SAStorage_Database_SQL:
			db = [[SAStorage_SQLiteDatabase alloc] initWithURL: url andSchema: schema];
			break;
			
		case SAStorage_Database_FS:
			db = [[SAStorage_FSDatabase alloc] initWithURL: url andSchema: schema];
			break;
			
		default:
			break;
	}
	
	if (flags & SAStorage_Database_readOnly) db.readOnly = YES;
	return db;
}

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema {
	if ((self = [super init])) {
		self.url = url;
		self.schema = schema;
		self.completionQueue = dispatch_get_main_queue();
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
#pragma mark Properties
- (void) setCompletionQueue: (dispatch_queue_t) completionQueue {
	#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
		if (completionQueue) dispatch_retain(completionQueue);
		if (_completionQueue) dispatch_release(_completionQueue);
	#endif
	_completionQueue = completionQueue;
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

- (BOOL) dirty {
	return _dirty || self.changedRecords.count > 0;
}

//=============================================================================================================================
#pragma mark Overrides
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion {
	return nil;
}

- (SAStorage_Query *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	return nil;
}

- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	return nil;
}

- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
	return nil;
}

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	return 0;
}

- (SAStorage_Record *) resolveProxy: (SAStorage_Proxy *) proxy {
	return nil;
}

- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion {
	return nil;
}

- (NSString *) metadataValueForKey: (NSString *) key {
	return nil;
}

- (void) setMetadataValue: (NSString *) value forKey: (NSString *) key {
	
}

- (void) deleteRecord: (id) recordOrProxy {
	
}

- (NSError *) deleteBackingStore {
	return nil;
}

- (id) objectForKeyedSubscript: (id) key {
	return nil;
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	
}
@end
