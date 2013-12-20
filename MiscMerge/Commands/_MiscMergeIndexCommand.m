//
//  _MiscMergeIndexCommand.m
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

#import "_MiscMergeIndexCommand.h"
#import "MiscMergeExpression.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

@implementation _MiscMergeIndexCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"index" fromScanner:aScanner isOptional:NO];
    [self setArrayField:[self getArgumentStringFromScanner:aScanner toEnd:NO quotes:&_arrayQuote]];
    [self setTheIndex:[self getPrimaryExpressionFromScanner:aScanner]];
    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    id theArray = [aMerger valueForField:[self arrayField] quoted:[self arrayQuote]];

    if ( [theArray respondsToSelector:@selector(objectAtIndex:)] )
    {
        NSInteger lookupIndex = [[self theIndex] evaluateAsIntegerWithEngine:aMerger];

        if ( (lookupIndex >= 0) && (lookupIndex < (NSInteger)[theArray count]) ) {
            [aMerger appendToOutput:[theArray objectAtIndex:lookupIndex]];
        }
    }
    else {
        [aMerger appendToOutput:theArray];
    }

    return MiscMergeCommandExitNormal;
}

@end

