//
//  SAStorage_CSVParser.h
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAStorage_CSVParser : NSObject

+ (id) parserWithData: (NSData *) data;

@property (nonatomic, strong) NSArray *schemaFields;
@property (nonatomic) wchar_t iterationSeparator, fieldSeparator, recordSeparator;

- (NSError *) beginParsing;
- (NSDictionary *) nextRecordWithError: (NSError **) error;

@end
