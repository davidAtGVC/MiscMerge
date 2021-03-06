//
//  _MiscMergeIfCommandTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "_MiscMergeIfCommand.h"

@interface _MiscMergeIfCommandTests : MiscMergeTests
@end

@implementation _MiscMergeIfCommandTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_handleElseInTemplate
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_handleEndifInTemplate
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_evaluateExpressionInMerger
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (NSString *)commandName
{
    return @"if";
}

// ## END MARKER

- (void)test_parseFromString_template
{
    NSString *commandContent = @"Special method used by the template";
    
    Class commandClass = [MiscMergeCommand classForCommand:[self commandName]];
    XCTAssertTrue(commandClass != Nil, @"Failed to find classForCommand( %@ )", [self commandName]);
    id command = [[commandClass alloc] init];
    XCTAssertNotNil(command, @"Failed to allocate command");
    
    BOOL success = [command parseFromString:[NSString stringWithFormat:@"%@ %@",[self commandName], commandContent] template:nil];
    XCTAssertTrue(success, @"Command failed to parse content");
}

- (void)test_parseFromScanner_template
{
    NSString *commandContent = @"Special method used by the template";
    
    NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@ %@",[self commandName], commandContent]];
    [scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    Class commandClass = [MiscMergeCommand classForCommand:[self commandName]];
    XCTAssertTrue(commandClass != Nil, @"Failed to find classForCommand( %@ )", [self commandName]);
    id command = [[commandClass alloc] init];
    XCTAssertNotNil(command, @"Failed to allocate command");
    
    BOOL success =  [command parseFromScanner:scanner template:nil];
    XCTAssertTrue(success, @"Command failed to parse content");
}


@end

