//
//  SAStorage_CSVParser.m
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_CSVParser.h"
#import "SAStorage.h"

@interface SAStorage_CSVParser ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic) char *raw;

@property (nonatomic) NSUInteger position;
@end

@implementation SAStorage_CSVParser

+ (id) parserWithData: (NSData *) data {
	SAStorage_CSVParser				*parser = [[self alloc] init];
	
	parser.data = data;
	parser.position = 0;
	
	return parser;
}

- (NSError *) beginParsing {
	self.raw = (char *) self.data.bytes;
	if (self.raw == nil) return [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_MissingData userInfo: nil];
	
	NSMutableArray		*fields = [NSMutableArray array];
	NSArray				*fieldLabels = [self readNextRow];
	NSDictionary		*typeKeys = @{ @"/d": @(SAStorage_SchemaField_Date),
									   @"/i": @(SAStorage_SchemaField_Integer),
									   @"/f": @(SAStorage_SchemaField_Float),
									   @"/b": @(SAStorage_SchemaField_Boolean),
									   @"/m": @(SAStorage_SchemaField_None),
									};
	
	for (NSString *field in fieldLabels) {
		BOOL							hasTypeKey = YES, isMultiple = NO;
		SAStorage_SchemaField_Type		fieldType = SAStorage_SchemaField_String;
		NSString						*label = field;
		
		while (hasTypeKey) {
			hasTypeKey = NO;
			for (NSString *typeKey in typeKeys) {
				if ([label hasSuffix: typeKey]) {
					hasTypeKey = YES;
					
					if ([typeKeys[typeKey] integerValue] == SAStorage_SchemaField_None) {
						isMultiple = YES;
					} else {
						fieldType = [typeKeys[typeKey] integerValue];
					}
					label = [label substringToIndex: label.length - typeKey.length];
				}
			}
		}
		
		SAStorage_SchemaField					*fieldSchema = [SAStorage_SchemaField fieldNamed: label ofType: fieldType];
		fieldSchema.isMultiple = isMultiple;
		[fields addObject: fieldSchema];
	}

	self.schemaFields = fields;
	return nil;
}

- (NSDictionary *) nextRecordWithError: (NSError **) error {
	NSArray					*fields = [self readNextRow];
	NSMutableDictionary		*record = [NSMutableDictionary dictionary];
	
	if (error) *error = nil;
	if (fields.count != self.schemaFields.count) {
		if (error) *error = [NSError errorWithDomain: SAStorage_ErrorDomain code: SAStorage_Error_MissingData userInfo: nil];
		return nil;
	}
	
	for (int i = 0; i < fields.count; i++) {
		SAStorage_SchemaField			*schema = self.schemaFields[i];
		
		if (schema.isMultiple) {
			NSArray						*subFields = [fields[i] componentsSeparatedByString: [NSString stringWithFormat: @"%c", self.iterationSeparator]];
			NSMutableArray				*values = [NSMutableArray array];
			
			for (NSString *subField in subFields) {
				[values addObject: [self convertString: subField forFieldType: schema.type] ?: [NSNull null]];
			}
			record[schema.name] = values;
		} else {
			id				value = [self convertString: fields[i] forFieldType: schema.type];
			if (value) record[schema.name] = value;
		}
	}
	

	return record;
}

- (id) convertString: (NSString *) string forFieldType: (SAStorage_SchemaField_Type) type {
	switch (type) {
		case SAStorage_SchemaField_Integer:
			if (string.length == 0) return nil;
			return @([string integerValue]);
			
		case SAStorage_SchemaField_Float:
		case SAStorage_SchemaField_Double:
			if (string.length == 0) return nil;
			return @([string floatValue]);
			
		case SAStorage_SchemaField_Boolean:
			if (string.length == 0) return nil;
			return @([string boolValue]);
			
		case SAStorage_SchemaField_Date: {
			if (string.length == 0) return nil;
			return [NSDate date];
		}
			
		default:
			return string;
	}
}


- (NSArray *) readNextRow {
	NSMutableArray					*fields = [NSMutableArray array];
	NSUInteger						position = self.position, fieldStart = self.position, length = self.data.length, lastFieldEnd = -1;
	char							*raw = self.raw;
	BOOL							inField = 0, inQuotes = NO;
	NSStringEncoding				encoding = NSUTF8StringEncoding;
	
	while (position < length) {
		char				chr = raw[position];
		
		if (chr == '"') {
			if (inField && (position == 0 || raw[position - 1] != '\\')) {
				[fields addObject: [[NSString alloc] initWithBytes: &raw[fieldStart] length: position - fieldStart encoding: encoding] ?: @""];
				inField = NO;
				inQuotes = NO;
			} else if (!inField) {
				inQuotes = YES;
				lastFieldEnd = position;
				fieldStart = position + 1;
				inField = YES;
			}
		} else if (chr == self.fieldSeparator && !inQuotes) {
			char					prev = position ? raw[position - 1] : self.fieldSeparator;
			
			if (prev == self.fieldSeparator) {
				if (inField) [fields addObject: [[NSString alloc] initWithBytes: &raw[fieldStart] length: position - fieldStart encoding: encoding] ?: @""];
				inField = YES;
			} else if (prev != '"') {
				if (inField) [fields addObject: [[NSString alloc] initWithBytes: &raw[fieldStart] length: position - fieldStart encoding: encoding] ?: @""];
				inField = YES;
			}
			
		} else if (chr == self.recordSeparator && !inQuotes) {
			if (inField) [fields addObject: [[NSString alloc] initWithBytes: &raw[fieldStart] length: position - fieldStart encoding: encoding] ?: @""];
			position++;
			break;
		} else if (!inField) {
			fieldStart = position + 1;
			inField = YES;
		}
		position++;
	}
	self.position = position;
	return fields;
}

@end
