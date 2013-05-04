//
//  SAStorage_ErrorManager.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAStorage_Error.h"

@interface SAStorage_ErrorManager : NSObject

- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info;
- (void) handleFatal: (BOOL) fatal error: (SAStorage_ErrorType) error onObject: (id) object userInfo: (NSDictionary *) info description: (NSString *) description;


@end
