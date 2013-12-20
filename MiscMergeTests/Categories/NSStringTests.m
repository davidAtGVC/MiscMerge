//
//  NSStringTests.m
//  MiscMerge
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "NSString+MiscAdditions.h"

@interface NSStringTests : MiscMergeTests

@end

@implementation NSStringTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_stringByTrimmingLeadWhitespace
{
}

- (void)test_stringByTrimmingTailWhitespace
{
}

- (void)test_stringByTrimmingWhitespace
{
}

- (void)test_stringBySquashingWhitespace
{
}


/*" "Letter" manipulation "*/
- (void)test_letterAtIndex
{
}

- (void)test_firstLetter
{
}

- (void)test_letterCount
{
}

/*" Getting "words" "*/
- (void)test_wordArray
{
}

- (void)test_wordCount
{
}

- (void)test_wordNum
{
}

- (void)test_wordEnumerator
{
}

- (void)test_firstWord
{
}


/*" Bulk replacing "*/
- (void)test_stringByReplacingEveryOccurrenceOfString_withString
{
}

- (void)test_stringByReplacingEveryOccurrenceOfString_withString_options
{
}

- (void)test_stringByReplacingEveryOccurrenceOfCharactersFromSet_withString
{
}

- (void)test_stringByReplacingEverySeriesOfCharactersFromSet_withString
{
}


- (void)test_numOfString
{
}

- (void)test_numOfString_options
{
}

- (void)test_numOfString_range
{
}

- (void)test_numOfString_options_range
{
}

- (void)test_numOfCharactersFromSet
{
}

- (void)test_numOfCharactersFromSet_range
{
}


- (void)test_rangeOfString_occurrenceNum
{
}

- (void)test_rangeOfString_options_occurrenceNum
{
}

- (void)test_rangeOfString_occurrenceNum_range
{
}

- (void)test_rangeOfString_options_occurrenceNum_range
{
}


/*" Dividing strings into pieces "*/
- (void)test_componentsSeparatedByCharactersFromSet
{
}

- (void)test_componentsSeparatedBySeriesOfCharactersFromSet
{
}

- (void)test_substringToString
{
}

- (void)test_substringFromEndOfString
{
}


/*" Adding the options mask (mainly for NSCaseInsensitiveSearch) "*/
- (void)test_containsString
{
}

- (void)test_containsString_options
{
}

- (void)test_hasPrefix_options
{
}

- (void)test_hasSuffix_options
{
}


- (void)test_isBlank
{
}


@end
