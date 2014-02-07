//
//  NSArray+Utilities.m
//  MiscMerge
//
//  Created by David Aspinall on 1/28/2014.
//  Copyright (c) 2014 Global Village Consulting. All rights reserved.
//

#import "NSData+Utilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Utilities)

- (NSData *)gvc_md5Digest
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (unsigned int)[self length], result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)gvc_hexString
{
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	
    const unsigned char *dataBuffer = [self bytes];
    NSUInteger i;
    
    for (i = 0; i < [self length]; ++i)
	{
        [stringBuffer appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
	}
    
    return stringBuffer;
}

@end
