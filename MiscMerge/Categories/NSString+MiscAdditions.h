//
//  NSString+MiscAdditions.h
//    Written by Carl Lindberg Copyright 1998 by Carl Lindberg.
//                     All rights reserved.
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

#import <Foundation/NSString.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSScanner.h>

@class NSArray, NSEnumerator;

/* Additional searching options for some methods */
enum
{
    MiscOverlappingSearch = 2048
};


@interface NSString (MiscAdditions)

/*" Trimming whitespace "*/
- (id)mm_stringByTrimmingLeadWhitespace;
- (id)mm_stringByTrimmingTailWhitespace;
- (id)mm_stringByTrimmingWhitespace;
- (id)mm_stringBySquashingWhitespace;

/*" "Letter" manipulation "*/
- (NSString *)mm_letterAtIndex:(NSUInteger)anIndex;
- (NSString *)mm_firstLetter;
- (NSUInteger)mm_letterCount;

/*" Getting "words" "*/
- (NSArray *)mm_wordArray;
- (NSUInteger)mm_wordCount;
- (NSString *)mm_wordNum:(NSUInteger)n;
- (NSEnumerator *)mm_wordEnumerator;
- (NSString *)mm_firstWord;

- (NSUInteger)mm_numOfString:(NSString *)aString;
- (NSUInteger)mm_numOfString:(NSString *)aString options:(NSUInteger)mask;
- (NSUInteger)mm_numOfString:(NSString *)aString range:(NSRange)range;
- (NSUInteger)mm_numOfString:(NSString *)aString options:(NSUInteger)mask range:(NSRange)range;
- (NSUInteger)mm_numOfCharactersFromSet:(NSCharacterSet *)aSet;
- (NSUInteger)mm_numOfCharactersFromSet:(NSCharacterSet *)aSet range:(NSRange)range;

- (NSRange)mm_rangeOfString:(NSString *)aString occurrenceNum:(NSUInteger)n;
- (NSRange)mm_rangeOfString:(NSString *)aString options:(NSUInteger)mask occurrenceNum:(NSUInteger)n;
- (NSRange)mm_rangeOfString:(NSString *)aString occurrenceNum:(NSUInteger)n range:(NSRange)range;
- (NSRange)mm_rangeOfString:(NSString *)aString options:(NSUInteger)mask occurrenceNum:(NSUInteger)n range:(NSRange)range;

/*" Dividing strings into pieces "*/
- (NSArray *)mm_componentsSeparatedByCharactersFromSet:(NSCharacterSet *)aSet;
- (NSArray *)mm_componentsSeparatedBySeriesOfCharactersFromSet:(NSCharacterSet *)aSet;
- (NSString *)mm_substringToString:(NSString *)aString;
- (NSString *)mm_substringFromEndOfString:(NSString *)aString;

/*" Adding the options mask (mainly for NSCaseInsensitiveSearch) "*/
- (BOOL)mm_containsString:(NSString *)aString;
- (BOOL)mm_containsString:(NSString *)aString options:(NSUInteger)mask;
- (BOOL)mm_hasPrefix:(NSString *)aString options:(NSUInteger)mask;
- (BOOL)mm_hasSuffix:(NSString *)aString options:(NSUInteger)mask;

- (BOOL)mm_isBlank;

@end


@interface NSMutableString (MiscAdditions)

@end
