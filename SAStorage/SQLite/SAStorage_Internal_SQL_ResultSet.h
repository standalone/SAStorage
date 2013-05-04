//
//  SAStorage_Internal_SQL_ResultSet.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SAStorage_ResultSet.h"

@interface SAStorage_Internal_SQL_ResultSet : SAStorage_ResultSet

@property (nonatomic, strong) NSMutableArray *columnTypes;
@property (nonatomic, strong) NSMutableArray *columnNames;
@property (nonatomic, strong) NSError *error;

+ (SAStorage_Internal_SQL_ResultSet *)resultSetWithBoundStatement:(sqlite3_stmt *)stmt;

@end
