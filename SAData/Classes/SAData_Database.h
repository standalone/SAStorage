//
//  SAData_Database.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, SAData_Database_Type) {
	SAData_Database_any,
	SAData_Database_SQL
};


@class SAData_Query, SAData_Schema;

typedef void (^SAData_QueryCallback)(NSArray *results, NSError *error);
typedef void (^SAData_QueryCountCallback)(NSUInteger count, NSError *error);


@interface SAData_Database : NSObject

+ (id) databaseWithURL: (NSURL *) url ofType: (SAData_Database_Type) type basedOn: (SAData_Schema *) schema;

- (void) recordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;
- (void) proxiesMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;
- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;

- (void) numberOfRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCountCallback) completion;




//inheritable instance methods & properties

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SAData_Schema *schema;

- (id) initWithURL: (NSURL *) url andSchema: (SAData_Schema *) schema;


@end
