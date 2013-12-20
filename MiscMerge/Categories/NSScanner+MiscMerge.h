//
//  NSScanner+MiscMerge.h
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

#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>

@interface NSScanner (MiscMerge)

- (BOOL)mm_scanLetterIntoString:(NSString **)aString;

- (BOOL)mm_scanString:(NSString *)aString;

- (NSRange)mm_remainingRange;
- (NSString *)mm_remainingString;

- (void)mm_skipPastSkipCharacters;

- (BOOL)mm_scanCharacter:(unichar)targetCharacter;
- (unichar)mm_peekNextCharacter;

@end
