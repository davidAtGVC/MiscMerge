//
//  GVCMacros.h
//  GVCFoundation
//
//  Created by David Aspinall on 11-09-28.
//  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.
//


#ifndef MiscMergeMacros_h
#define MiscMergeMacros_h

/**
 * @file
 * @brief 'C' Macros definitions for cleaner coding
 * @see 
 **/

#pragma mark - Empty or Nil test
	// Credit: http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL mm_IsEmpty(id thing)
{
    return thing == nil
	|| ([thing isEqual:[NSNull null]])
	|| ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

#pragma mark - nil or isEqual test
/** if canBeNil is true AND both objects are nil, then return true, else if both objects are NOT nil and the same class and isEqual: the return true */
static inline BOOL mm_IsEqual(BOOL canBeNil, id thing, id other)
{
    return ((canBeNil == YES) && (thing == nil) && (other == nil))
    || ((thing != nil) && (other != nil) && ([thing isKindOfClass:[other class]] == YES) && ([thing isEqual:other] == YES));
}

#endif
