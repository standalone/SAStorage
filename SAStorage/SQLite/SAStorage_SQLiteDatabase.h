//
//  SAStorage_SQLiteDatabase.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Database.h"

@interface SAStorage_SQLiteDatabase : SAStorage_Database

- (id) initWithURL: (NSURL *) url andSchema: (SAStorage_SchemaBundle *) schema;

@end
