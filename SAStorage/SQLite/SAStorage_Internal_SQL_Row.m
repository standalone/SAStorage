//
//  SAStorage_Internal_SQL_Row.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/30/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Internal_SQL_Row.h"
#import "SAStorage_Internal_SQL_ResultSet.h"

@interface SAStorage_Internal_SQL_Row ()

@property (nonatomic, strong) NSMutableArray *columnData;

@end

@implementation SAStorage_Internal_SQL_Row

- (id)init {
    
    self = [super init];
    if (self) {
        self.columnData = [NSMutableArray array];
    }
    
    return self;
    
}

- (NSInteger)columnIndexForName:(NSString*)columnName {
	return [self.resultSet.columnNames indexOfObject:columnName];
}

- (NSInteger)intForColumn:(NSString*)columnName {
    NSInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex < 0 || columnIndex == NSNotFound) return 0;
    return [[self.columnData objectAtIndex:columnIndex] intValue];
}

- (NSInteger)intForColumnIndex: (NSInteger)columnIndex {
    return [[self.columnData objectAtIndex:columnIndex] intValue];
}

- (long)longForColumn:(NSString*)columnName {
    NSInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex < 0 || columnIndex == NSNotFound) return 0;
    return [[self.columnData objectAtIndex:columnIndex] longValue];
}

- (long)longForColumnIndex: (NSInteger)columnIndex {
    return [[self.columnData objectAtIndex:columnIndex] longValue];
}

- (BOOL)boolForColumn:(NSString*)columnName {
    return ([self intForColumn:columnName] != 0);
}

- (BOOL)boolForColumnIndex: (NSInteger)columnIndex {
    return ([self intForColumnIndex:columnIndex] != 0);
}

- (double)doubleForColumn:(NSString*)columnName {
    NSInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex < 0 || columnIndex == NSNotFound) return 0;
    return [[self.columnData objectAtIndex:columnIndex] doubleValue];
}

- (double)doubleForColumnIndex:(NSInteger)columnIndex {
    return [[self.columnData objectAtIndex:columnIndex] doubleValue];
}

- (NSString*) stringForColumn:(NSString*)columnName {
    NSInteger columnIndex = [self columnIndexForName:columnName];
	if(columnIndex < 0 || columnIndex == NSNotFound) return @"";
    return [self.columnData objectAtIndex:columnIndex];
}

- (NSString*)stringForColumnIndex: (NSInteger)columnIndex {
    return [self.columnData objectAtIndex:columnIndex];
}

- (NSData*)dataForColumn:(NSString*)columnName {
	NSInteger columnIndex = [self columnIndexForName:columnName];
	if (columnIndex < 0 || columnIndex == NSNotFound) return nil;
	return [self.columnData objectAtIndex:columnIndex];
}

- (NSData*)dataForColumnIndex: (NSInteger)columnIndex {
	return [self.columnData objectAtIndex:columnIndex];
}

- (NSDate*)dateForColumn:(NSString*)columnName {
    NSInteger columnIndex = [self columnIndexForName:columnName];
    if(columnIndex == -1) return nil;
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIndex]];
}

- (NSDate*)dateForColumnIndex: (NSInteger)columnIndex {
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIndex]];
}

@end
