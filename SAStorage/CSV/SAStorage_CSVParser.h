//
//  SAStorage_CSVParser.h
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAStorage_SchemaTable, SAStorage_Record;

@interface SAStorage_CSVParser : NSObject

+ (id) parserWithData: (NSData *) data;
+ (id) parserWithSchemaTable: (SAStorage_SchemaTable *) schema;

@property (nonatomic, strong) NSArray *schemaFields;
@property (nonatomic, strong) SAStorage_SchemaTable *schemaTable;
@property (nonatomic) char iterationSeparator, fieldSeparator, recordSeparator;

- (NSError *) beginParsing;
- (NSDictionary *) nextRecordWithError: (NSError **) error;

- (NSError *) beginWriting;
- (NSError *) writeRecord: (SAStorage_Record *) record;
- (NSData *) finishWriting;

@end
