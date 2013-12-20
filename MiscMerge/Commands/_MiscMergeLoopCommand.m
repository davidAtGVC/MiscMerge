//
//  _MiscMergeLoopCommand.m
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

#import "_MiscMergeLoopCommand.h"
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSCharacterSet.h>
#import "MiscMergeCommandBlock.h"
#import "MiscMergeExpression.h"
#import "MiscMergeFunctions.h"

@implementation _MiscMergeLoopCommand

- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setCommandBlock:[[MiscMergeCommandBlock alloc] initWithOwner:self]];
    }
    return self;
}

- (NSString *)validateStep:(int)step
{
    if (step == 0)
    {
        return [NSString stringWithFormat:@"%@: Loop %@ is infinite (no step value).",
            [self class], [self loopName]];
    }

    return nil;
}

- (NSString *)validateStart:(NSInteger)start stop:(NSInteger)stop step:(NSInteger)step
{
    NSString *error = nil;

    if (step == 0)
    {
        step = (start <= stop)? 1 : -1;
        error = [NSString stringWithFormat:@"%@: Loop %@ is infinite (no step value).  Setting to %ld.\n", [self class], [self loopName], (long)step];
    }

    if (((start < stop) && (step < 0)) || ((start > stop) && (step > 0)))
    {
        return [NSString stringWithFormat:@"%@%@: Loop %@ is probably longer than you want. (start,end,step) = (%ld,%ld,%ld).", error?error:@"", [self class], [self loopName], (long)start, stop, step];
    }

    return error;
}

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    [self eatKeyWord:@"loop" fromScanner:aScanner isOptional:NO];
    [self setIndexName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];
    [self setStartKey:[self getPrimaryExpressionFromScanner:aScanner]];
    [self setStopKey:[self getPrimaryExpressionFromScanner:aScanner]];
    [self setStepKey:[self getPrimaryExpressionFromScanner:aScanner]];
    [self setLoopName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];

    [template pushCommandBlock:[self commandBlock]];

    return YES;
}

- (void)handleEndLoopInTemplate:(MiscMergeTemplate *)template
{
    [template popCommandBlock:[self commandBlock]];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    NSMutableDictionary *loopContext = [NSMutableDictionary dictionary];
    NSInteger theIndex;
    NSInteger start = [[self startKey] evaluateAsIntegerWithEngine:aMerger];
    NSInteger stop  = [[self stopKey] evaluateAsIntegerWithEngine:aMerger];
    NSInteger step  = [[self stepKey] evaluateAsIntegerWithEngine:aMerger];
    MiscMergeCommandExitType exitCode = MiscMergeCommandExitNormal;

    NSString *error = [self validateStart:start stop:stop step:step];
    if (error) {
        NSLog(@"%@", error);
    }

    if (step == 0)
        step = (start <= stop)? 1 : -1;

    [aMerger addContextObject:loopContext];
    for (theIndex = start; (exitCode != MiscMergeCommandExitBreak) && ((step > 0)? (theIndex <= stop) : (theIndex >= stop)); theIndex += step)
    {
        [loopContext setObject:[NSString stringWithFormat:@"%ld", (long)theIndex] forKey:[self indexName]];
        exitCode = [aMerger executeCommandBlock:[self commandBlock]];
    }
    [aMerger removeContextObject:loopContext];
    return MiscMergeCommandExitNormal;
}

@end

