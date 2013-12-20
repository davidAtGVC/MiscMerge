//
//  _MiscMergeFieldCommand.m
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

#import "_MiscMergeFieldCommand.h"
#import "MiscMergeExpression.h"
#import "NSString+MiscAdditions.h"
#import "NSScanner+MiscMerge.h"

@implementation _MiscMergeFieldCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"field" fromScanner:aScanner isOptional:YES];
    [self setExpression:[self getExpressionFromScanner:aScanner]];
    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    [aMerger appendToOutput:[[self expression] evaluateWithEngine:aMerger]];
    return MiscMergeCommandExitNormal;
}

@end
