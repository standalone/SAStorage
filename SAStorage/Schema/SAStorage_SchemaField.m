//
//  SAStorage_SchemaField.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaField.h"
#import "SAStorage_Record.h"

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

+ (id) fieldNamed: (NSString *) name ofType: (SAStorage_SchemaField_Type) type {
	SAStorage_SchemaField			*field = [[self alloc] init];
	
	field.name = name;
	field.type = type;
	return field;
}

- (NSUInteger) hash { return self.name.hash + self.type * 1024 + self.relatedBy.hash + self.relatedTo.hash + self.sortedOn * 24; }

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

- (BOOL) valueIsProperType: (id) value {
	if (value == nil) return YES;
	
	switch (self.type) {
		case SAStorage_SchemaField_None:			return NO;
		case SAStorage_SchemaField_Integer:			return [value isKindOfClass: [NSNumber class]];
		case SAStorage_SchemaField_Float:			return [value isKindOfClass: [NSNumber class]];
		case SAStorage_SchemaField_Double:			return [value isKindOfClass: [NSNumber class]];
		case SAStorage_SchemaField_Boolean:			return [value isKindOfClass: [NSNumber class]];
		case SAStorage_SchemaField_String:			return [value isKindOfClass: [NSString class]];
		case SAStorage_SchemaField_Date:			return [value isKindOfClass: [NSDate class]];
		case SAStorage_SchemaField_Blob:			return [value isKindOfClass: [NSData class]];
		case SAStorage_SchemaField_RelationshipOneToOne: 			return [value isKindOfClass: [SAStorage_Record class]];
		case SAStorage_SchemaField_RelationshipOneToMany: 			return [value isKindOfClass: [NSSet class]];
		case SAStorage_SchemaField_RelationshipManyToOne: 			return [value isKindOfClass: [SAStorage_Record class]];
		case SAStorage_SchemaField_RelationshipManyToMany: 			return [value isKindOfClass: [NSSet class]];
			break;
	}
	return NO;
}

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
