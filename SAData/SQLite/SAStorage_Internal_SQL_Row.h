//
//  SAStorage_Internal_SQL_Row.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/30/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_Record.h"

@class SAStorage_Internal_SQL_ResultSet;

@interface SAStorage_Internal_SQL_Row : SAStorage_Record

- (int)intForColumn:(NSString *)columnName;
- (int)intForColumnIndex:(int)columnIdx;

- (long)longForColumn:(NSString *)columnName;
- (long)longForColumnIndex:(int)columnIdx;

- (BOOL)boolForColumn:(NSString *)columnName;
- (BOOL)boolForColumnIndex:(int)columnIdx;

- (double)doubleForColumn:(NSString *)columnName;
- (double)doubleForColumnIndex:(int)columnIdx;

- (NSString*)stringForColumn:(NSString *)columnName;
- (NSString*)stringForColumnIndex:(int)columnIdx;

- (NSData *)dataForColumn:(NSString *)columnName;
- (NSData *)dataForColumnIndex:(int)columnIndex;

- (NSDate *)dateForColumn:(NSString *)columnName;
- (NSDate *)dateForColumnIndex:(int)columnIdx;

@property (nonatomic, weak) SAStorage_Internal_SQL_ResultSet *resultSet;
@property (nonatomic, readonly) NSMutableArray *columnData;

@end
