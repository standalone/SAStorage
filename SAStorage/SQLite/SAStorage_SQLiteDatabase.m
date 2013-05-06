//
//  SAStorage_SQLiteDatabase.m
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SQLiteDatabase.h"
#import "SAStorage_Internal_SQL_Database.h"
#import "SAStorage_Internal_SQL_ResultSet.h"
#import "SAStorage_Internal_SQL_Row.h"
#import "SAStorage_Query.h"

@interface SAStorage_SQLiteDatabase ()
@property (nonatomic, strong) SAStorage_Internal_SQL_Database *sqlDB;

@end

@implementation SAStorage_SQLiteDatabase

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_SchemaBundle *) schema {
	if ((self = [super initWithURL: url andSchema: schema])) {
		self.sqlDB = [SAStorage_Internal_SQL_Database databaseWithURL: url];
		[self postInitSetup];
        NSError *error;
        [self.sqlDB openWithError:&error];
        if (error) {
            NSLog(@"Error opening SQL store: %@", error);
        }
	}
	return self;
}

//Fetching data
- (SAStorage_ResultSet *) recordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {

    SAStorage_QueryCallback completionCopy = [completion copy];
    [self.sqlDB executeQueryWithSQL:query.sql parameters:query.arguments completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        resultSet.error = error;
        completionCopy(resultSet);
    }];
    return nil;
}

- (SAStorage_Query *) fields: (NSSet *) fields fromRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCallback) completion {

    NSString *theQuery = [query.sql copy];
    if ([theQuery rangeOfString:@"*"].location != NSNotFound) {
        NSMutableString *mutableQuery = [NSMutableString string];
        NSArray *queryArray = [theQuery componentsSeparatedByString:@"*"];
        if ([queryArray count] == 3) {
            [mutableQuery appendFormat:@" (%@", queryArray[0]];
            NSUInteger i = 0, count = [fields count];
            for (NSString *field in fields) {
                [mutableQuery appendFormat:@"%@,", field];
                if (i < count - 1) [mutableQuery appendFormat:@", "];
                i++;
            }
            [mutableQuery appendFormat:@") %@", queryArray[2]];
            theQuery = [NSString stringWithString:mutableQuery];
        }
    }
    
    SAStorage_QueryCallback completionCopy = [completion copy];
    [self.sqlDB executeQueryWithSQL:theQuery parameters:query.arguments completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        resultSet.error = error;
        completionCopy(resultSet);
    }];
    
    return nil;

}

- (SAStorage_Record *) anyRecordMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_RecordCallback) completion {
    
    SAStorage_RecordCallback completionCopy = [completion copy];
    [self.sqlDB executeQueryWithSQL:query.sql parameters:query.arguments completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        SAStorage_Record *record = (resultSet.count > 0) ? resultSet.records[0] : nil;
        completionCopy(record, error);
    }];

    return nil;
}

- (NSUInteger) numberOfRecordsMatchingQuery: (SAStorage_Query *) query completion: (SAStorage_QueryCountCallback) completion {

    SAStorage_QueryCountCallback completionCopy = [completion copy];
    [self.sqlDB executeQueryWithSQL:query.sql parameters:query.arguments completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        completionCopy(resultSet.count, error);
    }];
    
    return 0;
}

- (NSError *) saveWithCompletion: (SAStorage_ErrorCallback) completion {

    return nil;
    
}

//Inserting data
- (SAStorage_Record *) insertNewRecordOfType: (NSString *) recordType completion: (SAStorage_RecordCallback) completion {

    return nil;
    
}

//Modifying Records
- (void) markRecord: (SAStorage_Record *) record changed: (BOOL) changed{

    
}

- (void) deleteRecord: (id) recordOrProxy {

    
}						

//metadata
- (NSString *) metadataValueForKey: (NSString *) key {
//create table if not exists %@ (id INTEGER PRIMARY KEY, key TEXT, data TEXT)
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = ?", kSADataSQLiteMetadataTableName];
    NSArray *params = @[key];
    __block NSString *metadataValue;
    [self.sqlDB executeQueryWithSQL:sql parameters:params completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        if (resultSet.count > 0) {
            SAStorage_Internal_SQL_Row *row = [resultSet.records objectAtIndex:0];
            metadataValue = [row stringForColumn:@"data"];
        }
        [lock unlock];
    }];
    return metadataValue;
    
}

- (void) setMetadataValue: (NSString *) value forKey: (NSString *) key {
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ values(NULL, ?, ?)", kSADataSQLiteMetadataTableName];
    NSArray *params = @[key, value];
    [self.sqlDB executeQueryWithSQL:sql parameters:params completionBlock:^(NSError *error, SAStorage_Internal_SQL_ResultSet *resultSet) {
        
        if (error) {
            NSLog(@"[SQLite] Error saving metadata.");
        }
        
    }];

}



@end
