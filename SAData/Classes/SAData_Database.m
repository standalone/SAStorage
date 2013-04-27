//
//  SAData_Database.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_Database.h"

typedef void (^SAData_QueryCallback)(NSArray *results, NSError *error);


@class SAData_Query;

@implementation SAData_Database

- (void) recordsMatchingQuery: (SAData_Query *) query completion: (SAData_QueryCallback) completion;


@end
