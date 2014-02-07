//
//  MiscMergeDriverTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "MiscMergeDriver.h"

static NSString *F1_Key = @"f1";
static NSString *F2_Key = @"f2";
static NSString *F3_Key = @"f3";
static NSString *F4_Key = @"f4";
static NSString *F5_Key = @"f5";
static NSString *F6_Key = @"f6";
static NSString *F7_Key = @"f7";
static NSString *F8_Key = @"f8";


@interface MiscMergeDriverTests : MiscMergeTests
@end

@implementation MiscMergeDriverTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSArray *)simpleTestData
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:@{
                      F1_Key: @"Alpha",
                      F2_Key: @"",
                      F3_Key: @"",
                      F4_Key: @"",
                      F5_Key: @0,
                      F6_Key: @6,
                      F7_Key: @"orange",
                      F8_Key: F1_Key
                      }];
    
    [data addObject:@{
                      F1_Key: @"Bravo",
                      F2_Key: @"",
                      F3_Key: @"",
                      F4_Key: @"taken",
                      F5_Key: @1,
                      F6_Key: @6,
                      F7_Key: @"red",
                      F8_Key: F1_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Charlie",
                      F2_Key: @"",
                      F3_Key: @"value",
                      F4_Key: @"",
                      F5_Key: @2,
                      F6_Key: @6,
                      F7_Key: @"green",
                      F8_Key: F7_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Delta",
                      F2_Key: @"",
                      F3_Key: @"value",
                      F4_Key: @2,
                      F5_Key: @3,
                      F6_Key: @6,
                      F7_Key: @"blue",
                      F8_Key: F7_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Echo",
                      F2_Key: @"two",
                      F3_Key: @"",
                      F4_Key: @"",
                      F5_Key: @4,
                      F6_Key: @6,
                      F7_Key: @"purple",
                      F8_Key: F5_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Foxtrot",
                      F2_Key: @99,
                      F3_Key: @"",
                      F4_Key: @"something",
                      F5_Key: @5,
                      F6_Key: @6,
                      F7_Key: @"white",
                      F8_Key: F2_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Golf",
                      F2_Key: @"a",
                      F3_Key: @"b",
                      F4_Key: @"",
                      F5_Key: @6,
                      F6_Key: @6,
                      F7_Key: F1_Key,
                      F8_Key: F6_Key
                      }];
    [data addObject:@{
                      F1_Key: @"Hotel",
                      F2_Key: @"a",
                      F3_Key: @"b",
                      F4_Key: @"c",
                      F5_Key: @7,
                      F6_Key: @6,
                      F7_Key: F2_Key,
                      F8_Key: F1_Key
                      }];
    
    return data;
}

// ## END MARKER


- (void)test_doMerge
{
    NSString *pathToTemplate = [self pathForResource:@"Simple" extension:@"mmtemplate"];
    MiscMergeTemplate *template = [[MiscMergeTemplate alloc] init];
    [template setStartDelimiter:@"«"];
    [template setEndDelimiter:@"»"];
    [template parseContentsOfFile:pathToTemplate];
    
	MiscMergeDriver *mergeDriver = [[MiscMergeDriver alloc] init];
    [mergeDriver setMergeTemplate:template];
    [mergeDriver setMergeData:[self simpleTestData]];
    
    NSArray *output = [mergeDriver doMerge:self];
    NSMutableData *encodedData = [[NSMutableData alloc] init];
    
    NSData *boundry = [@"\n-=-=-=-=-=-=-=-=-=-= output boundry =-=-=-=-=-=-=-=-=-=-\n" dataUsingEncoding:NSUTF8StringEncoding];
    for ( NSString *item in output )
    {
        [encodedData appendData:[item dataUsingEncoding:NSUTF8StringEncoding]];
        [encodedData appendData:boundry];
    }
    
    NSError *err = nil;
    BOOL success = [encodedData writeToFile:@"/tmp/mm_Simple.mmtemplate.result" options:(NSDataWritingAtomic) error:&err];
    if ((success == NO) || (err != nil))
    {
        XCTAssertTrue(success, @"encoded data failed to save");
        XCTAssertNil(err, @"ecoded data error %@", err);
    }
    else
    {
        // test the output
        NSData *md5 = [encodedData gvc_md5Digest];
        NSString *hex = [md5 gvc_hexString];
        XCTAssertEqualObjects(hex, @"aa717ba835156f016b0baf8fbfcdeab1", @"Merge failed to generate expected result");
    }
}

@end

