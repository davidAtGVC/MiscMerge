//
//  NSCharacterSet+GVCFoundation.m
//
//  Created by David Aspinall on 11-01-13.
//  Copyright 2011 Global Village Consulting Inc. All rights reserved.
//

#import "NSCharacterSet+MiscMerge.h"


@implementation NSCharacterSet (MiscMerge)

static NSCharacterSet *MM_KVCDelimiterCharacterSet;

+ (NSCharacterSet *)mm_KVCDelimiterCharacterSet
{
    static dispatch_once_t MM_KVCDelimiterCharacterSetDispatch;
	dispatch_once(&MM_KVCDelimiterCharacterSetDispatch, ^{
        MM_KVCDelimiterCharacterSet = [NSCharacterSet characterSetWithRange:NSMakeRange((unsigned int)'.', 1)];
    });
    return MM_KVCDelimiterCharacterSet;
}

@end
