//
//  SAStorage_RecordCache.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_RecordCache.h"
#import "SAStorage_Record.h"

@interface SAStorage_RecordCache ()
@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) NSPointerArray *pointerArray;
@end

@implementation SAStorage_RecordCache

- (id) init {
	if ((self = [super init])) {
		if (NSClassFromString(@"NSMapTable")) {
			self.mapTable = [NSMapTable weakToWeakObjectsMapTable];
		} else
			self.pointerArray = [NSPointerArray weakObjectsPointerArray];
	}
	return self;
}

- (void) cacheRecord: (SAStorage_Record *) record {
	if (self.mapTable) {
		[self.mapTable setObject: record forKey: @(record.recordID)];
	} else {
		if (self.pointerArray.count <= record.recordID) {
			self.pointerArray.count = record.recordID + 1;
		}
		
		[self.pointerArray insertPointer: (void *) record atIndex: record.recordID];
	}
}

- (void) clearRecord: (SAStorage_Record *) record {
	if (self.mapTable) {
		[self.mapTable removeObjectForKey: @(record.recordID)];
	} else {
		if (self.pointerArray.count <= record.recordID) return;
		[self.pointerArray insertPointer: NULL atIndex: record.recordID];
	}
}

- (SAStorage_Record *) recordWithID: (SAStorage_RecordIDType) recordID {
	if (self.mapTable) {
		return [self.mapTable objectForKey: @(recordID)];
	}
	
	if (recordID < self.pointerArray.count) return [self.pointerArray pointerAtIndex: recordID];
	return nil;
}


@end
