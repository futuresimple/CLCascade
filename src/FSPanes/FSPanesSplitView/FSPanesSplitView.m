//
//  FSPanesSplitView.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-03-27.
//  Copyright 2011 CreativeLabs.pl
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPanesSplitView.h"
#import "FSPanesGlobal.h"
#import "FSPanesNavigationController.h"
#import "FSPanesSplitViewController.h"

@interface FSPanesSplitView ()
- (void)_setupView;
- (void)_addDivierView;
@end

@implementation FSPanesSplitView

@synthesize splitViewController = _splitViewController;

@synthesize menuView = _menuView;
@synthesize navigationView = _navigationView;
@synthesize backgroundView = _backgroundView;
@synthesize verticalDividerImage = _verticalDividerImage;

#pragma mark - FSPanesSplitView ()

- (void)_setupView
{
    [self setBackgroundColor:[UIColor blackColor]];
}

- (void)_addDivierView
{    
    if (_backgroundView && _verticalDividerImage)
    {
        if (_dividerView) {
            [_dividerView removeFromSuperview];
            _dividerView = nil;
        }
        
        _dividerView = [[UIView alloc] init];
        _dividerWidth = _verticalDividerImage.size.width;
        [_dividerView setBackgroundColor:[UIColor colorWithPatternImage:_verticalDividerImage]];
        
        [_backgroundView addSubview:_dividerView];
        [self setNeedsLayout];
    }
}

#pragma mark - UIView

- (id)init
{
    if (self = [super init]) {
        [self _setupView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _setupView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{    
    FSPanesNavigationController *panesNavigationController = _splitViewController.panesNavigationController;
    UIView *navigationView = [panesNavigationController view];
    
    if (CGRectContainsPoint(_menuView.frame, point)) {
        UIView *rootView = [[panesNavigationController firstVisibleViewController] view];
        CGRect rootViewRect = [rootView convertRect:rootView.bounds toView:self];
        
        if ((rootView) && (CGRectContainsPoint(rootViewRect, point))) {
            CGPoint newPoint = [self convertPoint:point toView:navigationView];
            return [navigationView hitTest:newPoint withEvent:event];
        }
        else {
            return [_menuView hitTest:point withEvent:event];
        }
        
    }
    else {
        CGPoint newPoint = [self convertPoint:point toView:navigationView];
        return [navigationView hitTest:newPoint withEvent:event];
    }
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    CGRect menuFrame = CGRectMake(0.0, 0.0, CATEGORIES_VIEW_WIDTH, bounds.size.height);
    _menuView.frame = menuFrame;
    
    CGRect navigationFrame = bounds;
    _navigationView.frame = navigationFrame;
    
    CGRect backgroundViewFrame = bounds;
    _backgroundView.frame = backgroundViewFrame;
    
    CGRect dividerViewFrame = CGRectMake(CATEGORIES_VIEW_WIDTH, 0.0, _dividerWidth, bounds.size.height);
    _dividerView.frame = dividerViewFrame;
}

#pragma mark - Setters

- (void)setMenuView:(UIView *)aView
{
    if (_menuView != aView) {
        _menuView = aView;
        
        [self addSubview:_menuView];
        [self bringSubviewToFront:_navigationView];
    }
}

- (void)setNavigationView:(UIView *)aView
{
    if (_navigationView != aView) {
        _navigationView = aView;
        
        [self addSubview:_navigationView];
        [self bringSubviewToFront:_navigationView];
    }
}

- (void)setBackgroundView:(UIView *)aView
{
    if (_backgroundView != aView) {
        _backgroundView = aView;
        
        [_dividerView removeFromSuperview];
        _dividerView = nil;
        
        [self addSubview:_backgroundView];
        [self sendSubviewToBack:_backgroundView];
        
        [self _addDivierView];
    }
}

- (void)setVerticalDividerImage:(UIImage *)image
{
    if (_verticalDividerImage != image) {
        _verticalDividerImage = image;
        
        [self _addDivierView];
    }
}

@end
