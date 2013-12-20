//
//  MiscMergeDriver.m
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

#import "MiscMergeDriver.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import "MiscMergeEngine.h"
#import "MiscMergeTemplate.h"
#import "MiscMergeMacros.h"

@interface MiscMergeDriver ()
{
    NSUInteger _mergeLoopIndex;          /*" Index to #{dataArray} when merge is in progress "*/
}
@property (assign, readwrite, getter=isMerging) BOOL merging;

@end



@implementation MiscMergeDriver
/*"
 * A MiscMergeDriver is used to merge an ASCII template with several
 * objects.  Each object will be used in turn to generate a new output
 * "document".  Key-value methods are used to extract values from the
 * objects.
 * 
 * If you only need to generate a single merge, you may wish to simply use
 * a MiscMergeEngine object.  If you have several merges to perform, then a
 * MiscMergeDriver implements the required loop to generate the required
 * merges, as well as supporting a protocol that allows the merge engine
 * some control over the loop.  If you create your own loop, instead of
 * using a MiscMergeDriver instance, some of the merge commands such as
 * "next" will be ignored rather than performing the desired function.
 * 
 * To use a MiscMergeDriver you must provide it with a template, objects to
 * merge into the template, and, optionally, a MiscMergeEngine instance. If
 * a MiscMergeEngine is  not provided, one will be created to perform the
 * merge.  To set up a merge template, use the -#{setTemplate:} method. It
 * expects an instance of the MiscMergeTemplate class, which comes from an
 * ASCII file or from a MiscString object.
 * 
 * The data to be merged into the template is set up using the
 * -#{setMergeData:} method.  The data is an NSArray of objects, one object
 * for each merge to be performed.
 * 
 * Finally, use the -#{doMerge:} method to perform the desired merge
 * operation.  The results will be returned as an NSArray object with a
 * NSString corresponding to each object in the NSArray provided to the
 * MiscMergeDriver by the most recent -#{setMergeData:} message.  For
 * example, the third NSString will contain the results from the merge with
 * the third object in the NSArray.  If the merge returned no result (due
 * to an error or an "omit" command, for example) then the NSString will be
 * empty.
 * 
 * If you wish to use a specific subclass of MiscMergeEngine to perform the
 * merge, then use the -#{setEngine:} method to set up the engine before
 * calling -#{doMerge:}.  This engine will be used for all subsequent
 * merges unless -#{setEngine:} is sent again.
 * 
 * For more information, please see the IntroMiscMerge.rtfd document. It
 * describes the syntax of the merge language and built-in commands
 * available.  The MiscMergeArchitecture.rtfd document describes the
 * architecutre of the various classes used to perform merging operations
 * and how to add custom commands to the framework.
"*/


/*"
 * Sets the MiscMergeTemplate that will be used for the next merge.  The
 * template will not be set if a merge is in progress.
"*/
- (void)setMergeTemplate:(MiscMergeTemplate *)aTemplate
{
    if (([self isMerging] == NO) && ([self mergeTemplate] != aTemplate))
    {
        _mergeTemplate = aTemplate;
    }
}

/*"
 * Sets the NSArray of objects that will be used for the next merge.  The
 * data will not be set if a merge is in progress.
"*/
- (void)setMergeData:(NSArray *)aList
{
    if (([self isMerging] == NO) && ([self mergeData] != aList))
    {
        _mergeData = aList;
    }
}

/*"
 * Sets up an engine to be used for merging.  If no engine is set, a
 * temporary engine will be created before and destroyed after a merge.
 * Engines set using -#{setEngine:} will not be destroyed at the end of a
 * merge and will be used for subsequent merges as well. Setting the engine
 * to nil will revert to the default create/use/destroy pattern.  The
 * engine cannot be changed while a merge loop is in progress.
"*/
- (void)setEngine:(MiscMergeEngine *)anEngine
{
    if (([self isMerging] == NO) && ([self engine] != anEngine))
    {
        _engine = anEngine;
    }
}

/*"
 * Sets up a merge engine, if necessary, and performs a merge of the
 * template with the objects in the dataArray.  Any engines created will be
 * destroyed after the merge; engines set using -#{setEngine} will persist,
 * however.  An NSArray object populated with NSStrings will be returned.
 * There is a one-to-one correspondence between the index of the return
 * NSStrings in the NSArray and the objects' indices in the NSArray that
 * was provided via the most recent -#{setMergeData:}.  Thus, if there were
 * six dictionaries used for merging, six NSStrings will be returned, as
 * the result of six merges.  Note that the "next" command will cause a
 * MiscMergeEngine to attempt to skip forward to the next data object,
 * while still performing a single merge.  In this case, an empty NSString
 * will be inserted in the output array as a placeholder and the final
 * merge result will be put in the slot corresponding to the last
 * object used.  Merges that fail or are halted due to an "omit"
 * command will also be represented by an empty NSString in the output.
"*/
- (NSArray *)doMerge:sender
{
    BOOL createdEngine = NO;
    NSMutableArray *output = nil;
    NSArray *dataArray = [self mergeData];

    if ([self isMerging] == YES) return nil; // not re-entrant!!!
    if (([self mergeTemplate] == nil && [self engine] == nil) || mm_IsEmpty(dataArray)) return nil;

    if ([self engine] == nil)
    {
        createdEngine = YES;
        [self setEngine:[[MiscMergeEngine alloc] initWithTemplate:[self mergeTemplate]]];
    }

    [self setMerging:YES];
    output = [NSMutableArray arrayWithCapacity:[dataArray count]];

    for (_mergeLoopIndex=0; _mergeLoopIndex < [[self mergeData] count]; _mergeLoopIndex++)
    {
        id       inputObject = [dataArray objectAtIndex:_mergeLoopIndex];
        NSString *outString  = [[self engine] executeWithObject:inputObject sender:self];

        while (_mergeLoopIndex > [output count] /*&& _mergeLoopIndex < [dataArray count] hmm */) {
            [output addObject:@""]; // placeholder for skipped
        }

        if (outString != nil) [output addObject:outString];
        else [output addObject:@""]; // placeholder if failed
    }

    [self setMerging:YES];
    if (createdEngine) // don't keep it hanging around
    {
        [self setEngine:nil];
    }
    return output;
}

/*"
 * During a merge, returns the next object that will be merged and advances
 * the merge loop.  Returns nil if not merging or if the loop is already
 * performing the last merge.
"*/
- (id)advanceRecord
{
    id nextObject = nil;

    if (([self isMerging] == NO) || (_mergeLoopIndex >= [[self mergeData] count])) return nil;

    _mergeLoopIndex++;

    if (_mergeLoopIndex < [[self mergeData] count])
    {
        nextObject = [[self mergeData] objectAtIndex:_mergeLoopIndex];
    }
    [[self engine] setMainObject:nextObject];
    return nextObject;
}

/*"
 * During a merge, returns the object that is currently being merged.
 * Returns nil otherwise.
"*/
- (id)currentObject
{
    if ([self isMerging] == NO) return nil;
    if (_mergeLoopIndex >= [[self mergeData] count]) return nil;
    return [[self mergeData] objectAtIndex:_mergeLoopIndex];
}

@end
