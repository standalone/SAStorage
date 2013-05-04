//
//  SAStorage_Database.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, SAStorage_Database_Type) {
	SAStorage_Database_any,
	SAStorage_Database_SQL,
	SAStorage_Database_JSON,
	SAStorage_Database_FS
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
@property (nonatomic) dispatch_queue_t completionQueue;

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema;

- (NSError *) deleteBackingStore;

//Fetching data
- (SAStorage_Query *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion;

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion;
- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion;

//Inserting data
- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion;

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