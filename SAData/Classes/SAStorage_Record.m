//
//  SAStorage_Record.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Record.h"
#import "SAStorage_Database.h"

@interface SAStorage_Record ()
@end

@implementation SAStorage_Record

+ (id) recordInDatabase: (SAStorage_Database *) db andTable: (NSString *) tableName withRecordID: (SAStorage_RecordIDType) recordID {
	SAStorage_Record			*record = [[self alloc] init];
	
	record->_db = db;
	record->_tableName = tableName;
	record->_recordID = recordID;
	
	return record;
}

- (void) setRecordHasChanges: (BOOL) recordHasChanges {
	_recordHasChanges = recordHasChanges;
	[self.db markRecord: self changed: recordHasChanges];
}

- (NSString *) uuid {
	if (self.recordID == SAStorage_RecordIDNone) {
		return nil;					//can't generate uuids for records with no ID
	}
		
	
	return [NSString stringWithFormat: @"%@://%@/%@/%u", SAStorage_RecordIDURLPrefix, self.db, self.tableName, self.recordID];
}

@end
