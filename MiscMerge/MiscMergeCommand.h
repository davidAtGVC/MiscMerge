//
//  MiscMergeCommand.h
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
#import "MiscMergeEngine.h"
#import "MiscMergeTemplate.h"

@class NSScanner;
@class NSNumber;
@class MiscMergeExpression;

/**
 * class
 */
@interface MiscMergeCommand : NSObject
{}

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
+ (Class)classForCommand:(NSString *)aCommand;

/**
    " Basic methods "
 * @param aString the addresses stuff
 */
- (BOOL)parseFromString:(NSString *)aString template:(MiscMergeTemplate *)template;

- (BOOL)parseFromScanner:(NSScanner *)aScanner template:(MiscMergeTemplate *)template;
- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger;

- (BOOL)isKindOfCommandClass:(NSString *)command;

/*" Help with parsing "*/
- (BOOL)eatKeyWord:(NSString *)aKeyWord fromScanner:(NSScanner *)scanner isOptional:(BOOL)flag;
- getArgumentStringFromScanner:(NSScanner *)scanner toEnd:(BOOL)endFlag quotes:(NSInteger *)quotes;
- getArgumentStringFromScanner:(NSScanner *)scanner toEnd:(BOOL)endFlag;
- getPromptFromScanner:(NSScanner *)scanner toEnd:(BOOL)endFlag;
- getPromptableArgumentStringFromScanner:(NSScanner *)scanner wasPrompt:(BOOL *)prompt toEnd:(BOOL)endFlag;

- (MiscMergeExpression *)getPrimaryExpressionFromScanner:(NSScanner *)aScanner;
- (MiscMergeExpression *)getExpressionFromScanner:(NSScanner *)aScanner;

/*" Error reporting "*/
- (void)error_conditional:(NSString *)theCond;
- (void)error_keyword:(NSString *)aKeyWord;
- (void)error_noprompt;
- (void)error_closequote;
- (void)error_closeparens;
- (void)error_argument:(NSString *)theArgument;

@end
