//
//  SAStorage_SchemaBundle.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/5/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Schema.h"

@interface SAStorage_SchemaBundle : NSObject

@property (nonatomic, readonly) SAStorage_Schema *currentSchema;
@property (nonatomic, strong) NSURL *url;

+ (id) schemaBundleWithContentsOfURL: (NSURL *) url;

- (SAStorage_Schema *) schemaWithHash: (NSUInteger) hash;

@end
