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
	table.fields = [NSMutableArray array];
	
	for (NSDictionary *fieldDict in dict[@"fields"]) {
		SAStorage_SchemaField			*field = [SAStorage_SchemaField fieldWithDictionary: fieldDict];
		
		if (field) [table.fields addObject: field];
	}
	return table;
}
@end
