//
//  SAData_Database.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAData_Query, SAData_Scheme;

typedef void (^SAData_QueryCallback)(NSArray *results, NSError *error);
typedef void (^SAData_QueryCountCallback)(NSUInteger count, NSError *error);


@interface SAData_Database : NSObject

+ (id) databaseWithURL: (NSURL *) url basedOn: (SAData_Scheme *) schema;

- (void) recordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;
- (void) proxiesMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;
- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;

- (void) numberOfRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCountCallback) completion;

@end
