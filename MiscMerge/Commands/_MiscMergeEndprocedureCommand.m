//
//  _MiscMergeEndprocedureCommand.m
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

#import "_MiscMergeEndprocedureCommand.h"
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSString.h>
#import "_MiscMergeProcedureCommand.h"
#import "MiscMergeCommandBlock.h"
#import "MiscMergeMacros.h"

@implementation _MiscMergeEndprocedureCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    _MiscMergeProcedureCommand *procCommand = [[template currentCommandBlock] owner];

    [self eatKeyWord:@"endprocedure" fromScanner:aScanner isOptional:NO];
    [self setProcedureName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];

    if ( ([procCommand isKindOfCommandClass:@"Procedure"] == NO) ||
        ((mm_IsEmpty([self procedureName]) == NO) && (mm_IsEmpty([procCommand procedureName]) == NO) && ([[self procedureName] isEqualToString:[procCommand procedureName]] == NO)))
    {
        [template reportParseError:@"Mismatched endprocedure command"];
    }
    else
    {
        [procCommand handleEndProcedureInTemplate:template];
    }

    return YES;
}

@end
