//
//  SAStorage.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage.h"

const SAStorage_RecordIDType		SAStorage_RecordIDNone = 0L;
const NSString						*SAStorage_RecordIDURLPrefix = @"sastorage";
const NSString						*SAStorage_ErrorDomain = @"SAStorage_ErrorDomain";

@implementation SAStorage

+ (NSString *) uuid {
	CFUUIDRef					uuid = CFUUIDCreate(NULL);
	NSString					*uuidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
	
	CFRelease(uuid);
	
	return uuidString;
}

@end
