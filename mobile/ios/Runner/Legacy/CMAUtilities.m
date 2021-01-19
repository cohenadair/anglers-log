//
//  CMAUtilities.m
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUtilities.h"

@implementation CMAUtilities

+ (NSString *)stringForDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

@end

