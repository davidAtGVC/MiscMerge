//
//  MiscMergeEngine.m
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

#import "MiscMergeEngine.h"
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import "MiscMergeTemplate.h"
#import "MiscMergeCommand.h"
#import "MiscMergeCommandBlock.h"
#import "KeyValue+MiscMerge.h"
#import "MiscMergeFunctions.h"

#define RECURSIVE_LOOKUP_LIMIT 100

/*
 * We can't #import a header, since we could be using either MiscKeyValue,
 * EOControl, or (on MacOS X) Foundation.
 */
@interface NSObject (WarningAvoidance)
- (id)valueForKeyPath:(NSString *)keyPath;
@end


@interface MiscMergeEngine ()
@property (strong, nonatomic, readwrite) NSMutableDictionary *userInfo;
@property (strong, nonatomic) NSMutableDictionary *engineSymbols;
@property (strong, nonatomic) NSMutableDictionary *mergeSymbols;
@property (strong, nonatomic) NSMutableDictionary *localSymbols;
@property (strong, nonatomic) NSMutableArray  	*contextStack;
@property (strong, nonatomic) NSMutableArray  	*commandStack;
@property (strong, nonatomic) NSMutableString 	*outputBuffer;
@property (assign, nonatomic) BOOL aborted;
@property (weak, nonatomic) id driver;
@end


@implementation MiscMergeEngine
/*"
 * A MiscMergeEngine is the heart of the merging object suite.  It actually
 * performs the merges.  To use it, simply give it a MiscMergeTemplate that
 * has been properly set up with -#{setTemplate:}.  Next, give it a data
 * object (-#{setMainObject:}) that has values for the contents of the
 * merge fields.  Finally, send an -#{execute:} message to start things
 * off.  -#valueForKeyPath: will be called on the main object with the
 * field names in the template, and the values returned will be substituted
 * in the output. An NSString will be returned that contains the results of
 * the merge.
 * 
 * The rest of the methods are an API to the internal state of the engine
 * which may be used in MiscMergeCommand subclass implementations.
 * 
 * To implement MiscMergeCommands, it is important to understand some of
 * the internals of the MiscMergeEngine class.
 * 
 * The main thing to know is that there is an "output" string that is kept
 * throughout the merge and returned at the end.  MiscMergeCommands should
 * append strings to it as necessary with the -#{appendToOutput:} method.
 * 
 * The MiscMergeEngine resolves field names through a series of symbol
 * tables.  Commands can request that arguments be "resolved" through these
 * symbol tables with the -#{valueForField:} method. The process is to walk
 * down the context stack until an object with the desired key is found.
 * The search will look first for local variables, then on the main object,
 * then in the engine variables, and finally in the global variables.  If
 * any context objects are placed on the stack by MiscMergeCommands, they
 * are searched first. If the key is not found, then the "parent" merge, if
 * it exists, is consulted. If the key is not found, then the key itself is
 * returned.
 * 
 * If recursive lookups are turned on, the value returned by a lookup will
 * be used as a field name and the lookup repeated, causing an indirection
 * to take place (if a value is found for the new field name). This process
 * will be repeated as far as possible, so there can be multiple levels of
 * indirection.  Use the -#setUseRecursiveLookups: method to turn this
 * feature on or off.
 * 
 * By doing this extensive resolution, it is possible to use
 * MiscMergeCommands to create aliases for field names.  It is also
 * possible to use the global tables to contain "default" values for any
 * merge fields that might turn up empty on a particular merge.  Note that
 * there are specific methods which may be used to manipulate the local,
 * engine, and global symbol tables, as well as set up the parent merge.
 * 
 * Another special feature of the MiscMergeEngine is that it can carry
 * internal "variables" in its userInfo dictionary.  A variable is some
 * object that contains state and needs to be accessible throughout a
 * merge.  This is useful for groups of MiscMergeCommands that need to pass
 * information between each other, but do not specifically know about each
 * other.  Simply manipulate the userInfo dictionary (returned by the
 * -#userInfo method) to store or retrieve information as desired.  The
 * userInfo dictionary is not consulted during symbol lookups, and is
 * cleared at the start of a new merge, so only data pertaining to a merge
 * should be stored there.  This is the preferred way for MiscMergeCommands
 * to communicate with each other.
 * 
 * The current API should be adequate to perform most things a
 * MiscMergeCommand would want to do.  However, it is possible that more
 * functionality would be helpful or that some bit of information is still
 * inaccessible.  If this is the case, complain to the author (Don
 * Yacktman, don@misckit.com) and he will consider enhancing the API to
 * this object as necessary.  Of course, subclasses and categories might
 * also be workable approaches to such deficiencies.
"*/

static NSMutableDictionary *globalSymbols = nil;

/*"
 * Returns the static NSMutableDictionary used to store global symbols.
 * Global symbols are the last context searched when resolving names, and
 * are valid for every merge done in your program (i.e. the same dictionary
 * is used in all MiscMergeEngine instances).
"*/
+ (NSMutableDictionary *)globalSymbolsDictionary
{
    static dispatch_once_t globalSymbolsDictionaryDispatch;
	dispatch_once(&globalSymbolsDictionaryDispatch, ^{
        globalSymbols = [[NSMutableDictionary alloc] init];
    });
    return globalSymbols;
}

/*"
 * Sets the global symbol aKey to anObject.  A value of nil is the same as
 * removing the value.
"*/
+ (void)setGlobalValue:(id)anObject forKey:(NSString *)aKey
{
    if (anObject == nil)
        [self removeGlobalValueForKey:aKey];
    else
        [[self globalSymbolsDictionary] setObject:anObject forKey:aKey];
}

/*" Removes the global value associated with aKey. "*/
+ (void)removeGlobalValueForKey:(NSString *)aKey
{
    [[self globalSymbolsDictionary] removeObjectForKey:aKey];
}

/*" Returns the global value for aKey. "*/
+ (id)globalValueForKey:(NSString *)aKey
{
    return [globalSymbols objectForKey:aKey];
}


/*" The designated initializer. "*/
- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setUserInfo:[[NSMutableDictionary alloc] init]];
        [self setEngineSymbols:[[NSMutableDictionary alloc] init]];
        [self setMergeSymbols:[[NSMutableDictionary alloc] init]];
        [self setLocalSymbols:[self mergeSymbols]];
        [self setContextStack:[[NSMutableArray alloc] init]];
        [self setCommandStack:[[NSMutableArray alloc] init]];
    }
    return self;
}

/*"
 * Initializes a new MiscMergeEngine instance, setting the current template
 * to %{aTemplate}.
"*/
- initWithTemplate:(MiscMergeTemplate *)aTemplate
{
    self = [self init];
    if ( self != nil )
    {
        [self setMergeTemplate:aTemplate];
    }
    return self;
}

/*"
 * Set whether to use recursive lookups when resolving field names.
 * setUseRecursiveLookup
"*/
- (void)setUseRecursiveLookups:(BOOL)shouldRecurse
{
    _useRecursiveLookups = shouldRecurse;
    [self setRecursiveLookupLimit:RECURSIVE_LOOKUP_LIMIT];
}


- (void)setUseRecursiveLookups:(BOOL)shouldRecurse limit:(NSInteger)recurseLimit
{
    [self setUseRecursiveLookups:shouldRecurse];
    [self setRecursiveLookupLimit:recurseLimit];
}



/*"
 * Returns the output string from the latest merge, the same string
 * returned by the -#execute: method.
"*/
- (NSString *)outputString
{
    return [self outputBuffer];
}


/*" An instance method convenience for +#setGlobalValue:forKey:. "*/
- (void)setGlobalValue:(id)anObject forKey:(NSString *)aKey
{
    [[self class] setGlobalValue:anObject forKey:aKey];
}
/*" An instance method convenience for +#removeGlobalValueForKey:. "*/
- (void)removeGlobalValueForKey:(NSString *)aKey
{
    [[self class] removeGlobalValueForKey:aKey];
}
/*" An instance method convenience for +#globalValueForKey:. "*/
- (id)globalValueForKey:(NSString *)aKey
{
    return [[self class] globalValueForKey:aKey];
}


/*"
 * Sets the engine symbol aKey to anObject.  A value of nil is the same as
 * removing the value.  The engine symbols are searched after the main
 * object but before the global symbols when resolving a name.  They remain
 * valid for every merge executed by the receiving MiscMergeEngine instance.
"*/
- (void)setEngineValue:(id)anObject forKey:(NSString *)aKey
{
    if (anObject)
        [[self engineSymbols] setObject:anObject forKey:aKey];
    else
        [self removeGlobalValueForKey:aKey];
}

/*" Removes the engine value associated with aKey "*/
- (void)removeEngineValueForKey:(NSString *)aKey
{
    [[self engineSymbols] removeObjectForKey:aKey];
}
/*" Returns the engine value associated with aKey "*/
- (id)engineValueForKey:(NSString *)aKey
{
    return [[self engineSymbols] objectForKey:aKey];
}


/*"
 * Sets the merge symbol aKey to anObject.  A value of nil is the same as
 * removing the value.  The engine symbols are searched before the main
 * object when resolving a name.  Local symbols are only valid for the
 * current merge; the local symbol table is emptied before executing a
 * merge.
"*/
- (void)setMergeValue:(id)anObject forKey:(NSString *)aKey
{
    if (anObject)
        [[self mergeSymbols] setObject:anObject forKey:aKey];
    else
        [self removeMergeValueForKey:aKey];
}
/*" Removes the merge value associated with aKey "*/
- (void)removeMergeValueForKey:(NSString *)aKey
{
    [[self mergeSymbols] removeObjectForKey:aKey];
}
/*" Returns the merge value associated with aKey "*/
- (id)mergeValueForKey:(NSString *)aKey
{
    return [[self mergeSymbols] objectForKey:aKey];
}


/*"
 * Sets the local symbol aKey to anObject.  A value of nil is the same as
 * removing the value.  The engine symbols are searched before the main
 * object when resolving a name.  Local symbols are only valid for the
 * current merge; the local symbol table is emptied before executing a
 * merge.
"*/
- (void)setLocalValue:(id)anObject forKey:(NSString *)aKey
{
    if (anObject)
        [[self localSymbols] setObject:anObject forKey:aKey];
    else
        [self removeLocalValueForKey:aKey];
}
/*" Removes the local value associated with aKey "*/
- (void)removeLocalValueForKey:(NSString *)aKey
{
    [[self localSymbols] removeObjectForKey:aKey];
}
/*" Returns the local value associated with aKey "*/
- (id)localValueForKey:(NSString *)aKey
{
    return [[self localSymbols] objectForKey:aKey];
}


/*"
 * Adds a new context for symbol lookups.  MiscMergeCommands can use this
 * to add their own contexts to define variables that last only during the
 * execution of that command.
"*/
- (void)addContextObject:(id)anObject andSetLocalSymbols:(BOOL)flag
{
    [[self contextStack] addObject:anObject];

    if ( flag && [anObject isKindOfClass:[NSMutableDictionary class]] )
        [self setLocalSymbols:anObject];
}

- (void)addContextObject:(id)anObject
{
    [self addContextObject:anObject andSetLocalSymbols:NO];
}

/*" Removes anObject from the context stack. "*/
- (void)removeContextObject:(id)anObject
{
    if (anObject && anObject != [self mainObject]
        && anObject != globalSymbols
        && anObject != [self engineSymbols]
        && anObject != [self mergeSymbols])
    {
        // should only remove last occurrence, not all FIXME
        [[self contextStack] removeObjectIdenticalTo:anObject];

        if ( anObject == [self localSymbols] ) {
            NSInteger i;

            [self setLocalSymbols:nil];

            for ( i = [[self contextStack] count] - 1; i >= 0; i-- ) {
                id object = [[self contextStack] objectAtIndex:i];

                if ( [object isKindOfClass:[NSMutableDictionary class]] ) {
                    [self setLocalSymbols:object];
                    break;
                }
            }

            if ( [self localSymbols] == nil ) {
                [self setLocalSymbols:[self mergeSymbols]];
            }
        }
    }
}

/*"
 * Sets the main data object.  The next invocation of -#{execute:} will use
 * %{anObject} as the main data object for the merge.  Can be called during
 * a merge to change the main object.
"*/
- (void)setMainObject:(id)anObject
{
    NSUInteger oldIndex = NSNotFound;

    if (_mainObject != nil)
    {
        oldIndex = [[self contextStack] indexOfObject:_mainObject];
        if (oldIndex != NSNotFound)
            [[self contextStack] removeObjectAtIndex:oldIndex];
    }

    /* Insert the new object; if there was no previous object put before local symbols. */
    if (anObject != nil)
    {
        if (oldIndex == NSNotFound)
            oldIndex = [[self contextStack] indexOfObject:[self mergeSymbols]];

        if (oldIndex != NSNotFound)
            [[self contextStack] insertObject:anObject atIndex:oldIndex];
    }

    _mainObject = anObject;
}


- (NSString *)execute:sender
{
    [self setDriver:sender];
    [self setAborted:NO];
    [self setOutputBuffer:[NSMutableString string]];
    [[self contextStack] removeAllObjects];
    [[self commandStack] removeAllObjects];
    [[self mergeSymbols] removeAllObjects];

    [[self contextStack] addObject:[[self class] globalSymbolsDictionary]];
    [[self contextStack] addObject:[self engineSymbols]];
    if ([self mainObject] != nil)
        [[self contextStack] addObject:[self mainObject]];
    
    [[self contextStack] addObject:[self mergeSymbols]];

    [self executeCommandBlock:[[self mergeTemplate] topLevelCommandBlock]];

    [self setDriver:nil];

    if ([self aborted] ==  YES)
        return @"";
    
    return [self outputString];
}

/*"
 * Initiates a merge with the current template and %{anObject}.  Returns an
 * NSString containing the output of the merge if successful and nil
 * otherwise.  The argument %{sender} should be the initiating driver.  If
 * not, some commands, such as "next" will not work properly.  This method
 * is just a convenience method that calls -#setMainObject: and then
 * -#execute:.
"*/
- (NSString *)executeWithObject:(id)anObject sender:sender
{
    [self setMainObject:anObject];
    return [self execute:sender];
}

/*"
 * Executes a single command.  MiscMergeCommand subclasses should always
 * call this method instead of calling -executeForMerge: on the command
 * itself if they need to execute a command.
"*/
- (MiscMergeCommandExitType)executeCommand:(MiscMergeCommand *)command
{
    /*
     * Just execute the command.  This is meant to be a hook where we can
     * insert other stuff to be done on each command execution, such as
     * logging for debug purposes.
     */
    return [command executeForMerge:self];
}

/*"
 * Executes all the commands in block.  MiscMergeCommand subclasses should
 * use this method when they need to execute a command block.  A local
 * autorelease pool is used during execution of the block.
"*/
- (MiscMergeCommandExitType)executeCommandBlock:(MiscMergeCommandBlock *)block
{
    NSArray *commandArray = [block commandArray];
    NSInteger i, count = [commandArray count];
    MiscMergeCommandExitType exitCode = MiscMergeCommandExitNormal;
    /*
     * Maintain the execution stack.  This stack isn't being used at the
     * moment, but command implementations may in the future make use of it
     * (a break command, for example).
     */
    [[self commandStack] addObject:block];

    for (i=0; (exitCode == MiscMergeCommandExitNormal) && (i<count); i++)
    {
        exitCode = [self executeCommand:[commandArray objectAtIndex:i]];
    }

    [[self commandStack] removeLastObject];
    return exitCode;
}

- (id)valueForField:(NSString *)fieldName quoted:(NSInteger)quoted
{
    NSInteger  i;
    id   value = nil;
    id   prevValue = nil;
    id   returnValue = nil;
    BOOL found = NO;
    BOOL prevFound = NO;
    NSInteger lookupCount = 0;

    if ( quoted == 1 )
        return fieldName;

    for (i=[[self contextStack] count]; i > 0 && !found; i--)
    {
        id currContext = [[self contextStack] objectAtIndex:i-1];

        if ([currContext mm_hasMiscMergeKeyPath:fieldName])
        {
            value = [currContext valueForKeyPath:fieldName];
            found = YES;
        }

        /*
         * If recursive lookup is on, use the current value as a fieldName
         * and restart the search.  Store the last found value, so we know
         * which one to return.
         */
        if (found && [self useRecursiveLookups] && (lookupCount < [self recursiveLookupLimit]) && [value isKindOfClass:[NSString class]])
        {
            fieldName = value;
            prevValue = value;
            prevFound = YES;
            found = NO;
            i = [[self contextStack] count];
            lookupCount++;
        }
        else if ( [self useRecursiveLookups] && (lookupCount >= [self recursiveLookupLimit]) )
        {
            NSLog(@"Recursion limit %ld reached for %@.", (long)[self recursiveLookupLimit], fieldName);
        }
    }

    if (value == [NSNull null]) value = nil;

    /* If we found it, return it. */
    if (found) returnValue = value;

    /* If the previous iteration of the recursive search found it, return it */
    else if (prevFound) returnValue = prevValue;

    if ( found || prevFound ) {
        if ( returnValue == nil ) {
            switch ( [self nilLookupResult] )
            {
                case MiscMergeNilLookupResultKeyIfQuoted:
                    if ( quoted == 2 )
                        returnValue = fieldName;
                    break;
                    
                case MiscMergeNilLookupResultKey:
                    returnValue = fieldName;
                    break;
                    
                case MiscMergeNilLookupResultKeyWithDelims:
                    returnValue = [NSString stringWithFormat:@"%@%@%@", [[self mergeTemplate] startDelimiter], fieldName, [[self mergeTemplate] endDelimiter]];
                    break;

                default:
                    break;
            }
        }

        return returnValue;
    }

    /* If not found, try our parent merge */
    if ([self parentMerge] != nil)
        return [[self parentMerge] valueForField:fieldName quoted:quoted];

    switch ( [self failedLookupResult] )
    {
        case MiscMergeFailedLookupResultKeyWithDelims:
            return [NSString stringWithFormat:@"%@%@%@", [[self mergeTemplate] startDelimiter], fieldName, [[self mergeTemplate] endDelimiter]];

        case MiscMergeFailedLookupResultNil:
            return nil;
            
        case MiscMergeFailedLookupResultKeyIfNumeric:
            return MMIsObjectANumber(fieldName) ? fieldName : nil;

        case MiscMergeFailedLookupResultKey:
        default:
            return fieldName;
    }
}

- (id)valueForField:(NSString *)fieldName
{
    return [self valueForField:fieldName quoted:0];
}

/*"
 * Appends %{aString} to the merge output.
"*/
- (void)appendToOutput:(NSString *)aString
{
    if ( aString != nil )
    {
        [[self outputBuffer] appendString:[aString description]];
    }
}

- (void)abortMerge
{
    [self setAborted:YES];
}

- (void)advanceRecord
{
    id driver = [self driver];
    if ([driver respondsToSelector:@selector(advanceRecord)] == YES)
    {
        [driver advanceRecord];
    }
}

@end
