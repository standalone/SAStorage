//
//  SAStorage_SchemaField.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaField.h"

@implementation SAStorage_SchemaField
+ (id) fieldWithDictionary: (NSDictionary *) dict {
	SAStorage_SchemaField			*field = [[self alloc] init];
	
	return field;
}
@end
