//
//  _MiscMergeCopyCommand.m
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

#import "_MiscMergeCopyCommand.h"
#import "NSString+MiscAdditions.h"
#import "NSScanner+MiscMerge.h"

@implementation _MiscMergeCopyCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    if ([self eatKeyWord:@"copy" fromScanner:aScanner isOptional:NO] == NO)
        return NO;

    [self setTheText:[[aScanner mm_remainingString] mm_stringByTrimmingLeadWhitespace]];

    return YES;
}

/*" Special method used by the template "*/
- (void)parseFromRawString:(NSString *)aString
{
    [self setTheText:aString];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    [aMerger appendToOutput:[self theText]];
    return MiscMergeCommandExitNormal;
}

@end
