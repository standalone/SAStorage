//
//  SAStorage_SchemaTable.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaTable.h"
#import "SAStorage_SchemaField.h"

@implementation SAStorage_SchemaTable
+ (id) tableWithDictionary: (NSDictionary *) dict {
	SAStorage_SchemaTable			*table = [[self alloc] init];
	
	table.name = dict[@"name"];
	table.fields = [NSMutableDictionary dictionary];
	if (dict[@"class"]) table.objectClass = NSClassFromString(dict[@"class"]);
	
	for (NSDictionary *fieldDict in dict[@"columns"]) {
		SAStorage_SchemaField			*field = [SAStorage_SchemaField fieldWithDictionary: fieldDict];
		
		if (field) table.fields[field.name] = field;
	}
	return table;
}

- (NSDictionary *) dictionaryRepresentation {
	NSMutableDictionary			*dict = @{
		@"name": self.name,
		@"fields": [self.fields valueForKey: @"dictionaryRepresentation"]
	}.mutableCopy;
	
	if (self.objectClass) dict[@"class"] = NSStringFromClass(self.objectClass);
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

@end
