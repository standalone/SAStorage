//
//  SAStorage_JSONDatabase.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_JSONDatabase.h"
#import "SAStorage_Headers.h"
#import "SAStorage_Record.h"

@interface NSMutableArray (SAStorage_JSONDatabase)
- (id) dictionaryRepresentation;
@end

@interface SAStorage_JSONDatabase ()
@property (nonatomic, strong) NSMutableDictionary *metadata;
@property (nonatomic, strong) NSMutableDictionary *tables;
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
			
			self.tables[table.name] = records;
			for (NSDictionary *recordDictionary in json[@"tables"][table.name]) {
				SAStorage_Record		*record = [SAStorage_Record recordInDatabase: self andTable: table.name withRecordID: [recordDictionary[@"id"] intValue]];
				
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
- (void) saveWithCompletion: (SAStorage_ErrorCallback) completion {
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
}

- (void) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(nil, error);
		return;
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
	
	completion([SAStorage_ResultSet resultSetWithRecords: results], nil);
}

- (void) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(nil, error);
		return;
	}
	
	if (query.predicate) {
		if (query.sortedBy) records = [records sortedArrayUsingDescriptors: query.sortedBy];
		
		for (SAStorage_Record *record in records) {
			if ([record matchesPredicate: query.predicate]) {
				completion(record, nil);
				return;
			}
		}
	} else {
		completion(records.count ? records[0] : nil, nil);
	}
}

- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(nil, error);
		return;
	}

	NSArray						*availableFields = [[self.schema[query.tableName] fields] valueForKey: @"name"];
	
	for (NSString *field in fields) {
		if (![availableFields containsObject: field]) {
			error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchField userInfo: @{ @"tableName": query.tableName, @"field": field}];
			completion(nil, error);
			return;
		}
	}
		

	NSMutableArray			*results = nil;

	if (query.sortedBy) records = [records sortedArrayUsingDescriptors: query.sortedBy];
	
	results = [NSMutableArray array];
	
	for (SAStorage_Record *record in records) {
		if ([record matchesPredicate: query.predicate]) [results addObject: [record dictionaryWithFields: fields]];
	}
	completion([SAStorage_ResultSet resultSetWithRecords: results], nil);
}

- (void) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	NSArray					*records = self.tables[query.tableName];
	NSError					*error = nil;
	if (records == nil) {
		error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_NoSuchTable userInfo: @{ @"tableName": query.tableName}];
		completion(0, error);
		return;
	}
	
	NSUInteger					count = 0;
	
	if (query.predicate == nil) {
		count = records.count;
	} else {
		for (SAStorage_Record *record in records) {
			if ([record matchesPredicate: query.predicate]) count++;
		}
	}
	completion(count, nil);
}

- (void) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion {
	NSString					*metadataIDKey = [NSString stringWithFormat: @"currentID_%@", recordType];
	NSUInteger					lastID = [[self metadataValueForKey: metadataIDKey] integerValue] + 1;
	
	[self setMetadataValue: [NSString stringWithFormat: @"%u", lastID] forKey: metadataIDKey];
	
	SAStorage_Record			*record = [SAStorage_Record recordInDatabase: self andTable: recordType withRecordID: lastID];
	
	record.backingDictionary = [NSMutableDictionary dictionary];
	NSMutableArray				*tableRecords = self.tables[recordType];
	if (tableRecords == nil) {
		
	}
	[tableRecords addObject: record];
	
	completion(record, nil);
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