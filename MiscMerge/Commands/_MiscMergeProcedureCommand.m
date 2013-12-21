//
//  _MiscMergeProcedureCommand.m
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

#import "_MiscMergeProcedureCommand.h"
#import <Foundation/Foundation.h>
#import "MiscMergeEngine.h"
#import "MiscMergeTemplate.h"
#import "MiscMergeCommandBlock.h"
#import "NSScanner+MiscMerge.h"


@implementation _MiscMergeProcedureCommand

- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setCommandBlock:[[MiscMergeCommandBlock alloc] initWithOwner:self]];
        [self setArgumentArray:[NSMutableArray array]];
        [self setArgumentTypes:[NSMutableArray array]];
    }
    return self;
}

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    NSString *argName;
    BOOL optArgProcessing = NO;

    [self eatKeyWord:@"procedure" fromScanner:aScanner isOptional:NO];
    [self setProcedureName:[self getArgumentStringFromScanner:aScanner toEnd:NO]];

    while ((argName = [self getArgumentStringFromScanner:aScanner toEnd:NO]))
    {
        if ( [argName hasSuffix:@"?"] )
        {
            optArgProcessing = YES;
            argName = [argName substringToIndex:([argName length] - 1)];
            [[self argumentTypes] addObject:[NSNumber numberWithInt:OptionalArg]];
        }
        else if ( [argName hasSuffix:@"..."] )
        {
            argName = [argName substringToIndex:([argName length] - 3)];
            [aScanner mm_remainingString];
            [[self argumentTypes] addObject:[NSNumber numberWithInt:ArrayArg]];
        }
        else if ( optArgProcessing )
        {
            [template reportParseError:@"%@:  Can only specify optional arguments after an initial optional argument:  \"%@\".", [self procedureName], argName];
            return NO;
        }
        else {
            [[self argumentTypes] addObject:[NSNumber numberWithInt:RequiredArg]];
        }

        [[self argumentArray] addObject:argName];
    }

    [template pushCommandBlock:[self commandBlock]];

    return YES;
}

- (void)handleEndProcedureInTemplate:(MiscMergeTemplate *)template
{
    [template popCommandBlock:[self commandBlock]];
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    /* Just want to register ourselves to the engine */
    NSString *symbolName = [NSString stringWithFormat:@"_MiscMergeProcedure%@", [self procedureName]];
    [[aMerger userInfo] setObject:self forKey:symbolName];
    return MiscMergeCommandExitNormal;
}

/* The *real* execute; messaged from the call command */
- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger arguments:(NSArray *)passedArgArray
{
    NSInteger argumentIndex = 0, argumentCount = [[self argumentArray] count];
    NSInteger passedIndex = 0, passedCount = [passedArgArray count];
    NSInteger addToArgIndex = 0;
    NSMutableDictionary *procedureContext = [NSMutableDictionary dictionary];

    for ( ; passedIndex < passedCount; passedIndex++ ) {
        NSString *argName;
        NSInteger argType;

        id argValue = [passedArgArray objectAtIndex:passedIndex];

        if ( argumentIndex >= argumentCount ) {
            NSLog(@"%@: More arguments than declared.", [self procedureName]);
            break;
        }

        argName = [[self argumentArray] objectAtIndex:argumentIndex];
        argType = [[[self argumentTypes] objectAtIndex:argumentIndex] integerValue];
        
        switch ( argType )
        {
            case RequiredArg:
            case OptionalArg:
                if ( argValue == [NSNull null] )
                    argValue = @"";
                [procedureContext setObject:argValue forKey:argName];
                argumentIndex++;
                break;

            case ArrayArg:
            {
                NSMutableArray *array = [procedureContext objectForKey:argName];
                if ( array == nil ) {
                    array = [NSMutableArray array];
                    [procedureContext setObject:array forKey:argName];
                }
                addToArgIndex = 1;
                [array addObject:argValue];
            }
                break;
        }
    }

    argumentIndex += addToArgIndex;

    /* Insure any optional parameters get set to "" and log any required parameters there were not
        gotten in the call. */
    if ( argumentIndex < argumentCount )
    {
        NSMutableString *string = [NSMutableString string];
        
        for ( ; argumentIndex < argumentCount; argumentIndex++ )
        {
            NSString *argName = [[self argumentArray] objectAtIndex:argumentIndex];
            NSInteger argType = [[[self argumentTypes] objectAtIndex:argumentIndex] integerValue];

            if ( argType == OptionalArg ) {
                [procedureContext setObject:@"" forKey:argName];
            }
            else if ( argType == ArrayArg ) {
                [procedureContext setObject:[NSArray array] forKey:argName];
            }
            else {
                if ( [string length] > 0 )
                    [string appendString:@", "];
                [string appendString:argName];
            }
        }

        if ( [string length] > 0 )
            NSLog(@"%@: Missing arguments for: %@", [self procedureName], string);
    }


    [aMerger addContextObject:procedureContext andSetLocalSymbols:YES];
    [aMerger executeCommandBlock:[self commandBlock]];
    [aMerger removeContextObject:procedureContext];

    return MiscMergeCommandExitNormal;
}

@end

