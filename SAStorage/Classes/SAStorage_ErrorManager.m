//
//  SAStorage_ErrorManager.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_ErrorManager.h"

@implementation SAStorage_ErrorManager

- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info {
	[self handleFatal: fatal error: error onObject: object userInfo: info description: nil];
}


- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSLog(@"Non-fatal error: %@, %@", ConvertErrorToString(error), info ?: @"");
}


@end
