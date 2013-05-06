//
//  SAStorage_SchemaTable.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAStorage_Schema;

@interface SAStorage_SchemaTable : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Class recordClass;
@property (nonatomic, strong) NSMutableDictionary *fields;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
+ (id) tableWithDictionary: (NSDictionary *) dict;


- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) obj forKeyedSubscript: (id) key;


- (BOOL) canUpgradeFrom: (SAStorage_SchemaTable *) oldTable;
- (NSArray *) fieldsAddedComparedTo: (SAStorage_SchemaTable *) oldTable;			//returns an array of SAStorage_SchemaField objects
- (NSArray *) fieldsRemovedComparedTo: (SAStorage_SchemaTable *) oldTable;			//same as above
- (NSArray *) fieldsChangedComparedTo: (SAStorage_SchemaTable *) oldTable;			//returns an array of dictionaries, each with an old and new SAStorage_SchemaField

- (NSArray *) fieldsAddedComparedToSchema: (SAStorage_Schema *) oldSchema;			//returns an array of SAStorage_SchemaField objects
- (NSArray *) fieldsRemovedComparedToSchema: (SAStorage_Schema *) oldSchema;			//same as above
- (NSArray *) fieldsChangedComparedToSchema: (SAStorage_Schema *) oldSchema;			//returns an array of dictionaries, each with an old and new SAStorage_SchemaField

@end
