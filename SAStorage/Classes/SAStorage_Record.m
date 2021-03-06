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
			
			if (field.type == SAStorage_SchemaField_RelationshipOneToOne || field.type == SAStorage_SchemaField_RelationshipManyToOne) {
				otherSide = self.db[field.relatedTo][dict[key]];
				if (otherSide) self[key] = otherSide;
			} else if (field.type == SAStorage_SchemaField_RelationshipOneToMany || field.type == SAStorage_SchemaField_RelationshipManyToMany) {
				for (NSNumber *recordID in dict[key]) {
					otherSide = self.db[field.relatedTo][recordID];
					[otherSide addRelatedRecord: self forField: field.relatedBy];
					if (otherSide) [self addRelatedRecord: otherSide forField: field.name];
				}
			}
		} else
			self.backingDictionary[key] = dict[key];
	}
}

- (NSString *) description {
	NSMutableString				*string = [NSMutableString stringWithFormat: @"<%@: 0x%X, %@, %@>\n", NSStringFromClass([self class]), (int) self, self.tableName, self.db];
	
	for (NSString *key in self.backingDictionary) {
		id			value = self.backingDictionary[key];
		
		if ([value isKindOfClass: [NSSet class]]) {
			id		contents = [value count] ? [value anyObject] : nil;
			
			if (contents)
				[string appendFormat: @"%@:  <%lu %@ records>\n", key, (unsigned long)[value count], [contents tableName]];
			else
				[string appendFormat: @"%@:  <empty>\n", key];
		} else if ([value isKindOfClass: [SAStorage_Record class]]) {
			[string appendFormat: @"%@:  {%@ (%lu)}\n", key, [value tableName], (unsigned long)[value recordID]];
		} else
			[string appendFormat: @"%@:  %@\n", key, value];
	}
	return string;
}

//=============================================================================================================================
#pragma mark Properties
- (NSDictionary *) dictionaryRepresentation { return self.backingDictionary; }

- (void) setRecordHasChanges: (BOOL) recordHasChanges {
	if (_recordHasChanges == recordHasChanges) return;
	
	_recordHasChanges = recordHasChanges;
	[self.db markRecord: self changed: recordHasChanges];
}

- (NSString *) uuid {
	if (self.recordID == SAStorage_RecordIDNone) {
		return nil;					//can't generate uuids for records with no ID
	}
		
	
	return [NSString stringWithFormat: @"%@://%@/%@/%lu", SAStorage_RecordIDURLPrefix, self.db, self.tableName, (unsigned long)self.recordID];
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

	if ([value isKindOfClass: [NSArray class]]) value = [NSSet setWithArray: value];
	
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
	
	if (field.isRelationship) {
		if ([existing isKindOfClass: [NSSet class]]) {
			[existing enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
				[obj removeRelatedRecord: self forField: field.relatedBy];			//clear the existing relationship's other side
			}];
		} else
			[existing removeRelatedRecord: self forField: field.relatedBy];			//clear the existing relationship's other side
	}

	if (value) {
		[self.backingDictionary setValue: value forKey: key];

		if (field.isRelationship) {
			if ([value isKindOfClass: [NSSet class]]) {
				[value enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
					[obj addRelatedRecord: self forField: field.relatedBy];
				}];
			} else
				[value addRelatedRecord: self forField: field.relatedBy];
		}
	} else {
		[self.backingDictionary removeObjectForKey: key];
		if (field.isRelationship) [self removeRelatedRecord: existing forField: key];		//clear the existing relationship's other side
	}
	
	self.recordHasChanges = YES;
}

- (void) removeRelatedRecord: (id) otherSide forField: (NSString *) fieldName {
	SAStorage_SchemaField				*field = self.db.schema[self.tableName][fieldName];
	
	if (field.type == SAStorage_SchemaField_RelationshipOneToOne || field.type == SAStorage_SchemaField_RelationshipManyToOne) {
		[self.backingDictionary removeObjectForKey: fieldName];
	} else if (field.type == SAStorage_SchemaField_RelationshipOneToMany || field.type == SAStorage_SchemaField_RelationshipManyToMany) {
		NSMutableSet				*existing = self.backingDictionary[fieldName];
		
		if (existing == nil) {
			return;
		} else if (![existing respondsToSelector: @selector(addObject:)]) {
			existing = [existing mutableCopy];
			self.backingDictionary[fieldName] = existing;
		}
		
		[existing removeObject: otherSide];
	}
}

- (void) addRelatedRecord: (id) otherSide forField: (NSString *) fieldName {
	SAStorage_SchemaField				*field = self.db.schema[self.tableName][fieldName];
	
	if (field.type == SAStorage_SchemaField_RelationshipOneToOne || field.type == SAStorage_SchemaField_RelationshipManyToOne) {
		if (otherSide)
			self.backingDictionary[fieldName] = otherSide;
		else
			[self.backingDictionary removeObjectForKey: fieldName];
	} else if (field.type == SAStorage_SchemaField_RelationshipOneToMany || field.type == SAStorage_SchemaField_RelationshipManyToMany) {
		NSMutableSet				*existing = self.backingDictionary[fieldName];
		
		if (existing == nil) {
			existing = [NSMutableSet set];
			self.backingDictionary[fieldName] = existing;
		} else if (![existing respondsToSelector: @selector(addObject:)]) {
			existing = [existing mutableCopy];
			self.backingDictionary[fieldName] = existing;
		}
		
		[existing addObject: otherSide];
	}
}

- (id) objectForKeyedSubscript: (id) key {
	return self.backingDictionary[key];
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	[self setValue: obj forKey: key];
}


@end
