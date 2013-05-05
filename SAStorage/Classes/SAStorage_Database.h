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
	SAStorage_Database_FS
};

typedef NS_ENUM(uint8_t, SAStorage_Database_Flags) {
	SAStorage_Database_readOnly,
};


@class SAStorage_Query, SAStorage_Schema, SAStorage_Record, SAStorage_Proxy, SAStorage_ResultSet;

typedef void (^SAStorage_QueryCallback)(SAStorage_ResultSet *results);
typedef void (^SAStorage_QueryCountCallback)(NSUInteger count, NSError *error);
typedef void (^SAStorage_RecordCallback)(SAStorage_Record *record, NSError *error);
typedef void (^SAStorage_ErrorCallback)(NSError *error);


@interface SAStorage_Database : NSObject
@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic) BOOL dirty;
@property (nonatomic) BOOL validateSchemaFields;			//may be set by the database automatically, can be forced for others
@property (nonatomic) BOOL readOnly;						//prevent saves
@property (nonatomic) dispatch_queue_t completionQueue;
@property (nonatomic, strong) SAStorage_ErrorManager *errors;

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema;
+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema flags: (SAStorage_Database_Flags) flags;

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
- (NSString *) metadataValueForKey: (NSString *) key;
- (void) setMetadataValue: (NSString *) value forKey: (NSString *) key;

//Maintenance
- (void) postInitSetup;

//inheritable instance methods & properties

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SAStorage_Schema *schema;
@property (nonatomic, strong) NSMutableSet *changedRecords;

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema;
- (SAStorage_Record *) resolveProxy: (SAStorage_Proxy *) proxy;


@end
