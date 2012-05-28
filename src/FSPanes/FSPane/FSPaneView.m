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
    UIView *_shadowView;
    UIView *_roundedCornersView;
}

- (void)updateRoundedCorners;

@end

@implementation FSPaneView

@synthesize footerView = _footerView;
@synthesize contentView = _contentView;
@synthesize headerView = _headerView;

@synthesize shadowWidth = _shadowWidth;
@synthesize shadowOffset = _shadowOffset;

@synthesize showRoundedCorners = _showRoundedCorners;
@synthesize rectCorner = _rectCorner;

@synthesize viewSize = _viewSize;

- (id)initWithSize:(FSViewSize)size
{
    if (self = [super init]) {
        _roundedCornersView = [[UIView alloc] init];
        [_roundedCornersView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_roundedCornersView];
        
        _viewSize = size;
        _rectCorner = UIRectCornerAllCorners;
        _showRoundedCorners = NO;
        
        [self addLeftBorderShadowView:[FSPaneBorderShadowView new]
                            withWidth:20.0];
        [self setShadowOffset:10.0];
    }
    
    return self;
}

- (id)init 
{    
    return [self initWithSize:FSViewSizeNormal];
}

#pragma mark Custom accessors

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
            
            [_roundedCornersView addSubview: _contentView];
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
            
            [_roundedCornersView addSubview: _headerView];
            [self setNeedsLayout];
        }
    }
}

- (void)setFooterView:(UIView *)footerView
{    
    if (_footerView != footerView) {
        [_footerView removeFromSuperview];
        
        _footerView = footerView;
        if (_footerView) {
            [_footerView setAutoresizingMask:
             UIViewAutoresizingFlexibleLeftMargin | 
             UIViewAutoresizingFlexibleRightMargin | 
             UIViewAutoresizingFlexibleBottomMargin];
            [_footerView setUserInteractionEnabled:YES];
            
            [_roundedCornersView addSubview: _footerView];
            [self setNeedsLayout];
        }
    }
}

- (void)setRectCorner:(UIRectCorner)corners
{
    if (corners != _rectCorner) {
        _rectCorner = corners;
        [self setNeedsLayout];
    }
}

- (void)setShowRoundedCorners:(BOOL)show
{
    if (show != _showRoundedCorners) {
        _showRoundedCorners = show;
        [self setNeedsLayout];
    }
}

- (void)addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width
{
    self.clipsToBounds = NO;
    
    if (_shadowWidth != width) {
        _shadowWidth = width;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    if (view != _shadowView) {
        _shadowView = view;
        
        [self insertSubview:_shadowView atIndex:0];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (BOOL)isLoaded
{
    return self.superview != nil;
}

#pragma mark Private methods

- (void)updateRoundedCorners
{
    if (_showRoundedCorners) {
        CGRect toolbarBounds = self.bounds;
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:toolbarBounds
                                                   byRoundingCorners:_rectCorner
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [maskLayer setPath:[path CGPath]];
        
        _roundedCornersView.layer.masksToBounds = YES;
        _roundedCornersView.layer.mask = maskLayer;
    } 
    else {
        _roundedCornersView.layer.masksToBounds = NO;
        _roundedCornersView.layer.mask = nil;
    }
}

- (void)layoutSubviews 
{
    CGRect rect = self.bounds;
    
    CGFloat viewWidth = rect.size.width;
    CGFloat viewHeight = rect.size.height;
    CGFloat headerHeight = 0.0f;
    CGFloat footerHeight = 0.0f;
    
    _roundedCornersView.frame = rect;
    
    if (_headerView) {
        headerHeight = _headerView.frame.size.height;
        
        CGRect newHeaderViewFrame = CGRectMake(0.0f, 0.0f, viewWidth, headerHeight);
        _headerView.frame = newHeaderViewFrame;
    }
    
    if (_footerView) {
        footerHeight = _footerView.frame.size.height;
        CGFloat footerY = viewHeight - footerHeight;
        
        CGRect newFooterViewFrame = CGRectMake(0.0f, footerY, viewWidth, footerHeight);
        _footerView.frame = newFooterViewFrame;
    }
    
    _contentView.frame = CGRectMake(0.0f, headerHeight, viewWidth, viewHeight - headerHeight - footerHeight);
    
    if (_shadowView) {
        CGRect shadowFrame = CGRectMake(0.0f - _shadowWidth + _shadowOffset, 0.0f, _shadowWidth, rect.size.height);
        _shadowView.frame = shadowFrame;
    }
    
    [self updateRoundedCorners];
}

@end
