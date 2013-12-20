//
//  MiscMergeTemplate.h
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

@class NSMutableArray, NSCharacterSet;
@class MiscMergeCommandBlock;

typedef NS_ENUM(NSUInteger, MiscMergeTrimWhitespaceBehavior)
{
    MiscMergeKeepWhitespace,
    MiscMergeKeepNonBlankWhitespace,
    MiscMergeTrimWhitespace,
    MiscMergeIgnoreCommandSpaces
};

@interface MiscMergeTemplate : NSObject

/*" Creating a MiscMergeTemplate "*/
+ (instancetype)template;
+ (instancetype)templateWithString:(NSString *)aString;

/*" Initializing a MiscMergeTemplate "*/
- init;
- initWithString:(NSString *)string;
- initWithContentsOfFile:(NSString *)filename;

@property (weak, nonatomic) id delegate;

- (NSString *)resolveTemplateFilename:(NSString *)resolveName;

/*" Accessing/setting the delimiters "*/
+ (NSString *)defaultStartDelimiter;
+ (NSString *)defaultEndDelimiter;

@property (strong, nonatomic) NSString *startDelimiter;
@property (strong, nonatomic) NSString *endDelimiter;

/*" Change behavior of blank space between commands "*/
@property (assign, nonatomic) MiscMergeTrimWhitespaceBehavior trimWhitespaceBehavior;

/*" Command block manipulation "*/
- (void)pushCommandBlock:(MiscMergeCommandBlock *)aBlock;
- (void)popCommandBlock:(MiscMergeCommandBlock *)aBlock;
- (void)popCommandBlock;
- (MiscMergeCommandBlock *)currentCommandBlock;

/*"
 * Returns the "top level" command block of the MiscMergeTemplate, which is
 * basically the series of commands to be executed to generate the merge
 * file.  The top level block is always at the bottom of the command stack.
 "*/
@property (strong, nonatomic, readonly) MiscMergeCommandBlock *topLevelCommandBlock;

/*" Loading the template "*/
- (void)parseContentsOfFile:(NSString *)filename;
- (void)parseString:(NSString *)string;
- (void)reportParseError:(NSString *)format, ...;

/*"
 * the filename the template was created from, which is used in
 * reporting errors.  This is normally set by -#parseContentsOfFile:, but
 * this method can be used if -#parseString: needs to be called directly
 * but the original source did come from a file.
 "*/
@property (strong, nonatomic) NSString *filename;

/*"
 * Given the command string %{aCommand}, this method determines which
 * MiscMergeCommand subclass implements the merge command.  It returns the
 * class object needed to create instances of the MiscMergeCommand
 * subclass.
 *
 * This method works by asking the runtime if it can find Objective-C
 * classes with specific names.  The name that is looked up is build from
 * the first word found in %{aCommand}.  The first word is turned to all
 * lower case, with the first letter upper case, and then sandwiched
 * between "Merge" and "Command".  For example, the merge command "´if xxx
 * = yª" has the word "if" as the first word.  Thus, the class
 * "MergeIfCommand" will be searched for. If the desired class cannot be
 * found, then it is assumed that the merge command is giving the name of a
 * field which should be inserted into the output document.
 *
 * To avoid name space conflicts, all internal merge commands actually use
 * a slightly different name.  Thus, there really is no "MergeIfCommand" to
 * be found.  This method, when it doesn't find the "MergeIfCommand" class,
 * will search for another class, with a private name.  That class will be
 * found. (If it wasn't found, then the default "field" command class would
 * be returned.)  This allows a programmer to override any built in
 * command. To override the "if" command, simply create a "MergeIfCommand"
 * class and it will be found before the built in class.  If a programmer
 * wishes to make a particular command, such as "omit", inoperative, this
 * technique may be used to override with a MiscMergeCommand subclass that
 * does nothing.
 "*/
- (Class)classForCommand:(NSString *)aCommand;

@end


@interface MiscMergeTemplateDelegate

- (NSString *)mergeTemplate:(MiscMergeTemplate *)template resolveTemplateFilename:(NSString *)filename;

@end
