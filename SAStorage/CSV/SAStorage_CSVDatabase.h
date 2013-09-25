//
//  SAStorage_CSVDatabase.h
//  SAStorageTester
//
//  Created by Ben Gottlieb on 9/17/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_JSONDatabase.h"

@interface SAStorage_CSVDatabase : SAStorage_JSONDatabase

@property (nonatomic) BOOL writeOutQuotationMarks;
@property (nonatomic) char iterationSeparator, fieldSeparator, recordSeparator;

+ (NSString *) tableName;
@end
