//
//  NSString+CMA.h
//  AnglersLog
//
//  Created by Cohen Adair on 2016-09-14.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CMA)

/**
 * Uses an NSNumberFormatter to convert the string to an NSNumber. This is
 * necessary for user input in locals that use a comma in place of a period for
 * decimals.
 */
- (NSNumber *)formattedFloatValue;

- (NSString *)stringByRemovingSpaces;

@end
