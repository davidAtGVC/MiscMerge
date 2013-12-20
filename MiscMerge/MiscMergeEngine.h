//
//  MiscMergeEngine.h
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

#import <Foundation/NSObject.h>

@class NSMutableString, NSMutableArray, NSMutableDictionary;
@class MiscMergeTemplate, MiscMergeCommand, MiscMergeCommandBlock;

typedef NS_ENUM(NSUInteger, MiscMergeCommandExitType)
{
    MiscMergeCommandExitNormal,
    MiscMergeCommandExitBreak,
    MiscMergeCommandExitContinue
};

typedef NS_ENUM (NSUInteger, MiscMergeFailedLookupResultType)
{
    MiscMergeFailedLookupResultKey,
    MiscMergeFailedLookupResultKeyWithDelims,
    MiscMergeFailedLookupResultNil,
    MiscMergeFailedLookupResultKeyIfNumeric
};

typedef NS_ENUM(NSUInteger, MiscMergeNilLookupResultType)
{
    MiscMergeNilLookupResultNil,
    MiscMergeNilLookupResultKeyIfQuoted,
    MiscMergeNilLookupResultKey,
    MiscMergeNilLookupResultKeyWithDelims
};

@interface MiscMergeEngine : NSObject

/*" Initializing "*/
- init;
- initWithTemplate:(MiscMergeTemplate *)aTemplate;

/*" Setting/getting attributes "*/
@property (strong, nonatomic, readonly) NSMutableDictionary *userInfo;

/*" Accessing the template "*/
@property (strong, nonatomic) MiscMergeTemplate *mergeTemplate;

/*"
 * the "parent" merge for this merge engine.  If a symbol cannot be
 * found in the receiving instance's symbol table during lookup, the parent
 * will be consulted to see if it is defined there.
 "*/
@property (strong, nonatomic) MiscMergeEngine *parentMerge;

/*" Returns the main data object to be used in the next merge. "*/
@property (strong, nonatomic) id mainObject;

/*"
 * Returns YES if recursive lookups are being used.  During symbol
 * resolution, if a resolved value is an NSString object and recursive
 * lookups are turned on, then the value is used as a key itself and the
 * symbol lookup is repeated.  This process repeats until a value is not
 * found or it's not an NSString object, at which point the last valid
 * value will be returned.  This allows for multiple levels of indirection.
 * Be careful when using this feature, as it can lead to unexpected
 * problems.  For example, if the main object is not a dictionary,
 * returning a string that has the same name as a method on that object
 * (such as "description" or "zone") can lead to interesting (unintended)
 * results or even exceptions being raised.  Also, if an indirect value is
 * the same as a previously-resolved key, then the merge engine will go
 * into an infinite loop. By default, recursive lookups are turned off.
 "*/
@property (assign, nonatomic) BOOL useRecursiveLookups;
@property (assign, nonatomic) NSInteger recursiveLookupLimit;
- (void)setUseRecursiveLookups:(BOOL)shouldRecurse limit:(NSInteger)recurseLimit;

@property (assign, nonatomic) BOOL keepsDelimiters;

@property (assign, nonatomic) MiscMergeFailedLookupResultType failedLookupResult;
@property (assign, nonatomic) MiscMergeNilLookupResultType nilLookupResult;


/*" Manipulating context variables "*/
+ (NSMutableDictionary *)globalSymbolsDictionary;
+ (void)setGlobalValue:(id)anObject forKey:(NSString *)aKey;
+ (void)removeGlobalValueForKey:(NSString *)aKey;
+ (id)globalValueForKey:(NSString *)aKey;
- (void)setGlobalValue:(id)anObject forKey:(NSString *)aKey;
- (void)removeGlobalValueForKey:(NSString *)aKey;
- (id)globalValueForKey:(NSString *)aKey;

- (void)setEngineValue:(id)anObject forKey:(NSString *)aKey;
- (void)removeEngineValueForKey:(NSString *)aKey;
- (id)engineValueForKey:(NSString *)aKey;

- (void)setMergeValue:(id)anObject forKey:(NSString *)aKey;
- (void)removeMergeValueForKey:(NSString *)aKey;
- (id)mergeValueForKey:(NSString *)aKey;

- (void)setLocalValue:(id)anObject forKey:(NSString *)aKey;
- (void)removeLocalValueForKey:(NSString *)aKey;
- (id)localValueForKey:(NSString *)aKey;

/*"
 * Performs a merge using the current data object and template.  If
 * successful, then an NSString containing the results of the merge is
 * returned.  If unsuccessful, nil is returned.  The argument %{sender}
 * should be the initiating driver.  If not, some commands, such as "next"
 * will not work properly.
 "*/
- (NSString *)execute:sender;
- (NSString *)executeWithObject:(id)anObject sender:sender;

/*" Getting the output "*/
- (NSString *)outputString;

/*" Primitives that may be used by MiscMergeCommands "*/
- (MiscMergeCommandExitType)executeCommand:(MiscMergeCommand *)command;
- (MiscMergeCommandExitType)executeCommandBlock:(MiscMergeCommandBlock *)block;
- (void)addContextObject:(id)anObject andSetLocalSymbols:(BOOL)flag;
- (void)addContextObject:(id)anObject;
- (void)removeContextObject:(id)anObject;

/*"
 * Attempts to resolve a field name, by going down the context stack until
 * an object containing that key is found, at which point the
 * -#valueForKeyPath: is returned, thus treating the fieldName as a key
 * path.  If recursive lookups are turned on, then a resolved value that is
 * an NSString objects is treated as a field name, and the lookup process
 * is started again.  This will be repeated until a value is not found or
 * the resolved value is not an NSString object, at which point the last
 * valid result will be returned. If the field name is not found at all,
 * then the field string itself is returned (unless keepDelimiters is set
 * to YES, in which case the field string surrounded by the original field
 * delimiters will be returned).
 "*/
- (id)valueForField:(NSString *)fieldName;
- (id)valueForField:(NSString *)fieldName quoted:(NSInteger)quoted;

- (void)appendToOutput:(NSString *)aString;

/*"
 * Aborts the current merge.  This means that the merge output will be nil,
 * as well.
 "*/
- (void)abortMerge;

/*"
 * Attempts to advance to the next merge object while still working with
 * the current output string.  This might be used to allow two merges to
 * appear on the same "page" or document, for example. For it to work
 * properly, the driver that started the merge must respond to the
 * -#{advanceRecord} method.
 "*/
- (void)advanceRecord;

@end
