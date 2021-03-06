//
//  SAStorage_Database.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_ErrorManager.h"

typedef NS_ENUM(uint8_t, SAStorage_Database_Type) {
	SAStorage_Database_any,
	SAStorage_Database_SQL,
	SAStorage_Database_JSON,
	SAStorage_Database_FS,
	SAStorage_Database_CSV
};

typedef NS_ENUM(uint8_t, SAStorage_Database_Flags) {
	SAStorage_Database_readOnly,
};

extern NSString *SCHEMA_HASH_KEY, *UUID_KEY;

@class SAStorage_Query, SAStorage_SchemaBundle, SAStorage_Record, SAStorage_Proxy, SAStorage_ResultSet, SAStorage_Schema;

typedef void (^SAStorage_QueryCallback)(SAStorage_ResultSet *results);
typedef void (^SAStorage_QueryCountCallback)(NSUInteger count, NSError *error);
typedef void (^SAStorage_RecordCallback)(SAStorage_Record *record, NSError *error);
typedef void (^SAStorage_ErrorCallback)(NSError *error);


@interface SAStorage_Database : NSObject
@property (nonatomic, readonly) NSString *uuid, *databaseTypeAsString, *prettyName;
@property (nonatomic) BOOL dirty;
@property (nonatomic) BOOL validateSchemaFields;			//may be set by the database automatically, can be forced for others
@property (nonatomic) BOOL readOnly;						//prevent saves
@property (nonatomic) dispatch_queue_t completionQueue;
@property (nonatomic, strong) SAStorage_ErrorManager *errors;
@property (nonatomic) SAStorage_Database_Type type;

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_SchemaBundle *) schema;
+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_SchemaBundle *) schema flags: (SAStorage_Database_Flags) flags;

- (NSError *) deleteBackingStore;

//Fetching data
- (SAStorage_Query *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion;

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion;
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion;

- (id) objectForKeyedSubscript: (id) key;					//returns a table with a given name
- (void) setObject: (id) obj forKeyedSubscript: (id) key;		//


//Inserting data
- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion;
- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType withFields: (NSDictionary *) fields completion: (SAStorage_RecordCallback) completion;

//Modifying Records
- (void) markRecord: (SAStorage_Record *) record changed: (BOOL) changed;
- (void) deleteRecord: (id) recordOrProxy;						//can pass either a record or a proxy

//metadata
- (NSString *) metadataValueForKey: (const NSString *) key;
- (void) setMetadataValue: (NSString *) value forKey: (const NSString *) key;

//Maintenance
- (void) postInitSetup;
- (NSError *) upgradeFromSchema: (SAStorage_Schema *) oldSchema;

//inheritable instance methods & properties

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SAStorage_Schema *schema;
@property (nonatomic, strong) SAStorage_SchemaBundle *schemaBundle;
@property (nonatomic, strong) NSMutableSet *changedRecords;

- (id) initWithType: (SAStorage_Database_Type) type URL: (NSURL *) url andSchema: (SAStorage_SchemaBundle *) schema;
- (SAStorage_Record *) resolveProxy: (SAStorage_Proxy *) proxy;

- (NSMutableDictionary *) createBaseMetadata;
@end
