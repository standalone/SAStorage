//
//  SAStorage_Record.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Record.h"
#import "SAStorage_Database.h"

@interface SAStorage_Record ()
@property (nonatomic, assign) SAStorage_RecordIDType recordID;
@property (nonatomic, weak) SAStorage_Database *db;
@property (nonatomic, strong) NSString *tableName;
@end

@implementation SAStorage_Record

+ (id) recordInDatabase: (SAStorage_Database *) db andTable: (NSString *) tableName withRecordID: (SAStorage_RecordIDType) recordID {
	SAStorage_Record			*record = [[self alloc] init];
	
	record.db = db;
	record.tableName = tableName;
	record.recordID = recordID;

	return record;
}

//=============================================================================================================================
#pragma mark Actions
- (void) deleteRecord {
	[self.db deleteRecord: self];
}

- (void) populateBackingDictionaryFromDictionary: (NSDictionary *) dict {
	if (self.backingDictionary == nil) self.backingDictionary = [NSMutableDictionary dictionary];
	for (NSString *key in dict) {
		self.backingDictionary[key] = dict[key];
	}
}

//=============================================================================================================================
#pragma mark Properties
- (NSDictionary *) dictionaryRepresentation { return self.backingDictionary; }

- (void) setRecordHasChanges: (BOOL) recordHasChanges {
	_recordHasChanges = recordHasChanges;
	[self.db markRecord: self changed: recordHasChanges];
}

- (NSString *) uuid {
	if (self.recordID == SAStorage_RecordIDNone) {
		return nil;					//can't generate uuids for records with no ID
	}
		
	
	return [NSString stringWithFormat: @"%@://%@/%@/%u", SAStorage_RecordIDURLPrefix, self.db, self.tableName, self.recordID];
}


- (BOOL) matchesPredicate: (NSPredicate *) predicate {
	return [predicate evaluateWithObject: self];
}

- (NSDictionary *) dictionaryWithFields: (NSSet *) fields {
	NSMutableDictionary				*results = [NSMutableDictionary dictionary];
	
	for (NSString *key in fields) {
		id				value = results[key];
		
		if (value) results[key] = value;
	}
	return results;
}

//=============================================================================================================================
#pragma mark Maintenance
- (id) valueForKey: (NSString *) key {
	return [self.backingDictionary valueForKey: key];
}
- (void) setValue: (id) value forKey: (NSString *) key { [self.backingDictionary setValue: value forKey: key]; }

- (id) objectForKeyedSubscript: (id) key {
	return self.backingDictionary[key];
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	if (obj)
		self.backingDictionary[key] = obj;
	else
		[self.backingDictionary removeObjectForKey: key];
}


@end
