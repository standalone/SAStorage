//
//  SAStorage_SchemaTable.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_SchemaTable : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Class objectClass;
@property (nonatomic, strong) NSMutableDictionary *fields;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
+ (id) tableWithDictionary: (NSDictionary *) dict;


- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) obj forKeyedSubscript: (id) key;

@end
