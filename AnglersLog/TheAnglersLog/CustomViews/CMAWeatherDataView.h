//
//  CMAWeatherDataView.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-26.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMAWeatherDataView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *skyConditionsLabel;

@end
