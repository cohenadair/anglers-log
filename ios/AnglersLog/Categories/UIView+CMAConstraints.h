//
//  UIView+CMAConstraints.h
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-26.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

@interface UIView (CMAConstraints)

/**
 * A utility method for setting up a view's anchor constraints. All view positioning should be
 * done using this method, rather than the anchor methods directly.
 */
- (void)constrain:(void (^)(UIView *view))block;

#pragma mark - Width & Height

/**
 * Sets both the width and height to the given value.
 */
- (void)sizeToConstant:(CGFloat)value;

#pragma mark - Width

- (void)widthToConstant:(CGFloat)value;
- (void)widthToView:(UIView *)view;
- (void)widthToAnchor:(NSLayoutAnchor<NSLayoutDimension *> *)anchor;
- (void)widthToSuperview;

#pragma mark - Height

- (void)heightToConstant:(CGFloat)value;
- (void)heightToView:(UIView *)view;
- (void)heightToAnchor:(NSLayoutAnchor<NSLayoutDimension *> *)anchor;
- (void)heightToSuperview;

#pragma mark - Leading

- (void)leadingToConstant:(CGFloat)value;
- (void)leadingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor;
- (void)leadingToView:(UIView *)view offset:(CGFloat)offset;
- (void)leadingToView:(UIView *)view;
- (void)leadingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor offset:(CGFloat)offset;
- (void)leadingToMargin:(UIView *)view;
- (void)leadingToSuperview;
- (void)leadingToSuperview:(CGFloat)offset;

#pragma mark - Trailing

- (void)trailingToConstant:(CGFloat)value;
- (void)trailingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor;
- (void)trailingToView:(UIView *)view offset:(CGFloat)offset;
- (void)trailingToView:(UIView *)view;
- (void)trailingToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor offset:(CGFloat)offset;
- (void)trailingToMargin:(UIView *)view;
- (void)trailingToSuperview;
- (void)trailingToSuperview:(CGFloat)offset;

#pragma mark - Top

- (void)topToConstant:(CGFloat)value;
- (void)topToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor;
- (void)topToView:(UIView *)view offset:(CGFloat)offset;
- (void)topToView:(UIView *)view;
- (void)topToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor offset:(CGFloat)offset;
- (void)topToMargin:(UIView *)view;
- (void)topToSuperview;
- (void)topToSuperview:(CGFloat)offset;

#pragma mark - Bottom

- (void)bottomToConstant:(CGFloat)value;
- (void)bottomToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor;
- (void)bottomToView:(UIView *)view offset:(CGFloat)offset;
- (void)bottomToView:(UIView *)view;
- (void)bottomToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor offset:(CGFloat)offset;
- (void)bottomToMargin:(UIView *)view;
- (void)bottomToSuperview;
- (void)bottomToSuperview:(CGFloat)offset;

#pragma mark - CenterY

- (void)centerYToAnchor:(NSLayoutAnchor<NSLayoutYAxisAnchor *> *)anchor;
- (void)centerYToView:(UIView *)view;
- (void)centerYToSuperview;

#pragma mark - CenterX

- (void)centerXToAnchor:(NSLayoutAnchor<NSLayoutXAxisAnchor *> *)anchor;
- (void)centerXToView:(UIView *)view;
- (void)centerXToSuperview;

#pragma mark - Miscellaneous

- (void)fillSuperview;
- (void)centerToSuperview;

@end
