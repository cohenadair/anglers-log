//
//  CMAWeatherData.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMAEntry;

@interface CMAWeatherData : NSManagedObject

@property (strong, nonatomic)CMAEntry *entry;
@property (strong, nonatomic)NSNumber *temperature;
@property (strong, nonatomic)NSString *windSpeed;
@property (strong, nonatomic)NSString *skyConditions;
@property (strong, nonatomic)NSString *imageURL;

// visiting
- (void)accept:(id)aVisitor;

@end
