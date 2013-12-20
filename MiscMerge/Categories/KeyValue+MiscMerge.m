//
//  KeyValue+MiscMerge.m
//
//	Written by Don Yacktman and Carl Lindberg
//
//	Copyright 2001-2004 by Don Yacktman and Carl Lindberg.
//	All rights reserved.
//
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//

#import "KeyValue+MiscMerge.h"
#import "NSCharacterSet+MiscMerge.h"

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCharacterSet.h>

#import <stdlib.h> // for NULL os OSX
#import <objc/objc-runtime.h>

@interface NSObject (WarningAvoidance)
+ (BOOL)accessInstanceVariablesDirectly;
@end

@implementation NSObject (MiscMergeHasKey)

- (BOOL)mm_hasMiscMergeKeyPath:(NSString *)keyPath
{
    NSString *key = keyPath;
    NSRange dotRange = [keyPath rangeOfCharacterFromSet:[NSCharacterSet mm_KVCDelimiterCharacterSet]];

    if (dotRange.length > 0)
    {
        key = [keyPath substringToIndex:dotRange.location];
    }

    return [self mm_hasMiscMergeKey:key];
}

- (BOOL)mm_hasMiscMergeKey:(NSString *)key
{
    SEL keySelector;

    if ([key length] == 0) return NO;

    keySelector = NSSelectorFromString(key);

    return (keySelector != NULL && [self respondsToSelector:keySelector]) ||
        ([[self class] accessInstanceVariablesDirectly] &&
         class_getInstanceVariable([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]));
}

@end

@implementation NSDictionary (MiscMergeHasKey)

- (BOOL)mm_hasMiscMergeKey:(NSString *)key
{
    return ([self objectForKey:key] != nil)? YES : NO;
}

@end

@implementation NSArray (MiscMergeHasKey)

- (BOOL)mm_hasMiscMergeKey:(NSString *)key
{
    if ([key isEqualToString:@"count"]) return YES;
    if ([key hasPrefix:@"@"]) return YES;
    if ([self count] == 0) return YES; //Hmm
    return [[self objectAtIndex:0] mm_hasMiscMergeKey:key];
}

@end
