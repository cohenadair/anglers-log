//
//  CMAUtilitiesTest.m
//  AnglersLogTests
//
//  Created by Cohen Adair on 2018-01-07.
//  Copyright © 2018 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAUtilities.h"

@interface CMAUtilitiesTest : XCTestCase

@end

@implementation CMAUtilitiesTest

- (UIImage *)getTestImage {
    UIImage *image = [UIImage imageNamed:@"scale_image.jpg"
                                inBundle:[NSBundle bundleForClass:CMAUtilitiesTest.self]
           compatibleWithTraitCollection:nil];
    [self assertSize:image.size isSize:CGSizeMake(1600, 900)];
    return image;
}

- (void)assertSize:(CGSize)actualSize isSize:(CGSize)expectedSize {
    XCTAssertEqual(actualSize.width, expectedSize.width);
    XCTAssertEqual(actualSize.height, expectedSize.height);
}

- (void)testScaleSize {
    CGSize rectangle = CGSizeMake(1600, 900);
    CGSize scaledSize = [CMAUtilities scaleSize:rectangle toWidth:800];
    [self assertSize:scaledSize isSize:CGSizeMake(800, 450)];
}

- (void)testScaleImageToSize {
    UIImage *scaledImage = [CMAUtilities scaleImage:self.getTestImage toSize:CGSizeMake(800, 300)];
    [self assertSize:scaledImage.size isSize:CGSizeMake(800, 300)];
}

- (void)testScaleImageToSquareSize {
    UIImage *scaledImage = [CMAUtilities scaleImage:self.getTestImage toSquareSize:50];
    [self assertSize:scaledImage.size isSize:CGSizeMake(50, 50)];
}

- (void)testScaleImageToWidth {
    UIImage *scaledImage = [CMAUtilities scaleImage:self.getTestImage toWidth:800];
    [self assertSize:scaledImage.size isSize:CGSizeMake(800, 450)];
}

@end
