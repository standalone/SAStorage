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

- (NSInteger)intForColumn:(NSString *)columnName;
- (NSInteger)intForColumnIndex:(NSInteger)columnIdx;

- (long)longForColumn:(NSString *)columnName;
- (long)longForColumnIndex:(NSInteger)columnIdx;

- (BOOL)boolForColumn:(NSString *)columnName;
- (BOOL)boolForColumnIndex:(NSInteger)columnIdx;

- (double)doubleForColumn:(NSString *)columnName;
- (double)doubleForColumnIndex:(NSInteger)columnIdx;

- (NSString*)stringForColumn:(NSString *)columnName;
- (NSString*)stringForColumnIndex:(NSInteger)columnIdx;

- (NSData *)dataForColumn:(NSString *)columnName;
- (NSData *)dataForColumnIndex:(NSInteger)columnIndex;

- (NSDate *)dateForColumn:(NSString *)columnName;
- (NSDate *)dateForColumnIndex:(NSInteger)columnIdx;

@property (nonatomic, weak) SAStorage_Internal_SQL_ResultSet *resultSet;
@property (nonatomic, readonly) NSMutableArray *columnData;

@end
