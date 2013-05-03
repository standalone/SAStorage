//
//  SAStorage_FSDatabase.m
//  SADataTester
//
//  Created by Ben Gottlieb on 5/2/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_FSDatabase.h"
#import "SAStorage.h"

@interface SAStorage_FSDatabase ()
@property (nonatomic, strong) NSURL *metadataURL, *tablesURL;
@property (nonatomic) BOOL metadataDirty;
@property (nonatomic, strong) NSMutableSet *deletedRecords;
@end


@implementation SAStorage_FSDatabase

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		NSFileManager			*mgr = [NSFileManager defaultManager];
		NSError					*error = nil;
		BOOL					isDirectory;
		BOOL					exists = [mgr fileExistsAtPath: url.path isDirectory: &isDirectory];
		
		if (exists && !isDirectory) {
			NSLog(@"Error while loading FSDatabase, path exists, but is not a directory");
			return nil;
		}
		
		if (!exists) {
			[mgr createDirectoryAtURL: url withIntermediateDirectories: YES attributes: nil error: &error];
			if (error) {
				NSLog(@"Error while creating FSDatabase: %@", error);
				return nil;
			}
		}
		
		self.metadataURL = [url URLByAppendingPathComponent: @"metadata.json"];
		self.tablesURL = [url URLByAppendingPathComponent: @"tables"];
		
		NSData					*data = [NSData dataWithContentsOfURL: self.metadataURL];
		self.metadata = data ? [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error] : nil;
		
		if (error) NSLog(@"Error loading metadata from %@: %@", self.metadataURL, error);
		
		if (self.metadata == nil) {
			self.metadata = [NSMutableDictionary dictionary];
			self.metadata[@"schema_hash"] = @(schema.hash);
		}
		
		self.tables = [NSMutableDictionary dictionary];
		
		[self postInitSetup];
	}
	return self;
}

//=============================================================================================================================
#pragma mark Utilities
- (NSURL *) urlForTableNamed: (NSString *) table { return [self.tablesURL URLByAppendingPathComponent: table]; }
- (NSURL *) urlForRecordID: (SAStorage_RecordIDType) recordID inTable: (NSString *) table {
	return [[self urlForTableNamed: table] URLByAppendingPathComponent: [NSString stringWithFormat: @"%@ %d.json", table, recordID]];
}

- (NSError *) loadRecordsInTable: (NSString *) tableName {
	if (self.tables[tableName]) return nil;				//already loaded
	
	NSFileManager			*mgr = [NSFileManager defaultManager];
	NSError					*error = nil;
	
	SAStorage_SchemaTable		*table = self.schema[tableName];
	NSMutableArray				*records = [NSMutableArray array];
	Class						recordClass = table.recordClass ?: [SAStorage_Record class];
	BOOL						isDirectory;
	NSURL						*tableURL = [self urlForTableNamed: table.name];
	
	self.tables[table.name] = records;
	
	if (![mgr fileExistsAtPath: tableURL.path isDirectory: &isDirectory]) {
		[mgr createDirectoryAtURL: tableURL withIntermediateDirectories: YES attributes: nil error: &error];
		if (error) return error;
	} else if (!isDirectory) {
		NSLog(@"Tried to create a table directory, found a file at %@", tableURL.path);
		return [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_UnexpectedFile userInfo: nil];
	}
	
	for (NSURL *fileURL in [mgr contentsOfDirectoryAtURL: tableURL includingPropertiesForKeys: @[] options: 0 error: &error]) {
		NSString				*filename = fileURL.lastPathComponent.stringByDeletingPathExtension;
		
		if (![filename hasPrefix: table.name]) continue;
		
		NSData					*recordData = [NSData dataWithContentsOfURL: fileURL];
		NSDictionary			*recordDictionary = recordData ? [NSJSONSerialization JSONObjectWithData: recordData options: 0 error: &error] : nil;
		
		if (recordDictionary == nil || error) {
			NSLog(@"Failed to load a %@ record from %@: %@", table.name, fileURL, error);
			continue;
		}
		
		SAStorage_Record		*record = [recordClass recordInDatabase: self andTable: table.name withRecordID: [[[filename componentsSeparatedByString: @" "] lastObject] intValue]];
		
		[record populateBackingDictionaryFromDictionary: recordDictionary];
		[records addObject: record];
	}
	return nil;
}

//=============================================================================================================================
#pragma mark Overrides
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion {
	NSData				*data;
	NSError				*error;
	
	if (self.metadataDirty) {
		data = [NSJSONSerialization dataWithJSONObject: self.metadata options: NSJSONWritingPrettyPrinted error: &error];
		if (error == nil) [data writeToURL: self.metadataURL options: NSDataWritingAtomic error: &error];
		if (error) {
			NSLog(@"Error while writing out metadata: %@", error);
			if (completion) completion(error);
		} else
			self.metadataDirty = NO;
	}
	
	for (SAStorage_Record *dirtyRecord in self.changedRecords.copy) {
		NSURL			*url = [self urlForRecordID: dirtyRecord.recordID inTable: dirtyRecord.tableName];
		
		data = [NSJSONSerialization dataWithJSONObject: dirtyRecord.dictionaryRepresentation options: NSJSONWritingPrettyPrinted error: &error];
		if (error == nil) [data writeToURL: url options: NSDataWritingAtomic error: &error];
		if (error) {
			NSLog(@"Error while writing out record %d: %@", dirtyRecord.recordID, error);
			if (completion) completion(error);
		} else {
			[self.changedRecords removeObject: dirtyRecord];
		}
	}
	return error;
}

- (SAStorage_Query *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	[self loadRecordsInTable: query.tableName];
	return [super recordsMatchingQuery: query completion: completion];
}
- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
	[self loadRecordsInTable: query.tableName];
	return [super anyRecordMatchingQuery: query completion: completion];
}

- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	[self loadRecordsInTable: query.tableName];
	return [super fields: fields fromRecordsMatchingQuery: query completion: completion];
}

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	[self loadRecordsInTable: query.tableName];
	return [super numberOfRecordsMatchingQuery: query completion: completion];
}


- (void) deleteRecord: (id) recordOrProxy {
	SAStorage_Record		*record = recordOrProxy;
	NSMutableArray			*records = self.tables[record.tableName];
	
	if (self.deletedRecords == nil) self.deletedRecords = [NSMutableSet set];
	[records removeObject: record];
	[self.deletedRecords addObject: recordOrProxy];
}

- (NSError *) deleteBackingStore {
	NSError					*error;
	
	[[NSFileManager defaultManager] removeItemAtURL: self.url error: &error];
	return error;
}


- (void) setMetadataValue:(NSString *)value forKey:(NSString *)key {
	[super setMetadataValue: value forKey: key];
	self.metadataDirty = YES;
}
@end