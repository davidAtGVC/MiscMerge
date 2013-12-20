//
//  _MiscMergeCallCommand.m
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

#import "_MiscMergeCallCommand.h"
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import "MiscMergeEngine.h"
#import "_MiscMergeProcedureCommand.h"

@implementation _MiscMergeCallCommand

- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setArgumentArray:[NSMutableArray array]];
        [self setQuotedArray:[NSMutableArray array]];
    }
    return self;
}

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    NSString *argName;
    NSInteger quotes;

    [self eatKeyWord:@"call" fromScanner:aScanner isOptional:NO];
    [self setProcedureName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];

    while ((argName = [self getArgumentStringFromScanner:aScanner toEnd:NO quotes:&quotes]))
    {
        [[self argumentArray] addObject:argName];
        [[self quotedArray] addObject:[NSNumber numberWithInteger:quotes]];
    }

    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    NSString *symbolName = [NSString stringWithFormat:@"_MiscMergeProcedure%@", [self procedureName]];
    _MiscMergeProcedureCommand *procCommand = [[aMerger userInfo] objectForKey:symbolName];
    NSInteger count = [[self argumentArray] count];
    NSMutableArray *realArgArray = [NSMutableArray arrayWithCapacity:count];

    if (procCommand == nil)
    {
        if ([self alreadyWarned] == NO )
        {
            NSLog(@"%@: Error -- procedure %@ not found.", [self class], [self procedureName]);
            [self setAlreadyWarned:YES];
        }
        return MiscMergeCommandExitNormal;
    }

    for (NSInteger i = 0; i < count; i++)
    {
        NSString *argument = [[self argumentArray] objectAtIndex:i];
        id value = nil;
        NSInteger quote = [[[self quotedArray] objectAtIndex:i] integerValue];

        if ( quote == 1 )
        {
            value = argument;
        }
        else
        {
            value = [aMerger valueForField:argument quoted:quote];
            if (value == nil) value = [NSNull null];
        }

        if ( value != nil )
            [realArgArray addObject:value];
    }

    [procCommand executeForMerge:aMerger arguments:realArgArray];
    return MiscMergeCommandExitNormal;
}

@end

