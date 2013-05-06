//
//  SAStorage_SchemaBundle.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/5/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaBundle.h"

@interface SAStorage_SchemaBundle ()
@property (nonatomic, strong) SAStorage_Schema *currentSchema;
@end


@implementation SAStorage_SchemaBundle

+ (id) schemaBundleWithContentsOfURL: (NSURL *) url {
	SAStorage_SchemaBundle			*bundle = [[self alloc] init];
	
	bundle.url = url;
	bundle.currentSchema = [SAStorage_Schema schemaWithContentsOfURL: url];
	return bundle;
	
}


@end
