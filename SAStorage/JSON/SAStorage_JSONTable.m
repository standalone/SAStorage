//
//  SAStorage_JSONTable.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/4/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_JSONTable.h"
#import "SAStorage.h"

@interface SAStorage_JSONTable ()
@end

@interface SAStorage_Record (JSONDictionaryRepresentation)
- (NSDictionary *) JSONDictionaryRepresentation;
@end


@implementation SAStorage_JSONTable


- (void) addRecord: (SAStorage_Record *) record {
	if (self.records == nil) self.records = [NSMutableArray array];
	[self.records addObject: record];
}

- (id) objectForKeyedSubscript: (id) key {
	SAStorage_RecordIDType			recordID = [key intValue];
	
	for (SAStorage_Record *record in self.records) {
		if (record.recordID == recordID) return record;
	}
	return nil;
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	
}

- (id) JSONDictionaryRepresentation {
	NSMutableArray				*array = [NSMutableArray arrayWithCapacity: self.records.count];
	
	for (SAStorage_Record *record in self.records) {
		[array addObject: record.JSONDictionaryRepresentation];
	}
	return array;
}

@end

@implementation SAStorage_Record (JSONDictionaryRepresentation)
- (NSDictionary *) JSONDictionaryRepresentation {
	NSMutableDictionary			*dict = [NSMutableDictionary dictionary];
	
	for (SAStorage_SchemaField *field in self.db.schema[self.tableName]) {
		id			value = self.backingDictionary[field.name];
		
		if (value == nil) continue;
		if (field.isRelationship) {
			dict[field.name] = @([value recordID]);
		} else {
			dict[field.name] = value;
		}
	}
	dict[RECORD_ID_FIELD_NAME] = @(self.recordID);
	return dict;
}
@end

