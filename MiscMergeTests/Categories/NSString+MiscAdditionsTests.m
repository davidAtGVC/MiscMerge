//
//  NSString+MiscAdditionsTests.m
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
}

- (void)tearDown
{
    [super tearDown];
}


- (void)test_mm_stringByTrimmingLeadWhitespace
{
    NSDictionary *testCases = @{
                                @"": @"",
                                @" ": @"",
                                @"NoWhiteSpace":            @"NoWhiteSpace",
                                @"Interior white space":    @"Interior white space",
                                @"Multiple   white   space":    @"Multiple   white   space",
                                @" Leading 1 space":        @"Leading 1 space",
                                @"   Leading 3 space":      @"Leading 3 space",
                                @"Trailing 1 space ":       @"Trailing 1 space ",
                                @"Trailing 3 space   ":     @"Trailing 3 space   ",
                                @"  Leading and Trailing space  ":       @"Leading and Trailing space  "
                                };

    for ( NSString *source in testCases )
    {
        NSString *expected = [testCases valueForKey:source];
        NSString *result = [source mm_stringByTrimmingLeadWhitespace];
        XCTAssertEqualObjects(result, expected, @"Result '%@' should be '%@'", result, expected);
    }
}

- (void)test_mm_stringByTrimmingTailWhitespace
{
    NSDictionary *testCases = @{
                                @"": @"",
                                @" ": @"",
                                @"NoWhiteSpace":            @"NoWhiteSpace",
                                @"Interior white space":    @"Interior white space",
                                @"Multiple   white   space":    @"Multiple   white   space",
                                @" Leading 1 space":        @" Leading 1 space",
                                @"   Leading 3 space":      @"   Leading 3 space",
                                @"Trailing 1 space ":       @"Trailing 1 space",
                                @"Trailing 3 space   ":     @"Trailing 3 space",
                                @"  Leading and Trailing space  ":       @"  Leading and Trailing space"
                                };
    
    for ( NSString *source in testCases )
    {
        NSString *expected = [testCases valueForKey:source];
        NSString *result = [source mm_stringByTrimmingTailWhitespace];
        XCTAssertEqualObjects(result, expected, @"Result '%@' should be '%@'", result, expected);
    }
}

- (void)test_mm_stringByTrimmingWhitespace
{
    NSDictionary *testCases = @{
                                @"": @"",
                                @" ": @"",
                                @"NoWhiteSpace":            @"NoWhiteSpace",
                                @"Interior white space":    @"Interior white space",
                                @"Multiple   white   space":    @"Multiple   white   space",
                                @" Leading 1 space":        @"Leading 1 space",
                                @"   Leading 3 space":      @"Leading 3 space",
                                @"Trailing 1 space ":       @"Trailing 1 space",
                                @"Trailing 3 space   ":     @"Trailing 3 space",
                                @"  Leading and Trailing space  ":       @"Leading and Trailing space"
                                };
    
    for ( NSString *source in testCases )
    {
        NSString *expected = [testCases valueForKey:source];
        NSString *result = [source mm_stringByTrimmingWhitespace];
        XCTAssertEqualObjects(result, expected, @"Result '%@' should be '%@'", result, expected);
    }
}

- (void)test_mm_stringBySquashingWhitespace
{
    NSDictionary *testCases = @{
                                @"": @"",
                                @" ": @"",
                                @"NoWhiteSpace":            @"NoWhiteSpace",
                                @"Interior white space":    @"Interior white space",
                                @"Multiple   white   space":    @"Multiple white space",
                                @" Leading 1 space":        @"Leading 1 space",
                                @"   Leading 3 space":      @"Leading 3 space",
                                @"Trailing 1 space ":       @"Trailing 1 space",
                                @"Trailing 3 space   ":     @"Trailing 3 space",
                                @"  Leading and Trailing space  ":       @"Leading and Trailing space"
                                };
    
    for ( NSString *source in testCases )
    {
        NSString *expected = [testCases valueForKey:source];
        NSString *result = [source mm_stringBySquashingWhitespace];
        XCTAssertEqualObjects(result, expected, @"Result '%@' should be '%@'", result, expected);
    }
}

- (void)test_mm_letterAtIndex
{
    NSString *test = @" 123456789 abcdefghijklmnopqrstuvwxyz";
    NSDictionary *testCases = @{
                                @"0" : @" ",
                                @"3" : @"3",
                                @"36" : @"z",
                                @"37" : @""
                                };
    for ( NSString *source in testCases )
    {
        NSString *expected = [testCases valueForKey:source];
        NSString *result = [test mm_letterAtIndex:[source integerValue]];
        XCTAssertEqualObjects(result, expected, @"Result '%@' should be '%@' %lu", result, expected, (unsigned long)[test length]);
    }
    
    XCTAssertEqualObjects([@"" mm_letterAtIndex:0], @"", @"mm_letterAtIndex:0 of empty string should be empty");

    NSString *result = [test mm_letterAtIndex:UINT_MAX];
    XCTAssertEqualObjects(result, @"", @"Out of bounds should be empty");
}

- (void)test_mm_firstLetter
{
    XCTAssertEqualObjects([@"" mm_firstLetter], @"", @"First letter of empty string should be empty");
    XCTAssertEqualObjects([@"a" mm_firstLetter], @"a", @"First letter of 'a' should be 'a'");
    XCTAssertEqualObjects([@"abcd" mm_firstLetter], @"a", @"First letter of 'abcd' should be 'a'");
}

- (void)test_mm_letterCount
{
    XCTAssertTrue([@"" mm_letterCount] == 0, @"Empty string is 0 characters");
    XCTAssertTrue([@"abc" mm_letterCount] == 3, @"'abc' is 3 characters");
    XCTAssertTrue([@"abc xyz" mm_letterCount] == 7, @"'abc xyz' is 7 characters %lu", (unsigned long)[@"abc xyz" mm_letterCount]);

    NSString *utf8 = @"abc 😄😃";
    XCTAssertTrue([utf8 mm_letterCount] == 6, @"'%@' is 6 characters %lu", utf8, (unsigned long)[@"abc 😄😃" mm_letterCount]);
    
    utf8 = @"Arabic: أنا قادر على أكل الزجاج و هذا لا يؤلمني.";
    XCTAssertTrue([utf8 mm_letterCount] == 48, @"'%@' is 48 characters %lu", utf8, (unsigned long)[utf8 mm_letterCount]);
    
}

- (void)test_mm_wordArray
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_wordCount
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_wordNum
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_wordEnumerator
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_firstWord
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfString_options
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfString_range
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfString_options_range
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfCharactersFromSet
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_numOfCharactersFromSet_range
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_rangeOfString_occurrenceNum
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_rangeOfString_options_occurrenceNum
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_rangeOfString_occurrenceNum_range
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_rangeOfString_options_occurrenceNum_range
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_componentsSeparatedByCharactersFromSet
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_componentsSeparatedBySeriesOfCharactersFromSet
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_substringToString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_substringFromEndOfString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_containsString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_containsString_options
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_hasPrefix_options
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_hasSuffix_options
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mm_isBlank
{
    // true
    XCTAssertTrue([@"" mm_isBlank], @"Empty string is blank");
    XCTAssertTrue([@" " mm_isBlank], @"Single space string is blank");
    XCTAssertTrue([@"\n" mm_isBlank], @"new line string is blank");
    XCTAssertTrue([@" \n \r" mm_isBlank], @"Space, newline string is blank");

    // false
    XCTAssertFalse([@"a" mm_isBlank], @"'a' string is not blank");
    XCTAssertFalse([@"  a" mm_isBlank], @"'  a' string is not blank");

}

// ## END MARKER

@end

