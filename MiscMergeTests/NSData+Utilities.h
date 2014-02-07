//
//  NSData+Utilities.h
//
//  Created by David Aspinall on 1/28/2014.
//  Copyright (c) 2014 Global Village Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Utilities)

- (NSData *)gvc_md5Digest;

- (NSString *)gvc_hexString;

@end
