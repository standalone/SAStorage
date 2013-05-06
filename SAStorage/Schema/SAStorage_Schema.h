//
//  SAStorage_Schema.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_Schema : NSObject
@property (nonatomic, strong) NSData *JSONRepresentation;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSMutableDictionary *tables;

+ (id) schemaWithJSONRepresentation: (NSData *) json;
+ (id) schemaWithContentsOfURL: (NSURL *) url;

- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) obj forKeyedSubscript: (id) key;

- (BOOL) canUpgradeFrom: (SAStorage_Schema *) schema;

- (NSArray *) tablesAddedComparedTo: (SAStorage_Schema *) oldSchema;			//returns an array of SAStorage_SchemaTable objects
- (NSArray *) tablesRemovedComparedTo: (SAStorage_Schema *) oldSchema;			//same as above
- (NSArray *) tablesChangedComparedTo: (SAStorage_Schema *) oldSchema;			//returns an array of dictionaries, each with an old and new SAStorage_SchemaTable

@end


