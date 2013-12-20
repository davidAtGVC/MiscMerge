//
//  NSCharacterSetTests.m
//  MiscMerge
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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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
