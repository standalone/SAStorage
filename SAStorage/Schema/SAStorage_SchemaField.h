//
//  SAStorage_SchemaField.h
//  SADataTester
//
//  Created by Ben Gottlieb on 4/28/13.
//  Copyright (c) 2013 Stand Alone, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint8_t, SAStorage_SchemaField_Type) {
	SAStorage_SchemaField_None,
	SAStorage_SchemaField_Integer,
	SAStorage_SchemaField_Float,
	SAStorage_SchemaField_Double,
	SAStorage_SchemaField_Boolean,
	SAStorage_SchemaField_String,
	SAStorage_SchemaField_Date,
	SAStorage_SchemaField_Blob,
	SAStorage_SchemaField_RelationshipOneToOne,
	SAStorage_SchemaField_RelationshipOneToMany,
	SAStorage_SchemaField_RelationshipManyToOne,
	SAStorage_SchemaField_RelationshipManyToMany
};

@interface SAStorage_SchemaField : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) SAStorage_SchemaField_Type type;
@property (nonatomic, strong) NSString *relatedTo;				//if a relationship, what table does it point to?
@property (nonatomic, strong) NSString *relatedBy;				//…and what field in that table
@property (nonatomic) BOOL sortedOn;
@property (nonatomic, readonly) BOOL isRelationship;

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
+ (id) fieldWithDictionary: (NSDictionary *) dict;
+ (id) fieldNamed: (NSString *) name ofType: (SAStorage_SchemaField_Type) type;
@end