//
//  SAStorage_Internal_SQL_ResultSet.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Internal_SQL_ResultSet.h"
#import "SAStorage_Internal_SQL_Row.h"

@interface SAStorage_Internal_SQL_ResultSet ()

@property (nonatomic, strong) NSMutableArray *internalRows;

@end

@implementation SAStorage_Internal_SQL_ResultSet

#pragma mark NSFastEnumeration

- (SAStorage_Internal_SQL_ResultSet *)init {
    self = [super init];
    if (self) {
        self.internalRows = [NSMutableArray array];
        self.columnNames  = [NSMutableArray array];
        self.columnTypes  = [NSMutableArray array];
    }
    return self;
}

+ (SAStorage_Internal_SQL_ResultSet *)resultSetWithBoundStatement:(sqlite3_stmt *)stmt {
    
    SAStorage_Internal_SQL_ResultSet *result = [[SAStorage_Internal_SQL_ResultSet alloc] init];
    
    int colCount = sqlite3_column_count(stmt);
    for (int i = 0; i < colCount; i++) {
        
        if(sqlite3_column_name(stmt,i) != NULL) {
			[result.columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(stmt,i)]];
		} else {
			[result.columnNames addObject:[NSString stringWithFormat:@"%d", i]];
		}
        
		if(sqlite3_column_decltype(stmt,i) != NULL) {
			[result.columnTypes addObject:[NSString stringWithUTF8String:sqlite3_column_decltype(stmt,i)]];
		} else {
			[result.columnTypes addObject:@""];
		}
        
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        SAStorage_Internal_SQL_Row *row = [[SAStorage_Internal_SQL_Row alloc] init];
        row.resultSet = result;
        for (int i = 0; i < colCount; i++) {
            if (sqlite3_column_type(stmt, i) == SQLITE_BLOB) {
				[row.columnData addObject:[NSData dataWithBytes:sqlite3_column_text(stmt,i) length:sqlite3_column_bytes(stmt,i)]];
			} else if (sqlite3_column_text(stmt,i) != NULL) {
				[row.columnData addObject:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(stmt,i)]];
			} else {
				[row.columnData addObject:@""];
			}
        }
        [result.internalRows addObject:row];
    }
    
    return result;
    
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    
    return [self.internalRows countByEnumeratingWithState:state objects:buffer count:len];
    
}

- (NSUInteger)count {
    
    return [self.internalRows count];

}

- (NSArray *)rows {
    
    return [NSArray arrayWithArray:self.internalRows];
    
}

@end
