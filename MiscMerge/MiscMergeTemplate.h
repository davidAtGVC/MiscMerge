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


@end


@interface MiscMergeTemplateDelegate

- (NSString *)mergeTemplate:(MiscMergeTemplate *)template resolveTemplateFilename:(NSString *)filename;

@end
