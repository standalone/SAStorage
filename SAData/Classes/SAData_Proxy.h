//
//  SAData_Proxy.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAData_Headers.h"

@class SAData_Database;

@interface SAData_Proxy : NSProxy

@property (nonatomic, weak) SAData_Database *database;
@property (nonatomic, strong) NSString *table;
@property (nonatomic) SAData_RecordIDType recordID;

@end
