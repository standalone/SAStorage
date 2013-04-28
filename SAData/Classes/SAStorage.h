//
//  SAStorage.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define		SAStorage_RecordIDType				NSUInteger

extern const SAStorage_RecordIDType		SAStorage_RecordIDNone;
extern const NSString					*SAStorage_RecordIDURLPrefix;

@interface SAStorage : NSObject

+ (NSString *) uuid;

@end
