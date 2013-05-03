//
//  SAStorage_JSONDatabase.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_JSONDatabase.h"
#import "SAStorage.h"

@interface NSMutableArray (SAStorage_JSONDatabase)
- (id) dictionaryRepresentation;
@end

@interface SAStorage_JSONDatabase ()
@end

@implementation SAStorage_JSONDatabase

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		NSData					*data = [NSData dataWithContentsOfURL: url];
		NSError					*error = nil;
		NSDictionary			*json = data ? [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error] : nil;
		
		if (error) NSLog(@"Error loading JSON from %@: %@", url, error);
		
		if (json[@"metadata"]) {
			self.metadata = [json[@"metadata"] mutableCopy];
		} else {
			self.metadata = [NSMutableDictionary dictionary];
			self.metadata[@"schema_hash"] = @(schema.hash);
		}
				
		self.tables = [NSMutableDictionary dictionary];
		for (SAStorage_SchemaTable *table in schema.tables.allValues) {
			NSMutableArray				*records = [NSMutableArray array];
			Class						recordClass = table.recordClass ?: [SAStorage_Record class];
			
			self.tables[table.name] = records;
			for (NSDictionary *recordDictionary in json[@"tables"][table.name]) {
				SAStorage_Record		*record = [recordClass recordInDatabase: self andTable: table.name withRecordID: [recordDictionary[@"id"] intValue]];
				
				[record populateBackingDictionaryFromDictionary: recordDictionary];
				[records addObject: record];
			}
		}

		[self postInitSetup];
	}
	return self;
}

//=============================================================================================================================
#pragma mark Overrides
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion {
	NSMutableDictionary			*jsonTables = [NSMutableDictionary dictionary];
	for (NSString *name in self.tables) {
		jsonTables[name] = [self.tables[name] dictionaryRepresentation];
	}
	
	NSDictionary			*dictionary = @{ @"metadata": self.metadata, @"tables": jsonTables };
	NSError					*error = nil;
	NSData					*data = [NSJSONSerialization dataWithJSONObject: dictionary options: NSJSONWritingPrettyPrinted error: &error];
	
	if (error == nil) [data writeToURL: self.url options: NSDataWritingAtomic error: &error];
	
	if (error) {
		NSLog(@"Error writing out JSON file: %@", error);
	} else {
		self.dirty = NO;
		[self.changedRecords removeAllObjects];
	}
	if (completion) completion(error);
	return error;
}

- (SAStorage_ResultSet *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		if (completion) completion([SAStorage_ResultSet resultSetWithError: error]);
		return completion ? nil : [SAStorage_ResultSet resultSetWithError: error];
	}
	
	NSMutableArray			*results = nil;
	
	
	if (query.predicate) {
		if (query.sortedBy) records = [records sortedArrayUsingDescriptors: query.sortedBy];
		
		results = [NSMutableArray array];
		
		for (SAStorage_Record *record in records) {
			if ([record matchesPredicate: query.predicate]) [results addObject: record];
		}
	} else
		results = query.sortedBy ? [records sortedArrayUsingDescriptors: query.sortedBy] : records.copy;
	
	if (completion) completion([SAStorage_ResultSet resultSetWithRecords: results]);
	return completion ? nil : [SAStorage_ResultSet resultSetWithRecords: results];
}

- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(nil, error);
		return nil;
	}
	
	if (query.predicate) {
		if (query.sortedBy) records = [records sortedArrayUsingDescriptors: query.sortedBy];
		
		for (SAStorage_Record *record in records) {
			if ([record matchesPredicate: query.predicate]) {
				if (record) completion(record, nil);
				return record;
			}
		}
	} else {
		completion(records.count ? records[0] : nil, nil);
	}
	
	return (completion || records.count == 0) ? nil : records[0];
}

- (SAStorage_ResultSet *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		if (completion) completion([SAStorage_ResultSet resultSetWithError: error]);
		return completion ? nil : [SAStorage_ResultSet resultSetWithError: error];
	}

	NSArray						*availableFields = [[self.schema[query.tableName] fields] valueForKey: @"name"];
	
	for (NSString *field in fields) {
		if (![availableFields containsObject: field]) {
			error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchField userInfo: @{ @"tableName": query.tableName, @"field": field}];
			if (completion) completion([SAStorage_ResultSet resultSetWithError: error]);
			return completion ? nil : [SAStorage_ResultSet resultSetWithError: error];
		}
	}
		

	NSMutableArray			*results = nil;

	if (query.sortedBy) records = [records sortedArrayUsingDescriptors: query.sortedBy];
	
	results = [NSMutableArray array];
	
	for (SAStorage_Record *record in records) {
		if ([record matchesPredicate: query.predicate]) [results addObject: [record dictionaryWithFields: fields]];
	}
	if (completion) completion([SAStorage_ResultSet resultSetWithRecords: results]);
	return completion ? nil : [SAStorage_ResultSet resultSetWithRecords: results];
}

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(0, error);
		return 0;
	}
	
	NSUInteger					count = 0;
	
	if (query.predicate == nil) {
		count = records.count;
	} else {
		for (SAStorage_Record *record in records) {
			if ([record matchesPredicate: query.predicate]) count++;
		}
	}
	if (completion) completion(count, nil);
	return completion ? 0 : count;
}

- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion {
	NSString					*metadataIDKey = [NSString stringWithFormat: @"currentID_%@", recordType];
	NSUInteger					lastID = [[self metadataValueForKey: metadataIDKey] integerValue] + 1;
	
	[self setMetadataValue: [NSString stringWithFormat: @"%u", lastID] forKey: metadataIDKey];
	
	Class						recordClass = [self.schema.tables[recordType] recordClass] ?: [SAStorage_Record class];
	
	SAStorage_Record			*record = [recordClass recordInDatabase: self andTable: recordType withRecordID: lastID];
	
	record.backingDictionary = [NSMutableDictionary dictionary];
	NSMutableArray				*tableRecords = self.tables[recordType];
	if (tableRecords == nil) {
		
	}
	[tableRecords addObject: record];
	
	if (completion) completion(record, nil);
	return completion ? nil : record;
}

- (NSString *) metadataValueForKey: (NSString *) key {
	return self.metadata[key];
}

- (void) setMetadataValue: (NSString *) value forKey: (NSString *) key {
	self.dirty = YES;
	if (key)
		self.metadata[key] = value;
	else
		[self.metadata removeObjectForKey: key];
}

- (void) deleteRecord: (id) recordOrProxy {
	SAStorage_Record		*record = recordOrProxy;
	NSMutableArray			*records = self.tables[record.tableName];
	
	[records removeObject: record];
}

@end


@implementation NSMutableArray (SAStorage_JSONDatabase)
- (id) dictionaryRepresentation {
	NSMutableArray				*array = [NSMutableArray arrayWithCapacity: self.count];
	
	for (SAStorage_Record *record in self) {
		[array addObject: record.dictionaryRepresentation];
	}
	return array;
}
@end