//
//  SAStorage_SchemaBundle.m
//  SAStorage_Library
//
//  Created by Ben Gottlieb on 5/5/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SAStorage_SchemaBundle.h"

NSString		*s_schemaMetadataFilename = @"metadata.json";
NSString		*s_schemaMetadata_currentFilename = @"current_schema_filename";

@interface SAStorage_SchemaBundle ()
@property (nonatomic, strong) SAStorage_Schema *currentSchema;
@end


@implementation SAStorage_SchemaBundle

+ (id) schemaBundleWithContentsOfURL: (NSURL *) url {
	BOOL							isDirectory;

	if (![[NSFileManager defaultManager] fileExistsAtPath: url.path isDirectory: &isDirectory]) return nil;
	
	SAStorage_SchemaBundle			*bundle = [[self alloc] init];
	bundle.url = url;
	
	if (isDirectory) {
		NSData			*data = [NSData dataWithContentsOfURL: [url URLByAppendingPathComponent: s_schemaMetadataFilename]];
		NSError			*error = nil;
		
		if (data == nil) return nil;
		
		NSDictionary	*info = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
		if (info == nil) {
			NSLog(@"Failed to decode schema bundle metadata at %@: %@", url, error);
			return nil;
		}
		
		NSURL			*schemaURL = [url URLByAppendingPathComponent: info[s_schemaMetadata_currentFilename]];
		
		bundle.currentSchema = [SAStorage_Schema schemaWithContentsOfURL: schemaURL];
	} else
		bundle.currentSchema = [SAStorage_Schema schemaWithContentsOfURL: url];
	return bundle;
	
}


@end
