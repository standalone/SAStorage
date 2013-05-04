//
//  SAStorage_Error.h
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/3/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString		*SAStorage_ErrorDomain;



typedef NS_ENUM(uint8_t, SAStorage_ErrorType) {
	SAStorage_Error_NoSuchTable,
	SAStorage_Error_NoSuchField,
	SAStorage_Error_UnexpectedFile,
	SAStorage_Error_TableNotPresent,
	SAStorage_Error_FieldNotPresentInTable,
	SAStorage_Error_IncorrectDataType,
	SAStorage_Error_IncorrectDataTypeForRelationship,
	SAStorage_Error_TryingToSaveReadnlyDatabase,
	
};

NSString *		ConvertErrorToString(SAStorage_ErrorType error);

@interface SAStorage_Error : NSError

+ (id) error: (SAStorage_ErrorType) type info: (NSDictionary *) info;

@end
