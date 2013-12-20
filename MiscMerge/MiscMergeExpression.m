 //
//  MiscMergeEngine.m
//
//	Written by Doug McClure and Carl Lindberg
//
//	Copyright 2002-2004 by Don Yacktman, Doug McClure, and Carl Lindberg.
//	All rights reserved.
//
//      This notice may not be removed from this source code.
//
//	This header is included in the MiscKit by permission from the author
//	and its use is governed by the MiscKit license, found in the file
//	"License.rtf" in the MiscKit distribution.  Please refer to that file
//	for a list of all applicable permissions and restrictions.
//

#import "MiscMergeExpression.h"
#import "MiscMergeFunctions.h"
#import "MiscMergeEngine.h"
#import "NSString+MiscAdditions.h"

static NSNumber *TRUE_VALUE;
static NSNumber *FALSE_VALUE;

@interface MiscMergeValueExpression ()
@property (copy, nonatomic) NSString *valueName;
@property (assign, nonatomic) NSInteger quotes;
@end

@interface MiscMergeUnaryOpExpression ()
@property (strong, nonatomic) MiscMergeExpression *expression;
@end

@interface MiscMergeBinaryOpExpression ()
@property (strong, nonatomic) MiscMergeExpression *leftExpression;
@property (strong, nonatomic) MiscMergeExpression *rightExpression;
@property (assign, nonatomic) MiscMergeOperator operator;
@end

@interface MiscMergeGroupExpression ()
@property (strong, nonatomic) NSMutableArray *expressions;
@end

@implementation MiscMergeExpression

+ (void)initialize
{
    static dispatch_once_t globalSymbolsExpressionDispatch;
	dispatch_once(&globalSymbolsExpressionDispatch, ^{
        TRUE_VALUE = [NSNumber numberWithBool:YES];
        FALSE_VALUE = [NSNumber numberWithBool:NO];
    });
}

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    return nil;
}

- (BOOL)evaluateAsBoolWithEngine:(MiscMergeEngine *)anEngine
{
    return MMBoolValueOfObject([self evaluateWithEngine:anEngine]);
}

- (NSInteger)evaluateAsIntegerWithEngine:(MiscMergeEngine *)anEngine
{
    return MMIntegerValueOfObject([self evaluateWithEngine:anEngine]);
}

@end



@implementation MiscMergeValueExpression

- (id)initWithValueName:(NSString *)string quotes:(NSInteger)number
{
    self = [super init];
    if (self != nil)
    {
        [self setValueName:string];
        [self setQuotes:number];
    }
    return self;
}

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    return [anEngine valueForField:[self valueName] quoted:[self quotes]];
}

- (NSString *)description
{
    if ( [self quotes] > 0 )
        return [NSString stringWithFormat:@"MEValue(value='%@',quotes=%ld)", [self valueName], (long)[self quotes]];
    else
        return [NSString stringWithFormat:@"MEValue(value='%@')", [self valueName]];
}

+ (MiscMergeValueExpression *)valueName:(NSString *)string quotes:(NSInteger)number
{
    return [[self alloc] initWithValueName:string quotes:number];
}

@end


@implementation MiscMergeUnaryOpExpression

- (id)initWithExpression:(MiscMergeExpression *)anExpression
{
    self = [super init];
    if (self != nil)
    {
        [self setExpression:anExpression];
    }
    return self;
}

- (NSString *)nameDescription
{
    return @"MEUnary";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@(exp=%@)", [self nameDescription], [self expression]];
}

+ (MiscMergeUnaryOpExpression *)expression:(MiscMergeExpression *)anExpression
{
    return [[self alloc] initWithExpression:anExpression];
}

@end

@implementation MiscMergeNegativeExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    return [NSNumber numberWithDouble:-MMDoubleValueForObject([[self expression] evaluateWithEngine:anEngine])];
}

- (NSString *)nameDescription
{
    return @"MENegative";
}

@end

@implementation MiscMergeNegateExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    return [NSNumber numberWithBool:!MMDoubleValueForObject([[self expression] evaluateWithEngine:anEngine])];
}

- (NSString *)nameDescription
{
    return @"MENegate";
}

@end


@implementation MiscMergeBinaryOpExpression

- (id)initWithLeftExpression:(MiscMergeExpression *)lExpression operator:(MiscMergeOperator)anOperator rightExpression:(MiscMergeExpression *)rExpression
{
    self = [super init];
    if ( self != nil )
    {
        [self setLeftExpression:lExpression];
        [self setRightExpression:rExpression];
        [self setOperator:anOperator];
    }
    return self;
}

- (NSString *)nameDescription
{
    return @"MEBinary";
}

- (NSString *)operatorDescription
{
    return [NSString stringWithFormat:@"%lu", [self operator]];
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@(lexp=%@,op='%@',rexp=%@)", [self nameDescription],
            [self leftExpression], [self operatorDescription], [self rightExpression]];
}

+ (MiscMergeBinaryOpExpression *)leftExpression:(MiscMergeExpression *)lExpression operator:(MiscMergeOperator)anOperator rightExpression:(MiscMergeExpression *)rExpression
{
    return [[self alloc] initWithLeftExpression:lExpression operator:anOperator rightExpression:rExpression];
}

@end

@implementation MiscMergeMathExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    double lValue = MMDoubleValueForObject([[self leftExpression] evaluateWithEngine:anEngine]);
    double rValue = MMDoubleValueForObject([[self rightExpression] evaluateWithEngine:anEngine]);

    switch ( [self operator] )
    {
        case MiscMergeOperatorAdd:
            return [NSNumber numberWithDouble:(lValue + rValue)];
        case MiscMergeOperatorSubtract:
            return [NSNumber numberWithDouble:(lValue - rValue)];
        case MiscMergeOperatorMultiply:
            return [NSNumber numberWithDouble:(lValue * rValue)];
        case MiscMergeOperatorDivide:
            return [NSNumber numberWithDouble:(lValue / rValue)];
        case MiscMergeOperatorModulus:
            return [NSNumber numberWithInteger:((NSInteger)lValue % (NSInteger)rValue)];
        default:
            return [NSNumber numberWithInteger:0];
    }
}

- (NSString *)nameDescription
{
    return @"MEMath";
}

- (NSString *)operatorDescription
{
    switch ( [self operator] )
    {
        case MiscMergeOperatorAdd:      return @"+";
        case MiscMergeOperatorSubtract: return @"-";
        case MiscMergeOperatorMultiply: return @"*";
        case MiscMergeOperatorDivide:   return @"/";
        case MiscMergeOperatorModulus:  return @"%";
        default:                        return @"";
    }
}

@end

@implementation MiscMergeConditionalExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    id leftOperand = [[self leftExpression] evaluateWithEngine:anEngine];
    id rightOperand = [[self rightExpression] evaluateWithEngine:anEngine];
    NSComparisonResult comparison;
    NSInteger returnValue;

    if (leftOperand == nil && rightOperand == nil) {
        comparison = NSOrderedSame;
    }
    else if (leftOperand == nil && rightOperand != nil) {
        comparison = NSOrderedAscending;
    }
    else if (leftOperand != nil && rightOperand == nil) {
        comparison = NSOrderedDescending;
    }
    else if (MMIsObjectANumber(leftOperand) && MMIsObjectANumber(rightOperand)) {
        comparison = MMCompareFloats([leftOperand floatValue], [rightOperand floatValue]);
    }
    else if ([leftOperand isEqual:rightOperand]) {
        comparison = NSOrderedSame;
    }
    /* Short-circuit for "==" and "!=", since -isEqual: should have done the necessary check. */
    else if ([self operator] == MiscMergeOperatorEqual) {
        return FALSE_VALUE;
    }
    else if ([self operator] == MiscMergeOperatorNotEqual) {
        return TRUE_VALUE;
    }
    else if ([MMCommonAnscestorClass(leftOperand, rightOperand) instancesRespondToSelector:@selector(compare:)]) {
        comparison = [(NSString*)leftOperand compare:rightOperand];
    }
    else { //??
        comparison = [[leftOperand description] compare:[rightOperand description]];
    }

    /*
     * now that we have comparison results, turn them into a YES/NO
     * depending upon the chosen operator.
     */
    switch ( [self operator] )
    {
        case MiscMergeOperatorEqual:
            returnValue = (comparison == NSOrderedSame);
            break;
            
        case MiscMergeOperatorNotEqual:
            returnValue = (comparison != NSOrderedSame);
            break;
            
        case MiscMergeOperatorLessThanOrEqual:
            returnValue = (comparison != NSOrderedDescending);
            break;
            
        case MiscMergeOperatorGreaterThanOrEqual:
            returnValue = (comparison != NSOrderedAscending);
            break;
            
        case MiscMergeOperatorLessThan:
            returnValue = (comparison == NSOrderedAscending);
            break;
            
        case MiscMergeOperatorGreaterThan:
            returnValue = (comparison == NSOrderedDescending);
            break;
            
        default:
            returnValue = NO; // handled above
    }

    return (returnValue) ? TRUE_VALUE : FALSE_VALUE;
}

- (NSString *)nameDescription
{
    return @"MEConditional";
}

- (NSString *)operatorDescription
{
    NSString *operatorDescription;
    
    switch ( [self operator] )
    {
        case MiscMergeOperatorEqual:              return @"==";
        case MiscMergeOperatorNotEqual:           return @"!=";
        case MiscMergeOperatorLessThanOrEqual:    return @"<=";
        case MiscMergeOperatorGreaterThanOrEqual: return @">=";
        case MiscMergeOperatorLessThan:           return @"<";
        case MiscMergeOperatorGreaterThan:        return @">";
        default:                                  return @"";
    }

    return operatorDescription;
}

@end

@implementation MiscMergeContainsExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    id leftOperand = [[self leftExpression] evaluateWithEngine:anEngine];
    id rightOperand;
    BOOL returnValue = NO;

    if ( [[self rightExpression] isKindOfClass:[MiscMergeListExpression class]] )
        rightOperand = [(MiscMergeListExpression *)[self rightExpression] evaluateAsListWithEngine:anEngine];
    else
        rightOperand = [[self rightExpression] evaluateWithEngine:anEngine];

    if ( [rightOperand isKindOfClass:[NSArray class]] )
    {
        NSEnumerator *enumerator = [rightOperand objectEnumerator];
        id object;

        while ( !returnValue && (object = [enumerator nextObject]) ) {
            if (leftOperand == nil && object == nil) {
                returnValue = YES;
            }
            else if (leftOperand == nil && object != nil) {
                returnValue = NO;
            }
            else if (leftOperand != nil && object == nil) {
                returnValue = NO;
            }
            else if (MMIsObjectANumber(leftOperand) && MMIsObjectANumber(object)) {
                returnValue = (NSOrderedSame == MMCompareFloats([leftOperand floatValue], [object floatValue]));
            }
            else {
                returnValue = [leftOperand isEqual:object];
            }
        }
    }

    if ( [self operator] == MiscMergeOperatorNotIn )
        returnValue = !returnValue;

    return returnValue ? TRUE_VALUE : FALSE_VALUE;
}

- (NSString *)nameDescription
{
    return @"MEContains";
}

- (NSString *)operatorDescription
{
    NSString *operatorDescription;

    switch ( [self operator] )
    {
        case MiscMergeOperatorIn:    return @"==";
        case MiscMergeOperatorNotIn: return @"!=";
        default:                     return @"";
    }

    return operatorDescription;
}

@end



@implementation MiscMergeGroupExpression

- (id)initWithExpression:(MiscMergeExpression *)lExpression andExpression:(MiscMergeExpression *)rExpression
{
    self = [super init];
    if ( self != nil )
    {
        [self setExpressions:[[NSMutableArray alloc] init]];
        [[self expressions] addObject:lExpression];
        [[self expressions] addObject:rExpression];
    }
    return self;
}

- (id)initWithExpressions:(NSArray *)list
{
    self = [super init];
    if ( self != nil )
    {
        [self setExpressions:[[NSMutableArray alloc] init]];
    }
    return self;
}

- (void)addExpression:(MiscMergeExpression *)expression
{
    [[self expressions] addObject:expression];
}

- (NSString *)nameDescription
{
    return @"MEGroup";
}

- (NSString *)description
{
    NSInteger index, count = [[self expressions] count];
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@(", [self nameDescription]];
    
    for ( index = 0; index < count; index++ )
    {
        if ( index > 0 )
        {
            [string appendString:@","];
        }

        [string appendFormat:@"%ld=%@", (long)index, [[self expressions] objectAtIndex:index]];
    }

    [string appendString:@")"];
    return string;
}

+ (MiscMergeGroupExpression *)expression:(MiscMergeExpression *)lExpression andExpression:(MiscMergeExpression *)rExpression
{
    return [[self alloc] initWithExpression:lExpression andExpression:rExpression];
}

+ (MiscMergeGroupExpression *)expressions:(NSArray *)list
{
    return [[self alloc] initWithExpressions:list];
}

@end

@implementation MiscMergeAndExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    NSEnumerator *enumerator = [[self expressions] objectEnumerator];
    MiscMergeExpression *expression;
    BOOL returnValue = YES;

    while ( returnValue && (expression = (MiscMergeExpression *)[enumerator nextObject]) ) {
        returnValue = MMDoubleValueForObject([expression evaluateWithEngine:anEngine]);
    }

    return (returnValue) ? TRUE_VALUE : FALSE_VALUE;
}

- (NSString *)nameDescription
{
    return @"MEAnd";
}

@end

@implementation MiscMergeOrExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    NSEnumerator *enumerator = [[self expressions] objectEnumerator];
    MiscMergeExpression *expression;
    BOOL returnValue = NO;

    while ( !returnValue && (expression = (MiscMergeExpression *)[enumerator nextObject]) ) {
        returnValue = MMDoubleValueForObject([expression evaluateWithEngine:anEngine]);
    }

    return (returnValue) ? TRUE_VALUE : FALSE_VALUE;
}

- (NSString *)nameDescription
{
    return @"MEOr";
}

@end

@implementation MiscMergeListExpression

- (id)evaluateWithEngine:(MiscMergeEngine *)anEngine
{
    return [[[self expressions] lastObject] evaluateWithEngine:anEngine];
}

- (NSArray *)evaluateAsListWithEngine:(MiscMergeEngine *)anEngine
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *enumerator = [[self expressions] objectEnumerator];
    MiscMergeExpression *expression;
    
    while (( expression = (MiscMergeExpression *)[enumerator nextObject] )) {
        [array addObject:[expression evaluateWithEngine:anEngine]];
    }

    return array;
}

- (NSString *)nameDescription
{
    return @"MEList";
}

@end
