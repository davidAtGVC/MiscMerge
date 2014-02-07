//
//  MiscMergeCommandBlockTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "MiscMerge.h"

@interface MiscMergeCommandBlockTests : MiscMergeTests
@end

@implementation MiscMergeCommandBlockTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_initWithOwner
{
    MiscMergeCommandBlock *cmdBlock = [[MiscMergeCommandBlock alloc] initWithOwner:self];
    XCTAssertNotNil([cmdBlock owner], @"Owner should not be nil");
    XCTAssertTrue([cmdBlock owner] == self, @"Owner is set to wrong object");
    
    XCTAssertNotNil([cmdBlock commandArray], @"Command Array should be initialized");
    XCTAssertTrue( mm_IsEmpty([cmdBlock commandArray]), @"Command array should be empty");
}

- (void)test_addCommand
{
    MiscMergeCommandBlock *cmdBlock = [[MiscMergeCommandBlock alloc] initWithOwner:self];
    MiscMergeCommand *aCommand = [[MiscMergeCommand alloc] init];
    [cmdBlock addCommand:aCommand];
    
    XCTAssertNotNil([cmdBlock commandArray], @"Command Array should be initialized");
    XCTAssertTrue([[cmdBlock commandArray] count] == 1, @"Command Array should have one item");
    XCTAssertTrue( [[cmdBlock commandArray] firstObject] == aCommand, @"Command array should contain a command");
}

- (void)test_removeCommand
{
    MiscMergeCommandBlock *cmdBlock = [[MiscMergeCommandBlock alloc] initWithOwner:self];
    MiscMergeCommand *aCommand_1 = [[MiscMergeCommand alloc] init];
    MiscMergeCommand *aCommand_2 = [[MiscMergeCommand alloc] init];
    [cmdBlock addCommand:aCommand_1];
    [cmdBlock addCommand:aCommand_2];
    
    [cmdBlock removeCommand:aCommand_1];
    XCTAssertNotNil([cmdBlock commandArray], @"Command Array should be initialized");
    XCTAssertTrue([[cmdBlock commandArray] count] == 1, @"Command Array should have one item");
    XCTAssertFalse([[cmdBlock commandArray] containsObject:aCommand_1], @"Command array should not contain this command");
    XCTAssertTrue( [[cmdBlock commandArray] firstObject] == aCommand_2, @"Command array should contain a command");
}

// ## END MARKER

@end

