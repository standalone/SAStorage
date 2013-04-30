//
//  SAStorage_ResultSet.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/30/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_ResultSet.h"

@interface SAStorage_ResultSet ()
@property (nonatomic, strong) NSArray *internalRecords;
@end

@implementation SAStorage_ResultSet

+ (id) resultSetWithRecords: (NSArray *) records {
	SAStorage_ResultSet			*results = [[self alloc] init];
	
	results.internalRecords = records;
	return results;
}

@end
