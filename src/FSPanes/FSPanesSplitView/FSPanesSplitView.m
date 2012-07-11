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
    // Perhaps we'll put something here one day...
}

- (void)_addDivierView
{    
    if (_verticalDividerImage)
    {
        if (_dividerView) {
            [_dividerView removeFromSuperview];
        }
        
        _dividerView = [[UIView alloc] init];
        _dividerWidth = _verticalDividerImage.size.width;
        [_dividerView setBackgroundColor:[UIColor colorWithPatternImage:_verticalDividerImage]];
        
        if (self.backgroundView) {
            [self insertSubview:_dividerView aboveSubview:self.backgroundView];
        }
        else {
            [self insertSubview:_dividerView atIndex:0];
        }
        
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
    
    UIView *touchedView;
    
    if (CGRectContainsPoint(_menuView.frame, point)) {
        NSInteger index = [panesNavigationController.navigationView indexOfFirstVisibleView:YES];
        UIView *firstVisiblePane = [panesNavigationController.navigationView paneAtIndex:index];
        
        CGRect rootViewRect = [firstVisiblePane convertRect:firstVisiblePane.frame toView:self];
        
        if (firstVisiblePane && CGRectContainsPoint(rootViewRect, point)) {
            touchedView = navigationView;
        }
        else {
            touchedView = _menuView;
        }
        
    }
    else {
        touchedView = navigationView;
    }
    
    CGPoint newPoint = [self convertPoint:point toView:touchedView];
    return [touchedView hitTest:newPoint withEvent:event];
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
