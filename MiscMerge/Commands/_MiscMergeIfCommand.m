//
//  _MiscMergeIfCommand.m
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

#import "_MiscMergeIfCommand.h"
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSScanner.h>
#import "MiscMergeCommandBlock.h"
#import "MiscMergeExpression.h"

@implementation _MiscMergeIfCommand

- (id)init
{
    self = [super init];
    if ( self != nil )
    {
        [self setTrueBlock:[[MiscMergeCommandBlock alloc] initWithOwner:self]];
    }
    return self;
}

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"if" fromScanner:aScanner isOptional:NO];
    [self setExpression:[self getExpressionFromScanner:aScanner]];
    [template pushCommandBlock:[self trueBlock]];
    return YES;
}

- (void)handleElseInTemplate:(MiscMergeTemplate *)template
{
    if ([self elseBlock] == nil)
        [self setElseBlock:[[MiscMergeCommandBlock alloc] initWithOwner:self]];
    
    [template popCommandBlock:[self trueBlock]];
    [template pushCommandBlock:[self elseBlock]];
}

- (void)handleEndifInTemplate:(MiscMergeTemplate *)template
{
    [template popCommandBlock];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    if ([self evaluateExpressionInMerger:aMerger])
        return [aMerger executeCommandBlock:[self trueBlock]];
    else if ([self elseBlock])
        return [aMerger executeCommandBlock:[self elseBlock]];
    return MiscMergeCommandExitNormal;
}


- (BOOL)evaluateExpressionInMerger:(MiscMergeEngine *)anEngine
{
    return [[self expression] evaluateAsBoolWithEngine:anEngine];
}

@end

