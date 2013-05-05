//
//  SAStorage_JSONDatabase.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SAStorage.h"

@interface SAStorage_DatabaseTests : SenTestCase

@property (nonatomic) SAStorage_Database_Type databaseType;

- (void) testDatabaseCreation;
- (void) testRecordCreation;
- (void) testRecordFetching;



@end
