//
//  SAStorage_Query.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Query.h"

@implementation SAStorage_Query
+ (id) queryWithPredicate: (NSPredicate *) predicate {
	SAStorage_Query				*query = [[self alloc] init];
	query.predicate = predicate;
	return query;
}

+ (id) queryWithSQL: (NSString *) sql andArgs: (NSArray *) args {
	SAStorage_Query				*query = [[self alloc] init];
	query.sql = sql;
	query.arguments = args;
	return query;
}


@end
