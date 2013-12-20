//
//  _MiscMergeDebugCommand.m
//
//	Written by Doug McClure
//
//	Copyright 2001-2004 by Don Yacktman and Doug McClure.
//	All rights reserved.
//
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//

#import "_MiscMergeDebugCommand.h"
#import <Foundation/Foundation.h>
#import "NSString+MiscAdditions.h"
#import "NSScanner+MiscMerge.h"

@implementation _MiscMergeDebugCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    if ([self eatKeyWord:@"debug" fromScanner:aScanner isOptional:NO] == NO)
        return NO;

    [self setTheText:[[aScanner mm_remainingString] mm_stringByTrimmingLeadWhitespace]];
    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    fwrite([[self theText] cStringUsingEncoding:NSUTF8StringEncoding], 1, [[self theText] lengthOfBytesUsingEncoding:NSUTF8StringEncoding], stderr);
    if ([[self theText] hasSuffix:@"\n"])
        fputc('\n', stderr);

    return MiscMergeCommandExitNormal;
}

@end
