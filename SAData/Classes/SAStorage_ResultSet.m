//
//  SAStorage_ResultSet.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/30/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_ResultSet.h"

@interface SAStorage_ResultSet ()
@property (nonatomic, strong) NSArray *internalRecords;
@end

@implementation SAStorage_ResultSet
+ (id) resultSetWithError: (NSError *) error {
	if (error == nil) return nil;
	
	SAStorage_ResultSet			*results = [[self alloc] init];
	
	results->_error = error;
	return results;
}

+ (id) resultSetWithRecords: (NSArray *) records {
	SAStorage_ResultSet			*results = [[self alloc] init];
	
	results.internalRecords = records;
	return results;
}

//=============================================================================================================================
#pragma mark Fast Enumeration and Array accessors
- (void) setObject: (id) obj atIndexedSubscript: (NSUInteger) idx {
	//don't do anything by default; probably never will
}

- (id) objectAtIndexedSubscript: (NSUInteger) idx {
	if (idx >= self.internalRecords.count) return nil;
	return self.internalRecords[idx];
}

- (NSUInteger) count { return self.internalRecords.count; }

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *) state objects: (__unsafe_unretained id []) buffer count: (NSUInteger) len {
	return [self.internalRecords countByEnumeratingWithState: state objects: buffer count: len];
}
@end
