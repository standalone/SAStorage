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
	SAStorage_Database_JSON
};


@class SAStorage_Query, SAStorage_Schema, SAStorage_Record, SAStorage_Proxy;

typedef void (^SAStorage_QueryCallback)(NSArray *results, NSError *error);
typedef void (^SAStorage_QueryCountCallback)(NSUInteger count, NSError *error);
typedef void (^SAStorage_RecordCallback)(SAStorage_Record *record, NSError *error);
typedef void (^SAStorage_ErrorCallback)(NSError *error);


@interface SAStorage_Database : NSObject
@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic) BOOL dirty;

+ (id) databaseWithURL: (NSURL *) url ofType: (SAStorage_Database_Type) type basedOn: (SAStorage_Schema *) schema;


//Fetching data
- (void) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (void) proxiesMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion;
- (void) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion;

- (void) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion;
- (void) saveWithCompletion: (SAStorage_ErrorCallback) completion;

//Inserting data
- (void) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion;

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
