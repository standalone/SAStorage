//
//  SAStorage_SchemaTable.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaTable.h"
#import "SAStorage_SchemaField.h"
#import "SAStorage_Schema.h"

@implementation SAStorage_SchemaTable
+ (id) tableWithDictionary: (NSDictionary *) dict {
	SAStorage_SchemaTable			*table = [[self alloc] init];
	
	table.name = dict[@"name"];
	table.fields = [NSMutableDictionary dictionary];
	if (dict[@"class"]) table.recordClass = NSClassFromString(dict[@"class"]);
	
	for (NSDictionary *fieldDict in dict[@"columns"]) {
		SAStorage_SchemaField			*field = [SAStorage_SchemaField fieldWithDictionary: fieldDict];
		
		if (field) table.fields[field.name] = field;
	}
	return table;
}

- (NSDictionary *) dictionaryRepresentation {
	NSMutableDictionary			*dict = @{
		@"name": self.name,
		@"fields": [[self.fields allValues] valueForKey: @"dictionaryRepresentation"]
	}.mutableCopy;
	
	if (self.recordClass) dict[@"class"] = NSStringFromClass(self.recordClass);
	return dict;
}

- (NSString *) description {
	return [NSString stringWithFormat: @"%@, fields: %@", self.name, self.fields];
}


//=============================================================================================================================
#pragma mark Maintenance
- (id) objectForKeyedSubscript: (id) key {
	return self.fields[key];
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	if (![obj isKindOfClass: [SAStorage_SchemaField class]]) return;
	
	if (obj)
		self.fields[key] = obj;
	else
		[self.fields removeObjectForKey: key];
}

- (NSUInteger) hash {
	NSUInteger				hash = self.name.hash;
	
	for (SAStorage_SchemaField *field in self.fields) { hash += field.hash; }
	return hash;
}

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *) state objects: (__unsafe_unretained id []) buffer count: (NSUInteger) len {
	return [self.fields.allValues countByEnumeratingWithState: state objects: buffer count: len];
}

//=============================================================================================================================
#pragma mark Upgrading
- (BOOL) canUpgradeFrom: (SAStorage_SchemaTable *) oldTable {
	for (SAStorage_SchemaField *oldField in oldTable.fields) {
		SAStorage_SchemaField		*newField = self.fields[oldField.name];
		
		if (newField == nil) continue;			//deleted a field
		if (newField.type != oldField.type) return NO;		//can't change the type of a field
	}
	return YES;
}

- (NSArray *) fieldsAddedComparedTo: (SAStorage_SchemaTable *) oldTable {
	NSMutableArray				*addedFields = [NSMutableArray array];
	
	for (NSString *fieldName in self.fields) {
		if (oldTable.fields[fieldName] == nil) [addedFields addObject: self.fields[fieldName]];
	}
	return addedFields;
}

- (NSArray *) fieldsRemovedComparedTo: (SAStorage_SchemaTable *) oldTable {
	NSMutableArray				*removedFields = [NSMutableArray array];
	
	for (NSString *fieldName in oldTable.fields) {
		if (self.fields[fieldName] == nil) [removedFields addObject: oldTable.fields[fieldName]];
	}
	return removedFields;
}

- (NSArray *) fieldsChangedComparedTo: (SAStorage_SchemaTable *) oldTable {
	NSMutableArray				*changedFields = [NSMutableArray array];
	
	for (NSString *fieldName in oldTable.fields) {
		if (oldTable.fields[fieldName] && [self.fields[fieldName] hash] != [oldTable.fields[fieldName] hash]) {
			[changedFields addObject: @{ @"old": oldTable.fields[fieldName], @"new": self.fields[fieldName] }];
		}
	}
	return changedFields;
}

- (NSArray *) fieldsAddedComparedToSchema: (SAStorage_Schema *) oldSchema { return [self fieldsAddedComparedTo: oldSchema[self.name]]; }
- (NSArray *) fieldsRemovedComparedToSchema: (SAStorage_Schema *) oldSchema { return [self fieldsRemovedComparedTo: oldSchema[self.name]]; }
- (NSArray *) fieldsChangedComparedToSchema: (SAStorage_Schema *) oldSchema { return [self fieldsChangedComparedTo: oldSchema[self.name]]; }
@end
