//
//  SAData_SQLiteDatabase.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAData_SQLiteDatabase.h"
#import "SAData_Internal_SQL.h"


@interface SAData_SQLiteDatabase ()
@property (nonatomic, strong) SAData_Internal_SQL *sql;

@end

@implementation SAData_SQLiteDatabase

- (id) initWithURL: (NSURL *) url andSchema: (SAData_Schema *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		self.sql = [SAData_Internal_SQL databaseWithURL: url];
	}
	return self;
}


@end
