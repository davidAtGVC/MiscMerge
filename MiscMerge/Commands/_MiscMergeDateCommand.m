//
//  _MiscMergeDateCommand.m
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

#import "_MiscMergeDateCommand.h"
#import "MiscMergeMacros.h"
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>

/* On YellowBox, NSCalendarDate is now in its own header */
#import <Foundation/NSObjCRuntime.h>
#if defined(FOUNDATION_STATIC_INLINE) || defined(GNUSTEP)
#import <Foundation/NSCalendarDate.h>
#endif

@class NSCalendarDate;

@implementation _MiscMergeDateCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"date" fromScanner:aScanner isOptional:NO];
    [self setDateFormat:[self getArgumentStringFromScanner:aScanner toEnd:YES]];
    if (mm_IsEmpty([self dateFormat]) == YES)
    {
        [self setDateFormat:@"%B %d, %Y"];
    }
    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    NSCalendarDate *currentDate = (NSCalendarDate *)[NSCalendarDate date];
    [aMerger appendToOutput:[currentDate descriptionWithCalendarFormat:[self dateFormat]]];
    return MiscMergeCommandExitNormal;
}

@end
