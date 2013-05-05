//
//  SAStorage_Table.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/4/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Table.h"

@interface SAStorage_Table ()
@property (nonatomic, weak) SAStorage_Database *db;
@end

@implementation SAStorage_Table
+ (id) tableInDatabase: (SAStorage_Database *) db {
	SAStorage_Table		*table = [[self alloc] init];
	
	table.db = db;
	return table;
}

- (void) addRecord: (SAStorage_Record *) record {
	
}

- (id) objectForKeyedSubscript: (id) key {
	return nil;
}

- (void) setObject: (id) obj forKeyedSubscript: (id) key {
	
}


@end
