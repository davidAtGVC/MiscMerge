//
//  MiscMergeTemplate.m
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

#import "MiscMergeTemplate.h"
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSObjCRuntime.h>
#import "NSString+MiscAdditions.h"
#import "NSScanner+MiscMerge.h"
#import "MiscMergeCommand.h"
#import "MiscMergeCommandBlock.h"
#import "_MiscMergeFieldCommand.h"
#import "_MiscMergeCopyCommand.h"
#import "_MiscMergeDelayedParseCommand.h"
#import "MiscMergeFunctions.h"
#import "MiscMergeMacros.h"

@interface MiscMergeTemplate ()
@property (strong, nonatomic, readwrite) MiscMergeCommandBlock *topLevelCommandBlock;
@property (strong, nonatomic) NSMutableArray *commandStack;
@property (assign, nonatomic) NSUInteger lineNumber;
@end


@implementation MiscMergeTemplate
/*"
 * This class contains the template that is used by a merge engine. It
 * performs two functions:  (1) parse a string or text file into the
 * commands required by a merge ending and (2) act as a container for the
 * commands once they have been parsed, providing them to a merge engine as
 * needed.
 *
 * Typically, MiscMergeTemplate objects are used in a very simple way: they
 * are instantiated, given the ASCII text or string to parse, and then
 * passed to MiscMergeEngine instances as needed.  That's it!
 *
 * It should be noted that template text which is simply copied from the
 * template into the merged output (i.e. any text outside of a merge
 * command) is actually turned into a special "copy" command by the parsing
 * algorithm. This allows the merge engine to deal exclusively with
 * MiscMergeCommand subclasses to perform a merge.  This implementation
 * detail should not affect anything that would normally be done with this
 * object, but it is important to understand this fact if attempting to
 * understand the data structure created by the parsing routines.
 *
 * If a command string contains merge commands inside itself, then a
 * special "delayed command" class will used.  That class will, during a
 * merge, create an engine, perform a merge on its text, and then parse
 * itself into the correct type of command.  This allows merges to contain
 * commands that change depending upon the data records.
 *
 * Commands created while parsing are always added to the "current" command
 * block.  By using -#pushCommandBlock: and -#popCommandBlock,
 * MiscMergeCommand subclasses can temporarily substitute their own command
 * block to be the "current" block during the parsing process.  This way,
 * container-type commands such as if clauses and loops can know which
 * commands they hold.
"*/

/*"
 * Returns the default string used to start a merge command, "«".  A
 * subclass of MiscMergeTemplate could override this method.
"*/
+ (NSString *)defaultStartDelimiter
{
    //	return @"(";
    //	return @"«";
    /* This works better for whatever reason. Due to some unknown pecularities,
    a constant NSString doesn't work under Windows with Apple's
    implementation. 
     Unicode character      Oct     Dec	Hex     HTML
     «	acute accent        0264	180	0xB4	&acute;
     */
    unichar achar = 0xB4;
    return [NSString stringWithCharacters:&achar length:1];
}

/*"
 * Returns the default string used to end a merge command, "»".  A
 * subclass of MiscMergeTemplate could override this method.
"*/
+ (NSString *)defaultEndDelimiter
{
    //	return @")";
    //	return @"»";
    /* This works better than a constant NSString for whatever reason.  See above. 
     Unicode character              Oct     Dec	Hex     HTML
     » feminine ordinal indicator	0252	170	0xAA	&ordf;
     */
    unichar achar = 0xAA;
    return [NSString stringWithCharacters:&achar length:1];
}

/*" Creates a new, autoreleased MiscMergeTemplate. "*/
+ (instancetype)template
{
    return [[self alloc] init];
}

/*"
 * Creates a new, autoreleased MiscMergeTemplate, and parses aString.
"*/
+ (instancetype)templateWithString:(NSString *)aString
{
    return [[self alloc] initWithString:aString];
}

/*"
 * Initializes the MiscMergeTemplate instance and returns self.  This is
 * the designated initializer.  The start and end delimiters are set to the
 * values returned by +#defaultStartDelimiter and +#defaultEndDelimiter.
"*/
- init
{
    self = [super init];
    if ( self != nil )
    {
        [self setTopLevelCommandBlock:[[MiscMergeCommandBlock alloc] init]];
        [self setCommandStack:[NSMutableArray arrayWithObject:[self topLevelCommandBlock]]];
        [self setStartDelimiter:[[self class] defaultStartDelimiter]];
        [self setEndDelimiter:[[self class] defaultEndDelimiter]];
    }
    return self;
}

/*"
 * Initializes the MiscMergeTemplate, then parses string.
"*/
- initWithString:(NSString *)string
{
    self = [self init];
    if ( self != nil)
    {
        [self parseString:string];
    }
    return self;
}

/*"
 * Loads the contents of filename, then calls -#initWithString:.
"*/
- initWithContentsOfFile:(NSString *)filename
{
    self = [self init];
    if ( self != nil)
    {
        [self parseContentsOfFile:filename];
    }
    return self;
}


/*"
 * Pushes aBlock on the command stack.  aBlock becomes the current command
 * block until popped off (or another block is placed on top of it).
"*/
- (void)pushCommandBlock:(MiscMergeCommandBlock *)aBlock
{
    [[self commandStack] addObject:aBlock];
}

/*"
 * Pops the command block aBlock off of the command stack, so the previous
 * command block will again be the "current" command block.  If aBlock is
 * not at the top of the command stack, logs an error and does nothing.
 * Basically the same as -#popCommandBlock except it does the extra sanity
 * check.
"*/
- (void)popCommandBlock:(MiscMergeCommandBlock *)aBlock
{
    if (aBlock && [[self commandStack] lastObject] != aBlock)
    {
        [self reportParseError:@"Error, command stack mismatch"];
        return;
    }

    [self popCommandBlock];
}

/*"
 * Pops the top command block off the command stack, so the previous
 * command block will again be the "current" command block.
"*/
- (void)popCommandBlock
{
    if ([[self commandStack] count] <= 1)
    {
        [self reportParseError:@"Error, cannot pop last command block"];
        return;
    }

    [[self commandStack] removeLastObject];
}

/*"
 * Returns the "current" command block, i.e. the command block at the top
 * of the command stack.  As they are parsed, commands are always added to
 * the command block returned by this method.
"*/
- (MiscMergeCommandBlock *)currentCommandBlock
{
    return [[self commandStack] lastObject];
}

- (NSString *)resolveTemplateFilename:(NSString *)resolveName
{
    NSString *resolvedName = nil;
    id delegate = [self delegate];
    
    if ( [delegate respondsToSelector:@selector(mergeTemplate:resolveTemplateFilename:)] )
        resolvedName = [delegate mergeTemplate:self resolveTemplateFilename:resolveName];

    return ( [resolvedName length] > 0 ) ? resolvedName : resolveName;
}
        

- (Class)_classForCommand:(NSString *)realCommand
{
    NSString *className = [NSString stringWithFormat:@"MiscMerge%@Command", realCommand];
    Class theClass = NSClassFromString(className);

    if (theClass == Nil)
    {
        className = [NSString stringWithFormat:@"_MiscMerge%@Command", realCommand];
        theClass = NSClassFromString(className);
    }

    if (theClass == Nil)
    {
        theClass = [self classForCommand:@"Field"];
    }

    return theClass;
}

- (Class)classForCommand:(NSString *)aCommand
{
    return [self _classForCommand:[[aCommand mm_firstWord] capitalizedString]];
}


/*"
 * Reports the given error message, prefixed with filename and current line
 * number.
"*/
- (void)reportParseError:(NSString *)format, ...
{
    NSString *errorMessage;
    va_list args;

    va_start(args, format);
    errorMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    if ([self filename] != nil)
        NSLog(@"%@: %lu: %@", [self filename], (unsigned long)[self lineNumber], errorMessage);
    else
        NSLog(@"Line %lu: %@", (unsigned long)[self lineNumber], errorMessage);
}

- (void)_addCommand:(MiscMergeCommand *)command
{
    [[self currentCommandBlock] addCommand:command];
}

- (void)_addBetweenString:(NSString *)betweenString
{
    NSString *copyString = betweenString;

    switch ( [self trimWhitespaceBehavior] )
    {
        case MiscMergeKeepNonBlankWhitespace:
            if ( [betweenString mm_isBlank] )
                copyString = nil;
            break;
            
        case MiscMergeTrimWhitespace:
            copyString = [copyString mm_stringByTrimmingWhitespace];
            break;

        case MiscMergeIgnoreCommandSpaces:
            copyString = MMStringByTrimmingCommandSpace(copyString);
            break;
            
        default:
            break;
    }

    /* Check to see if we are ignoring completely blank space or wanting to trim
    the space off of between strings. In both cases we then see if the trimmed string
    would result in no data written to the output, then we don't do anything here. */
    if ( mm_IsEmpty(copyString) == NO )
    {
        id command = [[[self _classForCommand:@"Copy"] alloc] init];
        /* Pass the trimmed string, or the passed in string depending if we are trimming strings */
        [command parseFromRawString:copyString];
        [self _addCommand:command];
    }

    _lineNumber += [betweenString mm_numOfString:@"\n"];
}

- (void)_addCommandString:(NSString *)commandString
{
    Class commandClass = [self classForCommand:commandString];
    id command = [[commandClass alloc] init];
    [self _addCommand:command];
    [command parseFromString:commandString template:self];

    _lineNumber += [commandString mm_numOfString:@"\n"];
}

/*"
 * Loads the contents of filename and calls -#parseString:.
"*/
- (void)parseContentsOfFile:(NSString *)filename
{
    NSError *err = nil;
    NSString *contentString = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
    if ( err != nil )
    {
        NSLog(@"%@: Error reading template file %@\n%@", [self class], filename, err);
    }
    else if ( mm_IsEmpty(contentString) == YES)
    {
        NSLog(@"%@: Could not read template file or content blank %@", [self class], filename);
    }
    else
    {
        [self setFilename:filename];
        [self parseString:contentString];
    }
}

/*"
 * Parses the template in %{string}.
"*/
- (void)parseString:(NSString *)string
{
    NSMutableString *accumString = [[NSMutableString alloc] init];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSString *currString;
    NSString *startDelimiter = [self startDelimiter];
    NSString *endDelimiter = [self endDelimiter];
    NSInteger nestingLevel = 0;
    NSInteger maxNestingLevel = 0;
    BOOL inQuotes = NO;
    NSString *charString = [NSString stringWithFormat:@"\"\\%@%@", [startDelimiter substringToIndex:1], [endDelimiter substringToIndex:1]];
    NSCharacterSet *parseStopChars = [NSCharacterSet characterSetWithCharactersInString:charString];

    [scanner setCharactersToBeSkipped:nil];
    _lineNumber = 1;

    // may want to flush localPool every 50 loops or so...
    while (![scanner isAtEnd])
    {
        if ([scanner scanUpToCharactersFromSet:parseStopChars intoString:&currString])
            [accumString appendString:currString];

        if ([scanner mm_scanString:@"\\"])
        {
            BOOL     foundDelimiter;
            NSString *delimiter = nil;

            /* Look for the delimiters.  As a side effect, move scanner along */
            foundDelimiter = [scanner scanString:startDelimiter intoString:&delimiter] || [scanner scanString:endDelimiter intoString:&delimiter];

            /*
             * Leave the backslash if we are not quoting a delimiter string
             * -- we would wreak havoc on RTF template files otherwise.
             * Also leave the backslash if we are deeply nesting or inside
             * quotes, as those sections will get reduced later.
             */
            if (nestingLevel > 1 || (nestingLevel == 1 && inQuotes) || !foundDelimiter)
            {
                [accumString appendString:@"\\"];
            }

            if (foundDelimiter)
                [accumString appendString:delimiter];
        }
        else if ([scanner mm_scanString:@"\""])
        {
            [accumString appendString:@"\""];
            if (nestingLevel == 1) inQuotes = !inQuotes;
        }
        else if (nestingLevel > 0 && [scanner mm_scanString:endDelimiter])
        {
            if (nestingLevel > 1)
            {
                [accumString appendString:endDelimiter];
            }
            else
            {
                /* Special hack for the delayed parsing stuff. Hm. */
                if (maxNestingLevel > 1)
                {
                    id command = [[[self _classForCommand:@"DelayedParse"] alloc] init];
                    _lineNumber += [accumString mm_numOfString:@"\n"];
                    [command parseFromString:accumString template:self];
                    [self _addCommand:command];
                }
                else
                {
                    if ([accumString length] > 0)
                        [self _addCommandString:[accumString copy]];
                }
                [accumString setString:@""];
                inQuotes = NO;
                maxNestingLevel = 0;
            }

            nestingLevel--;
        }
        else if ([scanner mm_scanString:startDelimiter])
        {
            if (nestingLevel > 0)
            {
                [accumString appendString:startDelimiter];
            }
            else
            {
                if ([accumString length] > 0)
                    [self _addBetweenString:[accumString copy]];
                [accumString setString:@""];
            }

            nestingLevel++;
            if (nestingLevel > maxNestingLevel) maxNestingLevel = nestingLevel;
        }
        else if ([scanner mm_scanLetterIntoString:&currString])
        {
            // If we can scan the end delimiter, it's an error, otherwise
            // it's just a string that starts with the same char as a
            // delimiter.
            [accumString appendString:currString];
        }
    }

    if ([accumString length] > 0)
    {
        [self _addBetweenString:[accumString copy]];
    }
}

@end
