//
//  _MiscMergeOptionCommand.h
//
//	Written by Doug McClure
//
//	Copyright 2001-2004 by Don Yacktman and Doug McClure.
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

typedef NS_ENUM(NSInteger, OptionType)
{
    RecursiveLookups = 1,
    
    FailedLookupResultKey,
    FailedLookupResultKeyWithDelims,
    FailedLookupResultNil,
    FailedLookupResultKeyIfNumeric,
    
    NilLookupResultNil,
    NilLookupResultKeyIfQuoted,
    NilLookupResultKey,
    NilLookupResultKeyWithDelims
};

@interface _MiscMergeOptionCommand : MiscMergeCommand

@property (assign, nonatomic) OptionType optionType;
@property (strong, nonatomic) NSString *value1;

@end
