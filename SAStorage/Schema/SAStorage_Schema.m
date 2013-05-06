//
//  SAStorage_Schema.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Schema.h"
#import "SAStorage_SchemaTable.h"

@implementation SAStorage_Schema

+ (id) schemaWithJSONRepresentation: (NSData *) json {
	SAStorage_Schema		*schema = [[self alloc] init];
	
	schema.JSONRepresentation = json;
	return schema;
}

+ (id) schemaWithContentsOfURL: (NSURL *) url {
	return [self schemaWithJSONRepresentation: [NSData dataWithContentsOfURL: url]];
}



//=============================================================================================================================
#pragma mark Properties

- (void) setJSONRepresentation: (NSData *) JSONRepresentation {
	NSError					*error;
	NSDictionary			*dictionary = [NSJSONSerialization JSONObjectWithData: JSONRepresentation options: 0 error: &error];
	
	if (dictionary == nil) {
		NSLog(@"Error while reading in Schema JSON: %@", error);
		return;
	}
	
	self.tables = [NSMutableDictionary dictionary];
	for (NSDictionary *tableDict in dictionary[@"tables"]) {
		SAStorage_SchemaTable			*table = [SAStorage_SchemaTable tableWithDictionary: tableDict];
		
		self.tables[table.name] = table;
	}	
}

- (NSDictionary *) dictionaryRepresentation {
	static NSArray			*sort = nil;
	
	if (sort == nil) sort = @[ [NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES] ];
	
	return @{ @"tables": [[self.tables.allValues sortedArrayUsingDescriptors: sort] valueForKey: @"dictionaryRepresentation"] };
}

- (NSData *) JSONRepresentation {
	NSDictionary			*dictionary = self.dictionaryRepresentation;
	NSError					*error = nil;
	NSData					*data = [NSJSONSerialization dataWithJSONObject: dictionary options: NSJSONWritingPrettyPrinted error: &error];
	
	if (error) NSLog(@"Error converting a schema to JSON: %@", error);
	return data;
}

- (NSString *) description {
	return [NSString stringWithFormat: @"%@", self.tables];
}


//=============================================================================================================================
#pragma mark Maintenance
- (id) objectForKeyedSubscript: (id) key {
	return self.tables[key];
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	if (![obj isKindOfClass: [SAStorage_SchemaTable class]]) return;
	
	if (obj)
		self.tables[key] = obj;
	else
		[self.tables removeObjectForKey: key];
}

- (NSUInteger) hash {
	NSUInteger				hash = 0L;
	
	for (SAStorage_SchemaTable *table in self.tables) { hash += table.hash; }
	return hash;
}

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *) state objects: (__unsafe_unretained id []) buffer count: (NSUInteger) len {
	return [self.tables.allValues countByEnumeratingWithState: state objects: buffer count: len];
}

//=============================================================================================================================
#pragma mark Upgrading
- (BOOL) canUpgradeFrom: (SAStorage_Schema *) oldSchema {
	for (SAStorage_SchemaTable *oldTable in oldSchema.tables) {
		SAStorage_SchemaTable		*newTable = self.tables[oldTable.name];
		
		if ([newTable canUpgradeFrom: oldTable]) return NO;
	}
	return YES;
}

- (NSArray *) tablesAddedComparedTo: (SAStorage_Schema *) oldSchema {
	NSMutableArray				*addedTables = [NSMutableArray array];
	
	for (NSString *tableName in self.tables) {
		if (oldSchema.tables[tableName] == nil) [addedTables addObject: self.tables[tableName]];
	}
	return addedTables;
}

- (NSArray *) tablesRemovedComparedTo: (SAStorage_Schema *) oldSchema {
	NSMutableArray				*removedTables = [NSMutableArray array];
	
	for (NSString *tableName in oldSchema.tables) {
		if (self.tables[tableName] == nil) [removedTables addObject: oldSchema.tables[tableName]];
	}
	return removedTables;
}

- (NSArray *) tablesChangedComparedTo: (SAStorage_Schema *) oldSchema {
	NSMutableArray				*changedTables = [NSMutableArray array];
	
	for (NSString *tableName in oldSchema.tables) {
		if (oldSchema.tables[tableName] && [self.tables[tableName] hash] != [oldSchema.tables[tableName] hash]) {
			[changedTables addObject: @{ @"old": oldSchema.tables[tableName], @"new": self.tables[tableName] }];
		}
	}
	return changedTables;
}

@end



