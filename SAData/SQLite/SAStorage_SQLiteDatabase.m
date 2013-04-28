//
//  SAStorage_SQLiteDatabase.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SQLiteDatabase.h"
#import "SAStorage_Internal_SQL_Database.h"


@interface SAStorage_SQLiteDatabase ()
@property (nonatomic, strong) SAStorage_Internal_SQL_Database *sql;

@end

@implementation SAStorage_SQLiteDatabase

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_Schema *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		self.sql = [SAStorage_Internal_SQL_Database databaseWithURL: url];
	}
	return self;
}


@end
