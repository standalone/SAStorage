//
//  SAStorage_JSONTable.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/4/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Table.h"

@interface SAStorage_JSONTable : SAStorage_Table
@property (nonatomic, strong) NSMutableArray *records;

- (id) JSONDictionaryRepresentation;

@end

@interface SAStorage_Record (JSONDictionaryRepresentation)
- (NSDictionary *) JSONDictionaryRepresentation;
@end


