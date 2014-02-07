//
//  MiscMergeTests.m
//  MiscMergeTests
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"

@implementation MiscMergeTests

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

- (NSString *)pathForResource:(NSString *)name extension:(NSString *)ext
{
    NSParameterAssert(name);
    NSParameterAssert(ext);

	NSString *file = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:ext];
	
	XCTAssertNotNil(file, @"Unable to locate %@.%@ file", name, ext);
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:file], @"File does not exist %@", file);
	
	return file;
}
@end
