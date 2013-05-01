//
//  SAStorage_RecordCache.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_Record.h"
#import "SAStorage_Tools.h"

@class SAStorage_Record;

@interface SAStorage_RecordCache : NSObject

- (void) cacheRecord: (SAStorage_Record *) record;
- (SAStorage_Record *) recordWithID: (SAStorage_RecordIDType) recordID;
- (void) clearRecord: (SAStorage_Record *) record;

@end
