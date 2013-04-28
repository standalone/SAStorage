//
//  SAStorage_Query.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Query.h"

@implementation SAStorage_Query
+ (id) queryInTable: (NSString *) tableName withPredicate: (NSPredicate *) predicate {
	SAStorage_Query				*query = [[self alloc] init];
	query.predicate = predicate;
	query.tableName = tableName;
	return query;
}

+ (id) queryInTable: (NSString *) tableName withSQL: (NSString *) sql andArgs: (NSArray *) args {
	SAStorage_Query				*query = [[self alloc] init];
	query.sql = sql;
	query.arguments = args;
	query.tableName = tableName;
	return query;
}


@end
