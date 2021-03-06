//
//  _MiscMergeOptionCommand.m
//
//	Written by Doug McClure
//
//	Copyright 2002-2004 by Don Yacktman and Doug McClure.
//	All rights reserved.
//
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//

#import "_MiscMergeOptionCommand.h"
#import "NSString+MiscAdditions.h"
#import "MiscMergeTemplate.h"
#import "MiscMergeFunctions.h"


@implementation _MiscMergeOptionCommand


/*" This method will parse a option command in a template. Options can affect the template
processing or the runtime.

option betweenWhitespace keepAll* | keepOne | trim
option recursive no* | yes | <number>
option failedLookupResult Key* | KeyWithDelims | Nil | KeyIfNumeric
option nilLookupResult Nil* | KeyIfQuoted | Key | KeyWithDelims

 * the default option

"*/
- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template;
{
    NSString *option;

    if ( [self eatKeyWord:@"option" fromScanner:aScanner isOptional:NO] == NO)
        return NO;

    option = [self getArgumentStringFromScanner:aScanner toEnd:NO];

    if ( NSOrderedSame == [option caseInsensitiveCompare:@"recursiveLookups"] )
    {
        [self setOptionType:RecursiveLookups];
        [self setValue1:[self getArgumentStringFromScanner:aScanner toEnd:NO]];
    }
    else if ( NSOrderedSame == [option caseInsensitiveCompare:@"delimiters"] )
    {
        NSString *argument1 = [self getArgumentStringFromScanner:aScanner toEnd:NO];
        NSString *argument2 = [self getArgumentStringFromScanner:aScanner toEnd:NO];

        if ( ([argument1 length] == 0) && ([argument2 length] == 0) )
            [template reportParseError:@"%@: option delimiters command needs two arguments", [self class]];
        else
        {
            [template setStartDelimiter:argument1];
            [template setEndDelimiter:argument2];
        }
    }
    else if ( NSOrderedSame == [option caseInsensitiveCompare:@"betweenWhitespace"] )
    {
        NSString *argument = [self getArgumentStringFromScanner:aScanner toEnd:NO];

        if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keep"] )
            [template setTrimWhitespaceBehavior:MiscMergeKeepWhitespace];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"trim"] )
            [template setTrimWhitespaceBehavior:MiscMergeTrimWhitespace];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keepNonBlank"] )
            [template setTrimWhitespaceBehavior:MiscMergeKeepNonBlankWhitespace];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"ignoreCommandSpaces"] )
            [template setTrimWhitespaceBehavior:MiscMergeIgnoreCommandSpaces];
    }
    else if ( NSOrderedSame == [option caseInsensitiveCompare:@"failedLookupResult"] )
    {
        NSString *argument = [self getArgumentStringFromScanner:aScanner toEnd:NO];

        if ( NSOrderedSame == [argument caseInsensitiveCompare:@"key"] )
            [self setOptionType:FailedLookupResultKey];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keyWithDelims"] )
            [self setOptionType:FailedLookupResultKeyWithDelims];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"nil"] )
            [self setOptionType:FailedLookupResultNil];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keyIfNumeric"] )
            [self setOptionType:FailedLookupResultKeyIfNumeric];
    }
    else if ( NSOrderedSame == [option caseInsensitiveCompare:@"nilLookupResult"] )
    {
        NSString *argument = [self getArgumentStringFromScanner:aScanner toEnd:NO];

        if ( NSOrderedSame == [argument caseInsensitiveCompare:@"nil"] )
            [self setOptionType:NilLookupResultNil];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keyIfQuoted"] )
            [self setOptionType:NilLookupResultKeyIfQuoted];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"key"] )
            [self setOptionType:NilLookupResultKey];
        else if ( NSOrderedSame == [argument caseInsensitiveCompare:@"keyWithDelims"] )
            [self setOptionType:NilLookupResultKeyWithDelims];
    }
    else
    {
        [self error_argument:option];
    }

    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    switch ([self optionType])
    {
        case RecursiveLookups:
            if ( [[self value1] integerValue] > 0 )
                [aMerger setUseRecursiveLookups:YES limit:[[self value1] integerValue]];
            else if ( MMIsBooleanTrueString([self value1]) )
                [aMerger setUseRecursiveLookups:YES];
            else
                [aMerger setUseRecursiveLookups:NO];
            break;

        case FailedLookupResultKey:
            [aMerger setFailedLookupResult:MiscMergeFailedLookupResultKey];
            break;
            
        case FailedLookupResultKeyWithDelims:
            [aMerger setFailedLookupResult:MiscMergeFailedLookupResultKeyWithDelims];
            break;

        case FailedLookupResultNil:
            [aMerger setFailedLookupResult:MiscMergeFailedLookupResultNil];
           break;

        case FailedLookupResultKeyIfNumeric:
            [aMerger setFailedLookupResult:MiscMergeFailedLookupResultKeyIfNumeric];
            break;

        case NilLookupResultNil:
            [aMerger setNilLookupResult:MiscMergeNilLookupResultNil];
            break;

        case NilLookupResultKeyIfQuoted:
            [aMerger setNilLookupResult:MiscMergeNilLookupResultKeyIfQuoted];
            break;

        case NilLookupResultKey:
            [aMerger setNilLookupResult:MiscMergeNilLookupResultKey];
            break;

        case NilLookupResultKeyWithDelims:
            [aMerger setNilLookupResult:MiscMergeNilLookupResultKeyWithDelims];
            break;
    }

    return MiscMergeCommandExitNormal;
}

@end
