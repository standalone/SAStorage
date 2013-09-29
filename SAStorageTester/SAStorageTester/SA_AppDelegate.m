//
//  SA_AppDelegate.m
//  SADataTester
//
//  Created by Ben Gottlieb on 4/27/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import "SA_AppDelegate.h"
//#import <SAStorage/SAStorage.h>
#import "SAStorage.h"

@interface CT_Contact : SAStorage_Record

@end

@implementation CT_Contact

@end

@implementation SA_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	[self loadContacts];
	
    return YES;
}

- (void) loadHours {
	NSURL						*databaseURL = [NSURL fileURLWithPath: [@"~/Documents/Hours" stringByExpandingTildeInPath]];
	SAStorage_Database			*database = [SAStorage_Database databaseWithURL: databaseURL ofType: SAStorage_Database_CSV basedOn: nil];
	
	NSLog(@"Database: %@", database[@"data"]);
	database.url = [NSURL fileURLWithPath: [@"~/Documents/HoursSaved" stringByExpandingTildeInPath]];
	[database saveWithCompletion: nil];
}

- (void) loadContacts {
	NSURL				*url = [[NSBundle mainBundle] URLForResource: @"sample_schema" withExtension: @"json"];
	
	SAStorage_SchemaBundle	*schemaBundle = [SAStorage_SchemaBundle schemaBundleWithContentsOfURL: url];
	SAStorage_Schema		*schema = schemaBundle.currentSchema;
	
	schema[@"Contacts"][@"phone_number"] = [SAStorage_SchemaField fieldNamed: @"phone_number" ofType: SAStorage_SchemaField_String];
	
	NSLog(@"Schema: %@", schema);
	NSLog(@"%@", [NSString stringWithUTF8String: schema.JSONRepresentation.bytes]);
	
	NSURL						*databaseURL = [NSURL fileURLWithPath: [@"~/Documents/Contacts" stringByExpandingTildeInPath]];
	SAStorage_Database			*database = [SAStorage_Database databaseWithURL: databaseURL ofType: SAStorage_Database_FS basedOn: schemaBundle];
	SAStorage_Query				*query = [SAStorage_Query queryInTable: @"Contacts" withPredicate: [NSPredicate predicateWithFormat: @"first_name == 'Bill'"]];
	__block SAStorage_Record	*foundRecord = nil;
	
	[database anyRecordMatchingQuery: query completion: ^(SAStorage_Record *record, NSError *error) {
		foundRecord = record;
	}];
	
	if (foundRecord == nil) {
		[database insertNewRecordOfType: @"Contacts" completion:^(SAStorage_Record *record, NSError *error) {
			record[@"first_name"] = @"Bill";
			record[@"last_name"] = @"Smith";
			record[@"phone_number"] = @"311";
			record.recordHasChanges = YES;
		}];
	} else {
		foundRecord[@"first_name"] = @"William";
		foundRecord.recordHasChanges = YES;
	}
	
	[database saveWithCompletion: nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
