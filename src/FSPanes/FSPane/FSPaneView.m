//
//  FSPaneView.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-04-24.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPaneView.h"
#import "FSPaneBorderShadowView.h"

@interface FSPaneView ()
{
    UIView *_leftShadowView;
    UIView *_rightShadowView;
    UIView *_roundedCornersView;
}

- (void)_addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width;
- (void)_addRightBorderShadowView:(UIView *)view withWidth:(CGFloat)width;

@end

@implementation FSPaneView

@synthesize contentView = _contentView;
@synthesize headerView = _headerView;

@synthesize shadowWidth = _shadowWidth;
@synthesize shadowOffset = _shadowOffset;

@synthesize viewSize = _viewSize;

- (id)initWithSize:(FSPaneSize)size
{
    if (self = [super init]) {
        self.clipsToBounds = NO;
        
        _roundedCornersView = [UIView new];
        _roundedCornersView.backgroundColor = [UIColor clearColor];
        _roundedCornersView.layer.cornerRadius = 6.0;
        _roundedCornersView.layer.masksToBounds = YES;
        [self addSubview:_roundedCornersView];
        
        _viewSize = size;
        
        [self _addLeftBorderShadowView:[[FSPaneBorderShadowView alloc] initForLeftSide]
                            withWidth:20.0f];
        [self _addRightBorderShadowView:[[FSPaneBorderShadowView alloc] initForRightSide]
                            withWidth:20.0f];
        self.shadowOffset = 10.0f;
    }
    
    return self;
}

- (id)init 
{    
    return [self initWithSize:FSPaneSizeRegular];
}

#pragma mark - Custom accessors

- (void)setContentView:(UIView *)contentView
{
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        
        _contentView = contentView;
        
        if (_contentView) {
            [_contentView setAutoresizingMask:
             UIViewAutoresizingFlexibleLeftMargin | 
             UIViewAutoresizingFlexibleRightMargin | 
             UIViewAutoresizingFlexibleBottomMargin | 
             UIViewAutoresizingFlexibleTopMargin | 
             UIViewAutoresizingFlexibleWidth | 
             UIViewAutoresizingFlexibleHeight];
            
            [_roundedCornersView addSubview:_contentView];
            [self setNeedsLayout];
        }
    }
}

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        
        _headerView = headerView;
        
        if (_headerView) {
            [_headerView setAutoresizingMask:
             UIViewAutoresizingFlexibleLeftMargin | 
             UIViewAutoresizingFlexibleRightMargin | 
             UIViewAutoresizingFlexibleTopMargin];
            [_headerView setUserInteractionEnabled:YES];
            
            [_roundedCornersView addSubview:_headerView];
            [self setNeedsLayout];
        }
    }
}

- (BOOL)isLoaded
{
    return self.superview != nil && self.contentView != nil;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    CGFloat viewWidth = bounds.size.width;
    CGFloat viewHeight = bounds.size.height;
    CGFloat headerHeight = 0.0f;
    
    _roundedCornersView.frame = bounds;
    
    if (_headerView) {
        headerHeight = _headerView.frame.size.height;
        
        CGRect newHeaderViewFrame = CGRectMake(0.0f, 0.0f, viewWidth, headerHeight);
        _headerView.frame = newHeaderViewFrame;
    }
    
    _contentView.frame = CGRectMake(0.0f, headerHeight, viewWidth, viewHeight - headerHeight);
    
    if (_leftShadowView) {
        CGRect shadowFrame = CGRectMake(0.0f - _shadowWidth + _shadowOffset, 0.0f, _shadowWidth, bounds.size.height);
        _leftShadowView.frame = shadowFrame;
    }
    if (_rightShadowView) {
        CGRect shadowFrame = CGRectMake(viewWidth - _shadowOffset, 0.0f, _shadowWidth, bounds.size.height);
        _rightShadowView.frame = shadowFrame;
    }
}

#pragma mark - FSPaneView ()

- (void)_addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width
{
    if (_shadowWidth != width) {
        _shadowWidth = width;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    if (view != _leftShadowView) {
        _leftShadowView = view;
        
        [self insertSubview:_leftShadowView atIndex:0];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)_addRightBorderShadowView:(UIView *)view withWidth:(CGFloat)width {
    if (_shadowWidth != width) {
        _shadowWidth = width;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    if (view != _rightShadowView) {
        _rightShadowView = view;
        
        [self insertSubview:_rightShadowView atIndex:0];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

@end
