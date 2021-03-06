//
//  _MiscMergeForeachCommand.h
//
//	Written by Don Yacktman and Carl Lindberg
//
//	Copyright 2001-2004 by Don Yacktman and Carl Lindberg.
//	All rights reserved.
//
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//	

#import "MiscMergeCommand.h"

@class MiscMergeCommandBlock;

@interface _MiscMergeForeachCommand : MiscMergeCommand

@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *arrayField;
@property (assign, nonatomic) NSInteger arrayQuote;
@property (strong, nonatomic) NSString *loopName;
@property (strong, nonatomic) MiscMergeCommandBlock *commandBlock;
@property (strong, nonatomic) MiscMergeExpression *arrayExpression;

- (void)handleEndForeachInTemplate:(MiscMergeTemplate *)template;

@end
