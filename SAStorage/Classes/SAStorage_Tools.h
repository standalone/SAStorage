#import <Foundation/Foundation.h>


#define		SAStorage_RecordIDType				NSUInteger

extern const SAStorage_RecordIDType		SAStorage_RecordIDNone;
extern const NSString					*SAStorage_RecordIDURLPrefix;

@interface SAStorage : NSObject

+ (NSString *) uuid;

@end

