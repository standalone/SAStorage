//
//  SAStorage_JSONDatabase.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Database.h"

@interface SAStorage_JSONDatabase : SAStorage_Database
@property (nonatomic, strong) NSMutableDictionary *metadata;
@property (nonatomic, strong) NSMutableDictionary *tables;
@end
