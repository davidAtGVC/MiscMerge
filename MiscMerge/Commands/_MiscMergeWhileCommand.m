//
//  _MiscMergeWhileCommand.m
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

#import "_MiscMergeWhileCommand.h"
#import <Foundation/NSString.h>
#import "MiscMergeCommandBlock.h"
#import "MiscMergeExpression.h"

@implementation _MiscMergeWhileCommand

- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setCommandBlock:[[MiscMergeCommandBlock alloc] initWithOwner:self]];
    }
    return self;
}

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"while" fromScanner:aScanner isOptional:NO];
    [self setExpression:[self getExpressionFromScanner:aScanner]];
    [template pushCommandBlock:[self commandBlock]];

    return YES;
}

- (void)handleEndWhileInTemplate:(MiscMergeTemplate *)template
{
    [template popCommandBlock:[self commandBlock]];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    MiscMergeCommandExitType exitCode = MiscMergeCommandExitNormal;

    while (exitCode != MiscMergeCommandExitBreak && [[self expression] evaluateAsBoolWithEngine:aMerger])
    {
        exitCode = [aMerger executeCommandBlock:[self commandBlock]];
    }

    return MiscMergeCommandExitNormal;
}

@end
