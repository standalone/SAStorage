//
//  SAStorage_Record.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_Tools.h"

@class SAStorage_Database;


#define RECORD_ID_FIELD_NAME			@"id"

@interface SAStorage_Record : NSObject

@property (nonatomic, readonly) SAStorage_RecordIDType recordID;
@property (nonatomic, readonly) SAStorage_Database *db;
@property (nonatomic, readonly) NSString *tableName;
@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic, strong) NSMutableDictionary *backingDictionary;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

@property (nonatomic) BOOL recordHasChanges;

+ (id) recordInDatabase: (SAStorage_Database *) db andTable: (NSString *) tableName withRecordID: (SAStorage_RecordIDType) recordID;

- (void) populateBackingDictionaryFromDictionary: (NSDictionary *) dict;
- (BOOL) matchesPredicate: (NSPredicate *) predicate;
- (NSDictionary *) dictionaryWithFields: (NSSet *) fields;

- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) obj forKeyedSubscript: (id) key;

@end
