//
//  SAStorage_Error.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Error.h"

NSString *		ConvertErrorToString(SAStorage_ErrorType error) {
	return @[ @"]SAStorage_Error_NoSuchTable", @"SAStorage_Error_NoSuchField", @"SAStorage_Error_UnexpectedFile", @"SAStorage_Error_TableNotPresent", @"SAStorage_Error_FieldNotPresentInTable", @"SAStorage_Error_IncorrectDataType"][error];

}

@implementation SAStorage_Error

+ (void) handleNonFatalError: (SAStorage_ErrorType) error object: (id) object userInfo: (NSDictionary *) info description: (NSString *) description {
	NSLog(@"Non-fatal error: %@, %@", ConvertErrorToString(error), info ?: @"");
}

@end
