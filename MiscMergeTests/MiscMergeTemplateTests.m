//
//  MiscMergeTemplateTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "MiscMergeTemplate.h"

@interface MiscMergeTemplateTests : MiscMergeTests
@end

@implementation MiscMergeTemplateTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)defaultTemplateString
{
    NSString *s = [MiscMergeTemplate defaultStartDelimiter];
    NSString *e = [MiscMergeTemplate defaultEndDelimiter];
    
    NSString *copy1 = [NSString stringWithFormat:@"Testing value that dereferences another key: f8 = \\%@", s];
    NSString *field = [NSString stringWithFormat:@"%@f8%@", s, e];
    NSString *copy2 = [NSString stringWithFormat:@"\\%@ ==>> ", e];
    NSString *parse = [NSString stringWithFormat:@"%@%@f8%@%@", s, s, e, e];

    return [NSString stringWithFormat:@"%@%@%@%@", copy1, field, copy2, parse];
}

- (void)test_currentCommandBlock
{
    NSString *string = [self defaultTemplateString];
    MiscMergeTemplate *template = [[MiscMergeTemplate alloc] initWithString:string];
    MiscMergeCommandBlock *topBlock = [template currentCommandBlock];

    XCTAssertTrue([topBlock class] == NSClassFromString(@"MiscMergeCommandBlock"), @"Wrong class found %@", NSStringFromClass([topBlock class]));
    XCTAssertNotNil([topBlock commandArray], @"No commands found");
    XCTAssertTrue([[topBlock commandArray] count] == 4, @"Incorrect number of parsed commands");
    
    _MiscMergeCopyCommand *copy = [[topBlock commandArray] objectAtIndex:0];
    NSString *copy1 = [NSString stringWithFormat:@"Testing value that dereferences another key: f8 = %@", [MiscMergeTemplate defaultStartDelimiter]];
    XCTAssertEqualObjects([copy theText], copy1, @"First copy command has incorrect content %@", [copy theText]);
    
//    _MiscMergeFieldCommand *field = [[topBlock commandArray] objectAtIndex:1];
//    MiscMergeExpression *expression = [field expression];
    
    NSLog(@"Commands = %@", [topBlock commandArray]);
}

- (void)test_defaultEndDelimiter
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_defaultStartDelimiter
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_init
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_initWithContentsOfFile
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_initWithString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_mergeTemplate_resolveTemplateFilename
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_parseContentsOfFile
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_parseString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_popCommandBlock
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_pushCommandBlock
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_reportParseError
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_resolveTemplateFilename
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_template
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)test_templateWithString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

// ## END MARKER

@end

