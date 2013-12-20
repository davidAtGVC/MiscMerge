//
//  _MiscMergeProcedureCommand.h
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

@class NSArray;
@class MiscMergeCommandBlock;

typedef NS_ENUM(NSInteger, ArgTypes)
{
    RequiredArg = 1,
    OptionalArg = 2,
    ArrayArg = 3
};

@interface _MiscMergeProcedureCommand : MiscMergeCommand

@property (strong, nonatomic) NSString *procedureName;
@property (strong, nonatomic) MiscMergeCommandBlock *commandBlock;
@property (strong, nonatomic) NSMutableArray *argumentArray;
@property (strong, nonatomic) NSMutableArray *argumentTypes;

/*" Called by the endprocedure command "*/
- (void)handleEndProcedureInTemplate:(MiscMergeTemplate *)template;

/*" Called by the call command "*/
- (MiscMergeCommandExitType)executeForMerge:(MiscMergeEngine *)aMerger arguments:(NSArray *)passedArgArray;

@end
