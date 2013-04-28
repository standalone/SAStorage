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


@end



