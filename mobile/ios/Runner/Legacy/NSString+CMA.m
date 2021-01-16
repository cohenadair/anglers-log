//
//  NSString+CMA.m
//  AnglersLog
//
//  Created by Cohen Adair on 2016-09-14.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//

#import "NSString+CMA.h"

@implementation NSString (CMA)

- (NSNumber *)formattedFloatValue {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:self];
}

- (NSString *)stringByRemovingSpaces {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
