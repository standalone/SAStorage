//
//  SAStorage_Query.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_Query : NSObject

@property (nonatomic) BOOL alwaysFetchRecords;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) NSArray *arguments;			//arguments for the sql statement
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSArray *sortedBy;			//array of sort descriptors

+ (id) queryInTable: (NSString *) tableName withPredicate: (NSPredicate *) predicate;
+ (id) queryInTable: (NSString *) tableName withSQL: (NSString *) sql andArgs: (NSArray *) args;

@end
