//
//  SAStorage_Query.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_Query : NSObject

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) NSArray *arguments;


+ (id) queryWithPredicate: (NSPredicate *) predicate;
+ (id) queryWithSQL: (NSString *) sql andArgs: (NSArray *) args;

@end
