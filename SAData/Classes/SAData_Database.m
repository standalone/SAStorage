//
//  SAData_Database.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_Database.h"




@implementation SAData_Database

+ (id) databaseWithURL: (NSURL *) url basedOn: (SAData_Scheme *) schema {
	SAData_Database				*db = [[self alloc] init];
	
	return db;
}

- (void) recordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
}

- (void) proxiesMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
}

- (void) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion {
	
	
}

- (void) numberOfRecordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCountCallback) completion {
	
}




@end
