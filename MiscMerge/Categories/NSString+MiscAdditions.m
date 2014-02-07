//
//  NSString+MiscAdditions.m
//    Written by Carl Lindberg Copyright 2002 by Carl Lindberg.
//                     All rights reserved.
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

#import "NSString+MiscAdditions.h"
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSScanner.h>
//#import <Foundation/NSUtilities.h>
#import <Foundation/NSString.h>
#import <Foundation/NSData.h>
#import <stdlib.h>  //NULL os OSXPB


@implementation NSString (MiscAdditions)

- (NSRange)mm_completeRange
{
    return NSMakeRange(0, [self length]);
}

- (id)mm_stringByTrimmingLeadWhitespace
{
    NSCharacterSet *nonSpaceSet;
    NSRange validCharRange;

    nonSpaceSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    validCharRange = [self rangeOfCharacterFromSet:nonSpaceSet];

    if (validCharRange.length == 0)
        return @"";
    else
        return [self substringFromIndex:validCharRange.location];
}

- (id)mm_stringByTrimmingTailWhitespace
{
    NSCharacterSet *nonSpaceSet;
    NSRange validCharRange;

    nonSpaceSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    validCharRange = [self rangeOfCharacterFromSet:nonSpaceSet options:NSBackwardsSearch];

    if (validCharRange.length == 0)
        return @"";
    else
        return [self substringToIndex:validCharRange.location+1];
}

- (id)mm_stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- mm_stringBySquashingWhitespace
{
    NSCharacterSet *spaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *nonspaceSet = [spaceSet invertedSet];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSMutableString *newString = [NSMutableString stringWithCapacity:[self length]];
    NSString *wordString;
    NSString *stringToAppend = @"";

    [scanner setCharactersToBeSkipped:spaceSet];

    while (![scanner isAtEnd])
    {
        [newString appendString:stringToAppend];

        if ([scanner scanCharactersFromSet:nonspaceSet intoString:&wordString])
        {
            [newString appendString:wordString];
            //			stringToAppend = ([wordString hasSuffix:@"."])? @"  " : @" ";
            stringToAppend = @" ";
        }
    }

    return newString;
}

- mm_stringBySquashingWhitespace2
{
    return [[self mm_wordArray] componentsJoinedByString:@" "];
}

- (NSString *)mm_letterAtIndex:(NSUInteger)anIndex
{
    NSRange letterRange = NSMakeRange( NSNotFound, 0);
    if (([self length] > 0) && (anIndex < [self length]))
    {
        letterRange = [self rangeOfComposedCharacterSequenceAtIndex:anIndex];
    }
    return (letterRange.location == NSNotFound ? @"" : [self substringWithRange:letterRange]);
}

- (NSString *)mm_firstLetter
{
    return [self mm_letterAtIndex:0];
}

- (NSUInteger)mm_letterCount
{
    NSUInteger count = 0;
    NSUInteger selfLength = [self length];
    NSUInteger currIndex = 0;
    NSRange letterRange;

    while (currIndex < selfLength)
    {
        letterRange = [self rangeOfComposedCharacterSequenceAtIndex:currIndex];
        if (letterRange.length > 0)
        {
            currIndex = NSMaxRange(letterRange);
            count++;
        }
        else
        {
            break;
        }
    }

    return count;
}


- (NSArray *)mm_wordArray
{
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSUInteger)mm_wordCount;
{
    return [[self mm_wordArray] count];
}

- (NSString *)mm_wordNum:(NSUInteger)n
{
    NSArray *words = [self mm_wordArray];
    return (n < [words count] ? words[n] : nil);
}

- (NSEnumerator *)mm_wordEnumerator
{
    return [[self mm_wordArray] objectEnumerator];
}

- (NSString *)mm_firstWord
{
    return [[self mm_wordArray] firstObject];
}

static NSRange _mm_nextSearchRange(NSString *string, NSUInteger mask, NSRange *foundRange, NSUInteger lastIndex, NSUInteger firstIndex)
{
    /*
     * The char range stuff is if we want to use
     * -rangeOfComposedCharacterSequenceAtIndex: instead of assuming characters
     * are one index apart.  It may not matter, provided that NeXT's
     * -rangeOfString: routines adjust appropriately if we give it an index in
     * the middle of a composed character sequence.
     */
    //	NSRange	charRange;
    NSRange nextRange;

    if (mask & NSBackwardsSearch)
    {
        NSUInteger endLocation;

        if (mask & MiscOverlappingSearch)
        {
            endLocation = foundRange->location - 1;
            // charRange = [string rangeOfComposedCharacterSequenceAtIndex:endLocation];
            // endLocation = charRange.location;
        }
        else
        {
            endLocation = foundRange->location - foundRange->length;
        }
        nextRange.location = firstIndex;
        nextRange.length = endLocation - nextRange.location;
    }
    else
    {
        if (mask & MiscOverlappingSearch)
        {
            // charRange = [string rangeOfComposedCharacterSequenceAtIndex:foundRange->location];
            // nextRange.location = NSMaxRange(charRange);
            nextRange.location = foundRange->location+1;
        }
        else
        {
            nextRange.location = NSMaxRange(*foundRange);
        }
        nextRange.length = lastIndex - nextRange.location;
    }

    return nextRange;
}

- (NSUInteger)mm_numOfString:(NSString *)aString
{
    return [self mm_numOfString:aString options:0 range:[self mm_completeRange]];
}

- (NSUInteger)mm_numOfString:(NSString *)aString options:(NSUInteger)mask
{
    return [self mm_numOfString:aString options:mask range:[self mm_completeRange]];
}

- (NSUInteger)mm_numOfString:(NSString *)aString range:(NSRange)range
{
    return [self mm_numOfString:aString options:0 range:range];
}

- (NSUInteger)mm_numOfString:(NSString *)aString options:(NSUInteger)mask range:(NSRange)range
{
    NSUInteger lastIndex = NSMaxRange(range);
    NSUInteger stringCount = 0;
    NSUInteger searchOptions = (mask & (NSCaseInsensitiveSearch|NSLiteralSearch));
    NSRange searchRange;
    NSRange foundRange;

    mask &= ~NSBackwardsSearch;
    foundRange = [self rangeOfString:aString options:searchOptions range:range];

    while (foundRange.length > 0)
    {
        stringCount++;
        searchRange = _mm_nextSearchRange(self, mask, &foundRange, lastIndex, range.location);
        foundRange  = [self rangeOfString:aString options:searchOptions range:searchRange];
    }

    return stringCount;
}

- (NSRange)mm_rangeOfString:(NSString *)aString occurrenceNum:(NSUInteger)n
{
    return [self mm_rangeOfString:aString options:0 occurrenceNum:n range:[self mm_completeRange]];
}

- (NSRange)mm_rangeOfString:(NSString *)aString options:(NSUInteger)mask occurrenceNum:(NSUInteger)n
{
    return [self mm_rangeOfString:aString options:mask occurrenceNum:n range:[self mm_completeRange]];
}

- (NSRange)mm_rangeOfString:(NSString *)aString occurrenceNum:(NSUInteger)n range:(NSRange)range
{
    return [self mm_rangeOfString:aString options:0 occurrenceNum:n range:range];
}

- (NSRange)mm_rangeOfString:(NSString *)aString options:(NSUInteger)mask occurrenceNum:(NSUInteger)n range:(NSRange)range
{
    NSUInteger lastIndex = NSMaxRange(range);
    NSUInteger count = 0;
    NSUInteger searchOptions = (mask & (~NSAnchoredSearch));
    NSRange searchRange;
    NSRange foundRange;

    foundRange = [self rangeOfString:aString options:searchOptions range:range];

    while (foundRange.length > 0)
    {
        if (count == n) return foundRange;
        searchRange = _mm_nextSearchRange(self, mask, &foundRange, lastIndex, range.location);
        foundRange = [self rangeOfString:aString options:searchOptions range:searchRange];
        count++;
    }

    return NSMakeRange(NSNotFound, 0);
}

- (NSUInteger)mm_numOfCharactersFromSet:(NSCharacterSet *)aSet
{
    return [self mm_numOfCharactersFromSet:(NSCharacterSet *)aSet range:[self mm_completeRange]];
}

- (NSUInteger)mm_numOfCharactersFromSet:(NSCharacterSet *)aSet range:(NSRange)range
{
    NSUInteger lastIndex = NSMaxRange(range);
    NSRange searchRange = {range.location, lastIndex};
    NSRange foundRange;
    NSUInteger characterCount = 0;

    foundRange = [self rangeOfCharacterFromSet:aSet options:0 range:searchRange];

    while (foundRange.length > 0)
    {
        characterCount++;
        searchRange.location = NSMaxRange(foundRange);
        searchRange.length = lastIndex - searchRange.location;
        foundRange = [self rangeOfCharacterFromSet:aSet options:0 range:searchRange];
    }

    return characterCount;
}

- (NSArray *)mm_componentsSeparatedByCharactersFromSet:(NSCharacterSet *)aSet
{
    NSUInteger selfLength = [self length];
    NSRange searchRange = {0, selfLength};
    NSRange betweenRange = {0, 0};
    NSRange foundRange;
    NSMutableArray *stringArray = [NSMutableArray array];

    foundRange = [self rangeOfCharacterFromSet:aSet options:0 range:searchRange];

    while (foundRange.length > 0)
    {
        betweenRange.length = foundRange.location - betweenRange.location;
        [stringArray addObject:[self substringWithRange:betweenRange]];

        betweenRange.location = searchRange.location = NSMaxRange(foundRange);
        searchRange.length = selfLength - searchRange.location;
        foundRange = [self rangeOfCharacterFromSet:aSet options:0 range:searchRange];
    }

    betweenRange.length = selfLength - betweenRange.location;
    [stringArray addObject:[self substringWithRange:betweenRange]];
    return stringArray;
}


- (NSArray *)mm_componentsSeparatedBySeriesOfCharactersFromSet:(NSCharacterSet *)aSet
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSMutableArray *stringArray = [NSMutableArray array];
    NSString *betweenString;

    [scanner setCharactersToBeSkipped:nil];

    while (![scanner isAtEnd])
    {
        if ([scanner scanUpToCharactersFromSet:aSet intoString:&betweenString])
            [stringArray addObject:betweenString];
        else
            [stringArray addObject:@""];  // can only happen first time

        if ([scanner scanCharactersFromSet:aSet intoString:NULL])
        {
            if ([scanner isAtEnd])
                [stringArray addObject:@""];  // can only happen last time
        }
    }

    return stringArray;
}


- (NSString *)mm_substringFromEndOfString:(NSString *)aString
{
    NSRange stringRange = [self rangeOfString:aString options:0];

    if (stringRange.length > 0)
        return [self substringFromIndex:NSMaxRange(stringRange)];
    else
        return nil;  // return @""? return self?
}


- (NSString *)mm_substringToString:(NSString *)aString
{
    NSRange stringRange = [self rangeOfString:aString options:0];

    if (stringRange.length > 0)
        return [self substringToIndex:stringRange.location];
    else
        return nil;  // return @""? return self?
}

- (BOOL)mm_containsString:(NSString *)aString
{
    return [self mm_containsString:aString options:0];
}

- (BOOL)mm_containsString:(NSString *)aString options:(NSUInteger)mask
{
    NSRange range = [self rangeOfString:aString options:(mask & (~NSAnchoredSearch))];
    return (range.length > 0)? YES : NO;
}

- (BOOL)mm_hasPrefix:(NSString *)aString options:(NSUInteger)mask
{
    NSRange range;

    mask |= NSAnchoredSearch;
    mask &= (~NSBackwardsSearch);
    range = [self rangeOfString:aString options:mask];

    return (range.length > 0 && range.location == 0)? YES : NO;
}

- (BOOL)mm_hasSuffix:(NSString *)aString options:(NSUInteger)mask
{
    NSRange range;

    mask |= (NSAnchoredSearch|NSBackwardsSearch);
    range = [self rangeOfString:aString options:mask];

    return ((range.length > 0) && (NSMaxRange(range) == [self length]))? YES : NO;
}


- (BOOL)mm_isBlank
{
    NSRange spaceRange = [self rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]];
    return (spaceRange.length == 0)? YES : NO;
}

@end

@implementation NSMutableString (MiscAdditions)


@end
