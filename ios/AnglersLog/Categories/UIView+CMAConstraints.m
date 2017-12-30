//
//  UIView+CMAConstraints.m
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-26.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "UIView+CMAConstraints.h"

@implementation UIView (CMAConstraints)

- (void)constrain:(void (^)(UIView *view))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    block(self);
}

#pragma mark - Width & Height

/**
 * Sets both the width and height to the given value.
 */
- (void)sizeToConstant:(CGFloat)value {
    [self widthToConstant:value];
    [self heightToConstant:value];
}

#pragma mark - Width

- (void)widthToConstant:(CGFloat)value {
    [self.widthAnchor constraintEqualToConstant:value].active = YES;
}

- (void)widthToView:(UIView *)view {
    [self.widthAnchor constraintEqualToAnchor:view.widthAnchor].active = YES;
}

- (void)widthToAnchor:(NSLayoutAnchor<NSLayoutDimension *> *)anchor {
    [self.widthAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)widthToSuperview {
    [self widthToView:self.superview];
}

#pragma mark - Height

- (void)heightToConstant:(CGFloat)value {
    [self.heightAnchor constraintEqualToConstant:value].active = YES;
}

- (void)heightToView:(UIView *)view {
    [self.heightAnchor constraintEqualToAnchor:view.heightAnchor].active = YES;
}

- (void)heightToAnchor:(NSLayoutAnchor<NSLayoutDimension *> *)anchor {
    [self.heightAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)heightToSuperview {
    [self heightToView:self.superview];
}

#pragma mark - Leading

- (void)leadingToConstant:(CGFloat)value {
    [self.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:value].active = YES;
}

- (void)leadingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor {
    [self.leadingAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)leadingToView:(UIView *)view offset:(CGFloat)offset {
    [self.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:offset].active = YES;
}

- (void)leadingToView:(UIView *)view {
    [self leadingToView:view offset:0];
}

- (void)leadingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor offset:(CGFloat)offset {
    [self.leadingAnchor constraintEqualToAnchor:anchor constant:offset].active = YES;
}

- (void)leadingToMargin:(UIView *)view {
    [self.leadingAnchor constraintEqualToAnchor:view.layoutMarginsGuide.leadingAnchor].active = YES;
}

- (void)leadingToSuperview {
    [self leadingToView:self.superview];
}

- (void)leadingToSuperview:(CGFloat)offset {
    [self leadingToView:self.superview offset:offset];
}

#pragma mark - Trailing

- (void)trailingToConstant:(CGFloat)value {
    [self.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:value].active = YES;
}

- (void)trailingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor {
    [self.trailingAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)trailingToView:(UIView *)view offset:(CGFloat)offset {
    [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:offset].active = YES;
}

- (void)trailingToView:(UIView *)view {
    [self trailingToView:view offset:0];
}

- (void)trailingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor offset:(CGFloat)offset {
    [self.trailingAnchor constraintEqualToAnchor:anchor constant:offset].active = YES;
}

- (void)trailingToMargin:(UIView *)view {
    [self.trailingAnchor constraintEqualToAnchor:view.layoutMarginsGuide.trailingAnchor].active = YES;
}

- (void)trailingToSuperview {
    [self trailingToView:self.superview];
}

- (void)trailingToSuperview:(CGFloat)offset {
    [self trailingToView:self.superview offset:offset];
}

#pragma mark - Top

- (void)topToConstant:(CGFloat)value {
    [self.topAnchor constraintEqualToAnchor:self.topAnchor constant:value].active = YES;
}

- (void)topToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor {
    [self.topAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)topToView:(UIView *)view offset:(CGFloat)offset {
    [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:offset].active = YES;
}

- (void)topToView:(UIView *)view {
    [self topToView:view offset:0];
}

- (void)topToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor offset:(CGFloat)offset {
    [self.topAnchor constraintEqualToAnchor:anchor constant:offset].active = YES;
}

- (void)topToMargin:(UIView *)view {
    [self.topAnchor constraintEqualToAnchor:view.layoutMarginsGuide.topAnchor].active = YES;
}

- (void)topToSuperview {
    [self topToView:self.superview];
}

- (void)topToSuperview:(CGFloat)offset {
    [self topToView:self.superview offset:offset];
}

#pragma mark - Bottom

- (void)bottomToConstant:(CGFloat)value {
    [self.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:value].active = YES;
}

- (void)bottomToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor {
    [self.bottomAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)bottomToView:(UIView *)view offset:(CGFloat)offset {
    [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:offset].active = YES;
}

- (void)bottomToView:(UIView *)view {
    [self bottomToView:view offset:0];
}

- (void)bottomToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor offset:(CGFloat)offset {
    [self.bottomAnchor constraintEqualToAnchor:anchor constant:offset].active = YES;
}

- (void)bottomToMargin:(UIView *)view {
    [self.bottomAnchor constraintEqualToAnchor:view.layoutMarginsGuide.bottomAnchor].active = YES;
}

- (void)bottomToSuperview {
    [self bottomToView:self.superview];
}

- (void)bottomToSuperview:(CGFloat)offset {
    [self bottomToView:self.superview offset:offset];
}

#pragma mark - CenterY

- (void)centerYToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor {
    [self.centerYAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)centerYToView:(UIView *)view {
    [self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = YES;
}

- (void)centerYToSuperview {
    [self centerYToView:self.superview];
}

#pragma mark - CenterX

- (void)centerXToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor {
    [self.centerXAnchor constraintEqualToAnchor:anchor].active = YES;
}

- (void)centerXToView:(UIView *)view {
    [self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = YES;
}

- (void)centerXToSuperview {
    [self centerXToView:self.superview];
}

#pragma mark - Miscellaneous

- (void)fillSuperview {
    [self topToSuperview];
    [self leadingToSuperview];
    [self trailingToSuperview];
    [self bottomToSuperview];
}

- (void)centerToSuperview {
    [self centerXToSuperview];
    [self centerYToSuperview];
}

@end
