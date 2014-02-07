//
//  MiscMergeCommandTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "MiscMergeCommandTests.h"


@implementation MiscMergeCommandTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)commandName
{
    return @"";
}

//- (void)test_classForCommand
//{
//    MiscMergeTemplate *template = [[MiscMergeTemplate alloc] init];
//    Class classFound = [template classForCommand:@"include"];
//    XCTAssertTrue(classFound == NSClassFromString(@"_MiscMergeIncludeCommand"), @"Wrong class found %@", NSStringFromClass(classFound));
//    
//    classFound = [template classForCommand:@"notFound"];
//    XCTAssertTrue(classFound == NSClassFromString(@"_MiscMergeFieldCommand"), @"Wrong class found %@", NSStringFromClass(classFound));
//    
//    classFound = [template classForCommand:@"endif this has spaces"];
//    XCTAssertTrue(classFound == NSClassFromString(@"_MiscMergeEndifCommand"), @"Wrong class found %@", NSStringFromClass(classFound));
//}

- (void)test_parseFromString_template
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_parseFromScanner_template
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_executeForMerge
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_isKindOfCommandClass
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_eatKeyWord_fromScanner_isOptional
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getArgumentStringFromScanner_toEnd_quotes
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getArgumentStringFromScanner_toEnd
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getPromptFromScanner_toEnd
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getPromptableArgumentStringFromScanner_wasPrompt_toEnd
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getPrimaryExpressionFromScanner
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_getExpressionFromScanner
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_conditional
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_keyword
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_noprompt
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_closequote
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_closeparens
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_error_argument
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

// ## END MARKER

@end

