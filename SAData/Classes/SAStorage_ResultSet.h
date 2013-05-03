//
//  SAStorage_ResultSet.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/30/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_ResultSet : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSArray *records;

+ (id) resultSetWithRecords: (NSArray *) records;

- (void) setObject: (id) obj atIndexedSubscript: (NSUInteger) idx;
- (id) objectAtIndexedSubscript: (NSUInteger) idx;


@end
