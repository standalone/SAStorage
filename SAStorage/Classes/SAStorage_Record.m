//
//  SAStorage_Record.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Record.h"
#import "SAStorage_Database.h"
#import "SAStorage_Schema.h"
#import "SAStorage_SchemaTable.h"
#import "SAStorage_SchemaField.h"
#import "SAStorage_Error.h"


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
	
	SAStorage_SchemaTable				*table = self.db.schema[self.tableName];
	
	for (NSString *key in dict) {
		SAStorage_SchemaField				*field = table[key];
		
		if (field.isRelationship) {
			id			otherSide = nil;
			
			if (field.type == SAStorage_SchemaField_RelationshipOneToOne) {
				otherSide = self.db[field.relatedTo][dict[key]];
				if (otherSide) self[key] = otherSide;
			}
		} else
			self.backingDictionary[key] = dict[key];
	}
}

- (NSString *) description {
	NSMutableString				*string = [NSMutableString stringWithFormat: @"<%@: 0x%X, %@, %@>\n", NSStringFromClass([self class]), (int) self, self.tableName, self.db];
	
	for (NSString *key in self.backingDictionary) {
		id			value = self.backingDictionary[key];
		
		if ([value isKindOfClass: [SAStorage_Record class]]) {
			[string appendFormat: @"%@:  <%@/%d>\n", key, [value tableName], [value recordID]];
		} else
			[string appendFormat: @"%@:  %@\n", key, value];
	}
	return string;
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
	if ([key isEqual: @"recordID"]) return @(self.recordID);
	return [self.backingDictionary valueForKey: key];
}

- (void) setValue: (id) value forKey: (NSString *) key {
	SAStorage_SchemaField				*field = self.db.schema[self.tableName][key];
	id									existing = self[key];

	if (value == nil && existing == nil) return;
	if ([value isEqual: existing]) return;
	
	if (self.db.validateSchemaFields) {
		if (field == nil) {
			[self.db.errors handleFatal: NO error: SAStorage_Error_FieldNotPresentInTable onObject: self userInfo: @{ @"field": key }];
			return;
		}

		if (![field valueIsProperType: value]) {
			[self.db.errors handleFatal: NO error: SAStorage_Error_IncorrectDataType onObject: self userInfo: @{ @"field": key, @"value": value } ];
			return;
		}

		if (field.isRelationship) {
			if ((field.type == SAStorage_SchemaField_RelationshipOneToOne || field.type == SAStorage_SchemaField_RelationshipOneToOne) && (![value isKindOfClass: [SAStorage_Record class]] || ![field.relatedTo isEqual: [value tableName]])) {
				[self.db.errors handleFatal: NO error: SAStorage_Error_IncorrectDataType onObject: self userInfo: @{ @"field": key, @"value": value } ];
				return;
			}
			
			if ((field.type == SAStorage_SchemaField_RelationshipOneToMany || field.type == SAStorage_SchemaField_RelationshipManyToMany) && ![value isKindOfClass: [NSSet class]]) {
				[self.db.errors handleFatal: NO error: SAStorage_Error_IncorrectDataType onObject: self userInfo: @{ @"field": key, @"value": value } ];
				return;
			}
		}
	}
	if (value) {
		[self.backingDictionary setValue: value forKey: key];
		if (field.isRelationship) {
			[existing removeRelationship: self forField: field.relatedBy];			//clear the existing relationship's other side
			[value addRelationship: self forField: field.relatedBy];
		}
	} else {
		[self.backingDictionary removeObjectForKey: key];
		if (field.isRelationship) existing[field.relatedBy] = nil;		//clear the existing relationship's other side
	}
}

- (void) removeRelationship: (id) otherSide forField: (NSString *) fieldName {
	
}

- (void) addRelationship: (id) otherSide forField: (NSString *) fieldName {
	
}

- (id) objectForKeyedSubscript: (id) key {
	return self.backingDictionary[key];
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	[self setValue: obj forKey: key];
}


@end
