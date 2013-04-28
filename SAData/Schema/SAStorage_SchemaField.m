//
//  SAStorage_SchemaField.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaField.h"

@implementation SAStorage_SchemaField
+ (id) fieldWithDictionary: (NSDictionary *) dict {
	SAStorage_SchemaField			*field = [[self alloc] init];
	
	field.name = dict[@"name"];
	field.type = [self stringToFieldType: dict[@"type"]];
	field.relatedTo = dict[@"relatedTo"];
	field.relatedBy = dict[@"relatedBy"];
	field.sortedOn = [dict[@"sorted"] boolValue];
	
	return field;
}

- (NSString *) description {
	if (self.isRelationship) {
		return [NSString stringWithFormat: @"%@: %@ to %@.%@", self.name, [SAStorage_SchemaField fieldTypeToString: self.type], self.relatedTo, self.relatedBy];
	}
	return [NSString stringWithFormat: @"%@: %@", self.name, [SAStorage_SchemaField fieldTypeToString: self.type]];
}

- (NSDictionary *) dictionaryRepresentation {
	if (self.isRelationship)
		return @{
			@"name": self.name,
			@"type": [SAStorage_SchemaField fieldTypeToString: self.type],
			@"relatedTo" : self.relatedTo,
			@"relatedBy" : self.relatedBy
	 };
	
	return @{
		@"name": self.name,
		@"type": [SAStorage_SchemaField fieldTypeToString: self.type],
	  };
}

- (BOOL) isRelationship { return self.type >= SAStorage_SchemaField_RelationshipOneToOne; }

+ (SAStorage_SchemaField_Type) stringToFieldType: (NSString *) string {
	if ([string isEqual: @"integer"]) return SAStorage_SchemaField_Integer;
	if ([string isEqual: @"float"]) return SAStorage_SchemaField_Float;
	if ([string isEqual: @"double"]) return SAStorage_SchemaField_Double;
	if ([string isEqual: @"boolean"]) return SAStorage_SchemaField_Boolean;
	if ([string isEqual: @"string"]) return SAStorage_SchemaField_String;
	if ([string isEqual: @"date"]) return SAStorage_SchemaField_Date;
	if ([string isEqual: @"blob"]) return SAStorage_SchemaField_Blob;
	if ([string isEqual: @"one-to-one"]) return SAStorage_SchemaField_RelationshipOneToOne;
	if ([string isEqual: @"one-to-many"]) return SAStorage_SchemaField_RelationshipOneToMany;
	if ([string isEqual: @"many-to-one"]) return SAStorage_SchemaField_RelationshipManyToOne;
	if ([string isEqual: @"many-to-many"]) return SAStorage_SchemaField_RelationshipManyToMany;
	return SAStorage_SchemaField_None;
}

+ (NSString *) fieldTypeToString: (SAStorage_SchemaField_Type) type {
	static NSArray			*names = nil;
	
	if (names == nil) names = @[
		@"",
		@"integer",
		@"float",
		@"double",
		@"boolean",
		@"string",
		@"date",
		@"blob",
		@"one-to-one",
		@"one-to-many",
		@"many-to-one",
		@"many-to-many"
	];
	
	return names[type];
}
@end
