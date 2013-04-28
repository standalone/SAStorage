//
//  SAStorage_Internal_SQL_ResultSet.h
//  SADataTester
//
//  Created by Chris Cieslak on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_Internal_SQL_ResultSet : NSObject<NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;

@end
