//
//  SAStorage_Proxy.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_Headers.h"

@class SAStorage_Database;

@interface SAStorage_Proxy : NSProxy

@property (nonatomic, weak) SAStorage_Database *database;
@property (nonatomic, strong) NSString *table;
@property (nonatomic) SAStorage_RecordIDType recordID;

@end
