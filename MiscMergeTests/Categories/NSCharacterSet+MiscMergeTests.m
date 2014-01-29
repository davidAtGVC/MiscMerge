//
//  NSCharacterSet+MiscMergeTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "NSCharacterSet+MiscMerge.h"

@interface NSCharacterSetTests : MiscMergeTests
@end

@implementation NSCharacterSetTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)test_mm_KVCDelimiterCharacterSet
{
    NSArray *yesTestStrings = @[@" .",
                                @"this.has.whitespace"
                                ];
    
    for ( NSString *aString in yesTestStrings )
    {
        NSRange kvcExists = [aString rangeOfCharacterFromSet:[NSCharacterSet mm_KVCDelimiterCharacterSet]];
        XCTAssertTrue(kvcExists.length > 0, @"Failed to find kvc delimiter in '%@'", aString);
        XCTAssertTrue(kvcExists.location != NSNotFound, @"Failed to find kvc delimiter in '%@'", aString);
    }
}

// ## END MARKER


- (void)test_WhitespaceAndNewlines
{
    NSArray *yesTestStrings = @[@" ",
                                @"this has whitespace",
                                @"\t",
                                @"this\thas\ttabs",
                                @"\n"
                                @"this\nhas\nnewlines",
                                @"\r"
                                @"this\rhas\rcarrigereturns",
                                @"\v",
                                @"this\vhas\vvertical",
                                @"\f",
                                @"this\fhas\fnewlines"
                                ];
    
    for ( NSString *aString in yesTestStrings )
    {
        NSRange whiteRange = [aString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        XCTAssertTrue(whiteRange.length > 0, @"Failed to find white space in '%@'", aString);
        XCTAssertTrue(whiteRange.location != NSNotFound, @"Failed to find white space in '%@'", aString);
    }
}

- (void)test_NoWhitespaceAndNewlines
{
    NSArray *noTestStrings = @[@"", @"thishasnowhitespace"];
    
    for ( NSString *aString in noTestStrings )
    {
        NSRange whiteRange = [aString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        XCTAssertTrue(whiteRange.length == 0, @"Found white space in '%@'", aString);
        XCTAssertTrue(whiteRange.location == NSNotFound, @"Found white space in '%@'", aString);
    }
}

@end

