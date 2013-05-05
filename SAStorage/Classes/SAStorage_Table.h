//
//  SAStorage_Table.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/4/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage.h"

@interface SAStorage_Table : NSObject

+ (id) tableInDatabase: (SAStorage_Database *) db;

- (void) addRecord: (SAStorage_Record *) record;

- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) obj forKeyedSubscript: (id) key;

@end
