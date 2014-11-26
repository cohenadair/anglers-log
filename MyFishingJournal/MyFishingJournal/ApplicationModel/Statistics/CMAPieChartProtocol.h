//
//  CMAPieChartProtocol.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/25/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMAPieChartProtocol <NSObject>

@required
- (NSInteger)highestValueIndex;
- (NSInteger)indexForName:(NSString *)aName;
- (NSInteger)valueForSliceAtIndex:(NSInteger)anIndex;
- (NSInteger)valueForPercentAtIndex:(NSInteger)anIndex;
- (NSString *)stringForPercentAtIndex:(NSInteger)anIndex;
- (NSString *)nameAtIndex:(NSInteger)anIndex;
- (NSString *)detailTextAtIndex:(NSInteger)anIndex;

@end
