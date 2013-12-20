//
//  _MiscMergeIncludeCommand.m
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

#import "_MiscMergeIncludeCommand.h"
#import <Foundation/NSString.h>
//#import <Foundation/NSUtilities.h>
#import "MiscMergeTemplate.h"
#import "MiscMergeCommandBlock.h"
#import "MiscMergeEngine.h"
#import "MiscMergeMacros.h"

@implementation _MiscMergeIncludeCommand

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template
{
    NSString *filename;
    NSString *resolvedFilename;
    NSString *fileString = nil;
    NSString *startDelim = nil;
    NSString *endDelim = nil;

    [self eatKeyWord:@"include" fromScanner:aScanner isOptional:NO];
    filename = [self getArgumentStringFromScanner:aScanner toEnd:NO];
    startDelim = [self getArgumentStringFromScanner:aScanner toEnd:NO];

    if ( mm_IsEmpty(startDelim) == NO )
    {
        endDelim = [self getArgumentStringFromScanner:aScanner toEnd:NO];

        if ( [endDelim length] == 0 )
        {
            [template reportParseError:@"%@: Must specify an end delimiter if specifying a start delimiter.", [self class]];
            startDelim = nil;
        }
    }

    resolvedFilename = [template resolveTemplateFilename:filename];

    if (mm_IsEmpty(resolvedFilename) == NO)
    {
        NSError *err = nil;
        fileString = [NSString stringWithContentsOfFile:resolvedFilename encoding:NSUTF8StringEncoding error:&err];
        if ( err != nil )
        {
            [template reportParseError:@"%@: Error loading from file '%@'\n%@", [self class], resolvedFilename, err];
            return NO;
        }
    }

    if (mm_IsEmpty(fileString) == NO)
    {
        MiscMergeTemplate *newTemplate = [[[template class] alloc] init];

        if ( startDelim != nil )
        {
            [newTemplate setStartDelimiter:startDelim];
            [newTemplate setEndDelimiter:endDelim];
        }
        else
        {
            [newTemplate setStartDelimiter:[template startDelimiter]];
            [newTemplate setEndDelimiter:[template endDelimiter]];
        }
        
        [newTemplate setFilename:resolvedFilename];
        [newTemplate setDelegate:[template delegate]];
        [newTemplate parseString:fileString];
        [self setCommandBlock:[newTemplate topLevelCommandBlock]];
    }
    else
    {
        [template reportParseError:@"%@: Could not load from file '%@'", [self class], resolvedFilename];
    }

    return YES;
}

- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger
{
    if ([self commandBlock])
        return [aMerger executeCommandBlock:[self commandBlock]];
    return MiscMergeCommandExitNormal;
}

@end

