//
//  _MiscMergeForeachCommand.m
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

#import "_MiscMergeForeachCommand.h"
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSValue.h>
#import "MiscMergeCommandBlock.h"
#import "MiscMergeEngine.h"
#import "MiscMergeExpression.h"

@implementation _MiscMergeForeachCommand

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
    [self eatKeyWord:@"foreach" fromScanner:aScanner isOptional:NO];
    [self setItemName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];
    [self setArrayExpression:[self getExpressionFromScanner:aScanner]];
    [self setLoopName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];

    [template pushCommandBlock:[self commandBlock]];

    return YES;
}

- (void)handleEndForeachInTemplate:(MiscMergeTemplate *)template
{
    [template popCommandBlock:[self commandBlock]];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    id itemArray;

    if ( [[self arrayExpression] isKindOfClass:[MiscMergeListExpression class]] )
        itemArray = [(MiscMergeListExpression *)[self arrayExpression] evaluateAsListWithEngine:aMerger];
    else
        itemArray = [[self arrayExpression] evaluateWithEngine:aMerger];

    // If the itemArray is a dictionary we are going to process it just bit differently
    // setting variable name <itemName>Key that has the key of the item we are printing out
    if ([itemArray isKindOfClass:[NSDictionary class]])
    {
        NSString *indexName = [NSString stringWithFormat:@"%@Index", [self itemName]];
        NSString *keyName = [NSString stringWithFormat:@"%@Key", [self itemName]];
        NSUInteger loopIndex = 0;
        NSMutableDictionary *loopContext = [NSMutableDictionary dictionary];
        NSEnumerator *itemEnum = [itemArray keyEnumerator];
        id currObject;
        MiscMergeCommandExitType exitCode = MiscMergeCommandExitNormal;

        [aMerger addContextObject:loopContext];
        while ((exitCode != MiscMergeCommandExitBreak) && (currObject = [itemEnum nextObject]))
        {
            // maybe index should be a string
            [loopContext setObject:[itemArray objectForKey:currObject] forKey:[self itemName]];
            [loopContext setObject:currObject forKey:keyName];
            [loopContext setObject:[NSNumber numberWithInteger:loopIndex] forKey:indexName];
            exitCode = [aMerger executeCommandBlock:[self commandBlock]];
            loopIndex++;
        }
        [aMerger removeContextObject:loopContext];
    }
    else if ([itemArray respondsToSelector:@selector(objectEnumerator)])
    {
        NSString *indexName = [NSString stringWithFormat:@"%@Index", [self itemName]];
        NSUInteger loopIndex = 0;
        NSMutableDictionary *loopContext = [NSMutableDictionary dictionary];
        NSEnumerator *itemEnum = [itemArray objectEnumerator];
        id currObject;
        MiscMergeCommandExitType exitCode = MiscMergeCommandExitNormal;

        [aMerger addContextObject:loopContext];
        while ((exitCode != MiscMergeCommandExitBreak) && (currObject = [itemEnum nextObject]))
        {
            // maybe index should be a string
            [loopContext setObject:currObject forKey:[self itemName]];
            [loopContext setObject:[NSNumber numberWithInteger:loopIndex] forKey:indexName];
            exitCode = [aMerger executeCommandBlock:[self commandBlock]];
            loopIndex++;
        }
        [aMerger removeContextObject:loopContext];
    }

    return MiscMergeCommandExitNormal;
}

@end

