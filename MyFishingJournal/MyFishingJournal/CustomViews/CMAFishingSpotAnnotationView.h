//
//  CMAFishingSpotAnnotationView.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CMAFishingSpotAnnotationView : MKAnnotationView <MKAnnotation>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishCaughtLabel;

@end
