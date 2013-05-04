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
	SAStorage_Error_IncorrectDataType
	
};

@interface SAStorage_Error : NSError

+ (void) handleNonFatalError: (SAStorage_ErrorType) error object: (id) object userInfo: (NSDictionary *) info description: (NSString *) description;

@end
