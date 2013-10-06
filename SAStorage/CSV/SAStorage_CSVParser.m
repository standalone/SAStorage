//
//  SAStorage_CSVParser.m
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_CSVParser.h"
#import "SAStorage.h"
#import "SAStorage_CSVDatabase.h"

@interface NSDate (CSV)
+ (NSDate *) dateWithCSVString: (NSString *) string;
@end

@interface SAStorage_CSVParser ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableData *output;
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

+ (id) parserWithSchemaTable: (SAStorage_SchemaTable *) schema {
	SAStorage_CSVParser				*parser = [[self alloc] init];
	
	parser.schemaTable = schema;
	return parser;
}

//=============================================================================================================================
#pragma mark Writing
- (NSError *) beginWriting {
	char			quote = '"';
	self.output = [[NSMutableData alloc] init];
		
	if (self.schemaFields.count) {
		for (SAStorage_SchemaField *field in self.schemaFields) {
			[self.output appendBytes: &quote length: 1];
			[self.output appendBytes: field.name.UTF8String length: strlen(field.name.UTF8String)];
			if (field.type == SAStorage_SchemaField_Date) [self.output appendBytes: "/d" length: 2];
			if (field.type == SAStorage_SchemaField_Integer) [self.output appendBytes: "/i" length: 2];
			if (field.type == SAStorage_SchemaField_Float) [self.output appendBytes: "/f" length: 2];
			if (field.type == SAStorage_SchemaField_Boolean) [self.output appendBytes: "/b" length: 2];
			if (field.isMultiple) [self.output appendBytes: "/m" length: 2];
			
			[self.output appendBytes: &quote length: 1];
			[self.output appendBytes: &_fieldSeparator length: 1];
		}
		[self.output appendBytes: &_recordSeparator length: 1];
	}
	
	return nil;
}

- (NSError *) writeRecord: (SAStorage_Record *) record {
	char			quote = '"';
	
	for (SAStorage_SchemaField *field in self.schemaFields) {
		id					data = record[field.name];
		
		[self.output appendBytes: &quote length: 1];
		if (data == nil) {
			[self.output appendBytes: &quote length: 1];
			[self.output appendBytes: &_fieldSeparator length: 1];
			continue;
		}
		NSArray				*reps = [data isKindOfClass: [NSArray class]] ? data : @[ data ];
		NSString			*result;
		
		
		for (id subField in reps) {
			if (![subField isEqual: [NSNull null]]) switch (field.type) {
				case SAStorage_SchemaField_Date: {
					NSDateComponents		*components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate: subField];
					result = [NSString stringWithFormat: @"%02d/%02d/%02d", (UInt16) components.month, (UInt16) components.day, (UInt16) components.year];
					[self.output appendBytes: result.UTF8String length: strlen(result.UTF8String)];
				} break;
					
				case SAStorage_SchemaField_Integer:
					result = [subField stringValue];
					[self.output appendBytes: result.UTF8String length: strlen(result.UTF8String)];
					break;
					
				case SAStorage_SchemaField_Float:
					result = [subField stringValue];
					[self.output appendBytes: result.UTF8String length: strlen(result.UTF8String)];
					break;
					
				case SAStorage_SchemaField_Boolean:
					[self.output appendBytes: [subField boolValue] ? "Y" : "N" length: 1];
					break;
					
				default:
					result = subField;
					[self.output appendBytes: result.UTF8String length: strlen(result.UTF8String)];
					break;
			}
			if (field.isMultiple) [self.output appendBytes: &_iterationSeparator length: 1];
		}
		[self.output appendBytes: &quote length: 1];
		[self.output appendBytes: &_fieldSeparator length: 1];
	}
	[self.output appendBytes: &_recordSeparator length: 1];
	return nil;
}

- (NSData *) finishWriting {
	return self.output;
}

//=============================================================================================================================
#pragma mark Parsing
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
			return [NSDate dateWithCSVString: string];
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

//=============================================================================================================================
#pragma mark Properties
- (void) setSchemaTable: (SAStorage_SchemaTable *) schema {
	self.schemaFields = schema.fields.allValues;
}

- (SAStorage_SchemaTable *) schemaTable {
	NSMutableDictionary					*fields = [NSMutableDictionary dictionary];
	
	for (SAStorage_SchemaField *field in self.schemaFields) { fields[field.name] = field; }
	
	SAStorage_SchemaTable				*table = [SAStorage_SchemaTable tableWithDictionary: @{}];
	table.name = [SAStorage_CSVDatabase tableName];
	table.recordClass = [SAStorage_Record class];
	table.fields = fields;
	return table;
}

@end


@implementation NSDate (CSV)
+ (NSDate *) dateWithCSVString: (NSString *) string {
	NSArray			*components = [string componentsSeparatedByString: @"-"];
	if (components.count < 3) components = [string componentsSeparatedByString: @"/"];
	
	if (components.count == 3) {
		NSUInteger			month = [components[0] integerValue], day = [components[1] integerValue], year = [components[2] integerValue];
		
		if (month > 31) { NSUInteger			t = month; month = day; day = year; year = t; }
		if (month > 12) { NSUInteger			t = month; month = day; day = t; }
		if (month < 12 && day < 31) {
			NSDateComponents		*components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: [NSDate date]];
			
			components.second = 0;
			components.hour = 0;
			components.minute = 0;
			components.day = day;
			components.month = month;
			components.year = year;
			
			return [[NSCalendar currentCalendar] dateFromComponents: components];
		}
	}
	
	return [NSDate date];
}

@end