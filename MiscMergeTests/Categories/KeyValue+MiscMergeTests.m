//
//  KeyValue+MiscMergeTests.m
//
//  Created by David Aspinall on 12/20/2013.
//  Copyright (c) 2013 Global Village Consulting. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MiscMergeTests.h"
#import "KeyValue+MiscMerge.h"

@interface MMKeyPathObj : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) MMKeyPathObj *child;
@property (strong, nonatomic) NSArray *stuff;
@end

@implementation MMKeyPathObj
- (NSString *)description
{
    NSMutableString *buffer = [NSMutableString stringWithString:[super description]];
    [buffer appendFormat:@" name=%@", [self name]];
    [buffer appendFormat:@" child=%@", [self child]];
    return buffer;
}
@end


@interface KeyValueTests : MiscMergeTests
@end

@implementation KeyValueTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_mm_hasMiscMergeKey
{
    MMKeyPathObj *obj = [[MMKeyPathObj alloc] init];
    [obj setName:[self name]];
    
    XCTAssertTrue([obj mm_hasMiscMergeKey:@"name"], @"Failed to find 'name'");
    XCTAssertTrue([obj mm_hasMiscMergeKey:@"child"], @"Failed to find 'child'");
    
    XCTAssertFalse([obj mm_hasMiscMergeKey:nil], @"Found nil");
    XCTAssertFalse([obj mm_hasMiscMergeKey:@""], @"Found empty string");
    XCTAssertFalse([obj mm_hasMiscMergeKey:@"noSuchMethod"], @"Found no existant method 'noSuchMethod'");
    XCTAssertFalse([obj mm_hasMiscMergeKey:@"child.name"], @"Found keypath to 'child.name'");
}

- (void)test_mm_hasMiscMergeKeyPath
{
    MMKeyPathObj *parent = [[MMKeyPathObj alloc] init];
    [parent setName:[self name]];
    [parent setChild:[[MMKeyPathObj alloc] init]];
    [[parent child] setName:@"ChildName"];
    
    XCTAssertTrue([parent mm_hasMiscMergeKeyPath:@"name"], @"Failed to find 'name'");
    XCTAssertTrue([parent mm_hasMiscMergeKeyPath:@"child.name"], @"Failed to find 'child.name'");
    XCTAssertTrue([parent mm_hasMiscMergeKeyPath:@"child.child"], @"Failed to find 'child.child'");
    
    XCTAssertFalse([parent mm_hasMiscMergeKeyPath:nil], @"Found nil");
    XCTAssertFalse([parent mm_hasMiscMergeKeyPath:@""], @"Found empty string");
    XCTAssertFalse([parent mm_hasMiscMergeKeyPath:@"no.SuchMethod"], @"Found no existant keypath 'no.SuchMethod'");
}

// ## END MARKER

- (void)test_hasMiscMergeKey_NSArray
{
    MMKeyPathObj *obj1 = [[MMKeyPathObj alloc] init];
    [obj1 setName:[self name]];
    MMKeyPathObj *obj2 = [[MMKeyPathObj alloc] init];
    [obj2 setName:[self name]];
    
    NSArray *objArray = @[obj1, obj2];
    
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKey:@"count"], @"Failed to find 'count'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKey:@"@sum"], @"Failed to find '@sum'");
    
    XCTAssertTrue([objArray mm_hasMiscMergeKey:@"name"], @"Failed to find 'name'");
    XCTAssertTrue([objArray mm_hasMiscMergeKey:@"child"], @"Failed to find 'child'");
    
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKey:@"name"], @"EmptyArray Failed to find 'name'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKey:@"child"], @"EmptyArray Failed to find 'child'");
    
    XCTAssertFalse([objArray mm_hasMiscMergeKey:nil], @"Found nil");
    XCTAssertFalse([objArray mm_hasMiscMergeKey:@""], @"Found empty string");
    XCTAssertFalse([objArray mm_hasMiscMergeKey:@"noSuchMethod"], @"Found no existant method 'noSuchMethod'");
    XCTAssertFalse([objArray mm_hasMiscMergeKey:@"child.name"], @"Found keypath to 'child.name'");
}

- (void)test_hasMiscMergeKeyPath_NSArray
{
    MMKeyPathObj *obj1 = [[MMKeyPathObj alloc] init];
    [obj1 setName:[self name]];
    [obj1 setChild:[[MMKeyPathObj alloc] init]];
    
    MMKeyPathObj *obj2 = [[MMKeyPathObj alloc] init];
    [obj2 setName:[self name]];
    [obj2 setChild:[[MMKeyPathObj alloc] init]];
    
    NSArray *objArray = @[obj1, obj2];
    
    // test just a key
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"count"], @"Failed to find 'count'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"@sum"], @"Failed to find '@sum'");
    
    XCTAssertTrue([objArray mm_hasMiscMergeKeyPath:@"name"], @"Failed to find 'name'");
    XCTAssertTrue([objArray mm_hasMiscMergeKeyPath:@"child"], @"Failed to find 'child'");
    
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"name"], @"EmptyArray Failed to find 'name'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"child"], @"EmptyArray Failed to find 'child'");
    
    // test a keypath
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"name.count"], @"Failed to find 'count'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"@sum.name"], @"Failed to find '@sum.name'");
    
    XCTAssertTrue([objArray mm_hasMiscMergeKeyPath:@"child.name"], @"Failed to find 'child.name'");
    XCTAssertTrue([objArray mm_hasMiscMergeKeyPath:@"child.child"], @"Failed to find 'child.child'");
    
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"child.name"], @"EmptyArray Failed to find 'child.name'");
    XCTAssertTrue([[NSArray array] mm_hasMiscMergeKeyPath:@"child.child"], @"EmptyArray Failed to find 'child.child'");
    
    XCTAssertFalse([objArray mm_hasMiscMergeKeyPath:nil], @"Found nil");
    XCTAssertFalse([objArray mm_hasMiscMergeKeyPath:@""], @"Found empty string");
    
    // FIXME: should the array follow the keypath recursively
    //    XCTAssertFalse([objArray mm_hasMiscMergeKeyPath:@"child.noSuchMethod"], @"Found no existant method 'noSuchMethod'");
    XCTAssertFalse([objArray mm_hasMiscMergeKeyPath:@"no.such"], @"Found keypath to 'child.name'");
}

- (void)test_hasMiscMergeKey_NSDictionary
{
    MMKeyPathObj *obj1 = [[MMKeyPathObj alloc] init];
    [obj1 setName:[self name]];
    MMKeyPathObj *obj2 = [[MMKeyPathObj alloc] init];
    [obj2 setName:[self name]];
    
    NSDictionary *objDictionary = @{@"obj1": obj1,
                                    @"obj2": obj2};
    
    XCTAssertTrue([objDictionary mm_hasMiscMergeKey:@"obj1"], @"Failed to find 'obj1'");
    XCTAssertTrue([objDictionary mm_hasMiscMergeKey:@"obj2"], @"Failed to find 'obj2'");
    
    XCTAssertFalse([objDictionary mm_hasMiscMergeKey:nil], @"Found nil");
    XCTAssertFalse([objDictionary mm_hasMiscMergeKey:@""], @"Found empty string");
    XCTAssertFalse([objDictionary mm_hasMiscMergeKey:@"noSuchMethod"], @"Found no existant method 'noSuchMethod'");
    XCTAssertFalse([objDictionary mm_hasMiscMergeKey:@"child.name"], @"Found keypath to 'child.name'");
    
}

- (void)test_hasMiscMergeKeyPath_NSDictionary
{
    MMKeyPathObj *obj1 = [[MMKeyPathObj alloc] init];
    [obj1 setName:[self name]];
    [obj1 setChild:[[MMKeyPathObj alloc] init]];
    
    MMKeyPathObj *obj2 = [[MMKeyPathObj alloc] init];
    [obj2 setName:[self name]];
    [obj2 setChild:[[MMKeyPathObj alloc] init]];
    
    NSDictionary *objDictionary = @{@"obj1": obj1,
                                    @"obj2": obj2};
    
    // test just a key
    XCTAssertTrue([objDictionary mm_hasMiscMergeKeyPath:@"obj1"], @"Failed to find 'obj1'");
    XCTAssertTrue([objDictionary mm_hasMiscMergeKeyPath:@"obj2"], @"Failed to find 'obj2'");
    
    // test a keypath
    XCTAssertTrue([objDictionary mm_hasMiscMergeKeyPath:@"obj1.name"], @"Failed to find 'obj1.name'");
    XCTAssertTrue([objDictionary mm_hasMiscMergeKeyPath:@"obj1.child"], @"Failed to find 'obj1.child'");
    
    XCTAssertFalse([objDictionary mm_hasMiscMergeKeyPath:nil], @"Found nil");
    XCTAssertFalse([objDictionary mm_hasMiscMergeKeyPath:@""], @"Found empty string");
    
    // FIXME: should the dictionary follow the keypath recursively
    //    XCTAssertFalse([objDictionary mm_hasMiscMergeKeyPath:@"obj1.noSuchMethod"], @"Found no existant method 'obj1.noSuchMethod'");
    //    XCTAssertFalse([objDictionary mm_hasMiscMergeKeyPath:@"obj1.child.no.such"], @"Found keypath to 'obj1.child.no.such'");
}

@end

