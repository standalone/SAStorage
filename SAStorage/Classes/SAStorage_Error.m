//
//  SAStorage_Error.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_Error.h"

NSString *		ConvertErrorToString(SAStorage_ErrorType error) {
	return @[ @"]SAStorage_Error_NoSuchTable", @"SAStorage_Error_NoSuchField", @"SAStorage_Error_UnexpectedFile", @"SAStorage_Error_TableNotPresent", @"SAStorage_Error_FieldNotPresentInTable", @"SAStorage_Error_IncorrectDataType", @"SAStorage_Error_IncorrectDataTypeForRelationship", @"SAStorage_Error_TryingToSaveReadnlyDatabase"][error];

}

@implementation SAStorage_Error
+ (id) error: (SAStorage_ErrorType) type info: (NSDictionary *) info {
	return [self errorWithDomain: SAStorage_ErrorDomain code: type userInfo: info];
}
@end
