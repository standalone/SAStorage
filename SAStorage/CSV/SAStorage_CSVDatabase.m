//
//  SAStorage_CSVDatabase.m
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_CSVDatabase.h"
#import "SAStorage.h"
#import "SAStorage_JSONTable.h"
#import "SAStorage_CSVParser.h"

@interface SAStorage_CSVTable : SAStorage_JSONTable
@end

@interface SAStorage_CSVDatabase ()
@property (nonatomic, strong) NSURL *metadataURL, *dataURL;
@property (nonatomic) BOOL metadataDirty;
@property (nonatomic, strong) NSMutableSet *deletedRecords;
@end


@implementation SAStorage_CSVDatabase

+ (NSString *) tableName { return @"data"; }

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_SchemaBundle *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		NSFileManager			*mgr = [NSFileManager defaultManager];
		NSError					*error = nil;
		BOOL					isDirectory;
		BOOL					exists = [mgr fileExistsAtPath: url.path isDirectory: &isDirectory];
		
		self.iterationSeparator = '\x1d';
		self.fieldSeparator = ',';
		self.recordSeparator = '\r';
		
		if (exists && !isDirectory) {
			NSLog(@"Error while loading CSVDatabase, path exists, but is not a directory");
			return nil;
		}
		
		if (!exists) {
			[mgr createDirectoryAtURL: url withIntermediateDirectories: YES attributes: nil error: &error];
			if (error) {
				NSLog(@"Error while creating CSVDatabase: %@", error);
				return nil;
			}
		}
		
		self.metadataURL = [url URLByAppendingPathComponent: @"metadata.json"];
		self.dataURL = [url URLByAppendingPathComponent: @"data.csv"];
		
		NSData					*data = [NSData dataWithContentsOfURL: self.metadataURL];
		self.metadata = data ? [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error] : nil;
		
		if (error) NSLog(@"Error loading metadata from %@: %@", self.metadataURL, error);
		
		if (self.metadata == nil) {
			self.metadata = [NSMutableDictionary dictionary];
			self.metadata[SCHEMA_HASH_KEY] = @(self.schema.hash);
		}
		
		self.tables = [NSMutableDictionary dictionary];
		
		[self postInitSetup];
	}
	return self;
}

//=============================================================================================================================
#pragma mark Utilities

- (NSError *) loadRecords {
	NSString			*tableName = [SAStorage_CSVDatabase tableName];
	
	if (self.tables[tableName]) return nil;				//already loaded
	
	NSFileManager			*mgr = [NSFileManager defaultManager];
	NSError					*error = nil;
	
	NSURL						*dataURL = self.dataURL;
	SAStorage_CSVTable			*table = [SAStorage_CSVTable tableInDatabase: self];
	BOOL						isDirectory;
	Class						recordClass = [SAStorage_Record class];
	
	self.tables[tableName] = table;
	
	if (![mgr fileExistsAtPath: dataURL.path isDirectory: &isDirectory]) {
		return nil;			//no data
	} else if (isDirectory) {
		NSLog(@"Tried to create a data file, found a directory at %@", dataURL.path);
		return [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_UnexpectedDirectory userInfo: nil];
	}
	
	NSData				*raw = [NSData dataWithContentsOfURL: dataURL options: NSDataReadingMappedIfSafe error: &error];
	if (error) return error;
	
	SAStorage_CSVParser		*parser = [SAStorage_CSVParser parserWithData: raw];
	parser.iterationSeparator = self.iterationSeparator;
	parser.fieldSeparator = self.fieldSeparator;
	parser.recordSeparator = self.recordSeparator;
	
	error = [parser beginParsing];
	if (error) return error;
	
	NSDictionary			*fields;
	
	while ((fields = [parser nextRecordWithError: &error])) {
		SAStorage_Record		*record = [recordClass recordInDatabase: self andTable: tableName withRecordID: [fields[@"id"] integerValue]];
		
		[record populateBackingDictionaryFromDictionary: fields];
		[table addRecord: record];
	}
	
	self.schema = [[SAStorage_Schema alloc] init];
	self.schema.tables = @{ tableName: parser.schemaTable }.mutableCopy;
	self.tables = @{ tableName: table }.mutableCopy;
	if (error) return error;
	return nil;
}

- (id) objectForKeyedSubscript: (id) key {
	[self loadRecords];
	return self.tables[key];
}

//=============================================================================================================================
#pragma mark Overrides
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion {
	NSError				*error;
	
	if (self.readOnly) {
		if (completion) completion([SAStorage_Error error: SAStorage_Error_TryingToSaveReadnlyDatabase info: nil]);
		return [SAStorage_Error error: SAStorage_Error_TryingToSaveReadnlyDatabase info: nil];
	}
		
	SAStorage_CSVParser				*parser = [SAStorage_CSVParser parserWithSchemaTable: self.schema[[SAStorage_CSVDatabase tableName]]];
	SAStorage_CSVTable				*table = self.tables[[SAStorage_CSVDatabase tableName]];
	
	parser.iterationSeparator = self.iterationSeparator;
	parser.fieldSeparator = self.fieldSeparator;
	parser.recordSeparator = self.recordSeparator;

	[parser beginWriting];
	for (SAStorage_Record *record in table.records) {
		[parser writeRecord: record];
	}
	
	NSData							*data = [parser finishWriting];
	
	[data writeToURL: self.url atomically: YES];
	
	return error;
}

- (SAStorage_Query *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	[self loadRecords];
	return [super recordsMatchingQuery: query completion: completion];
}
- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
	[self loadRecords];
	return [super anyRecordMatchingQuery: query completion: completion];
}

- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {
	[self loadRecords];
	return [super fields: fields fromRecordsMatchingQuery: query completion: completion];
}

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {
	[self loadRecords];
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


@implementation SAStorage_CSVTable
@end