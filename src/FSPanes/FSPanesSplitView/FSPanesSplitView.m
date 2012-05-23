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

@interface FSPanesSplitView (Private)
- (void) setupView;
- (void) addDivierView;
@end

@implementation FSPanesSplitView

@synthesize splitViewController = _splitViewController;

@synthesize menuView = _menuView;
@synthesize navigationView = _navigationView;
@synthesize backgroundView = _backgroundView;
@synthesize verticalDividerImage = _verticalDividerImage;


#pragma mark -
#pragma mark Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setupView {
    [self setBackgroundColor: [UIColor blackColor]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addDivierView {
    
    if ((!_backgroundView) || (!_verticalDividerImage)) return;
    
    if (_dividerView) {
        [_dividerView removeFromSuperview];
        _dividerView = nil;
    }
    
    _dividerView = [[UIView alloc] init];
    _dividerWidth = _verticalDividerImage.size.width;
    [_dividerView setBackgroundColor:[UIColor colorWithPatternImage: _verticalDividerImage]];
    
    [_backgroundView addSubview: _dividerView];
    [self setNeedsLayout];   
    
}


#pragma mark -
#pragma mark Init & dealloc

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    _navigationView = nil;
    _menuView = nil;
    _verticalDividerImage = nil;
    _dividerView = nil;
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    FSPanesNavigationController* panesNavigationController = _splitViewController.panesNavigationController;
    UIView* navigationView = [panesNavigationController view];
    
    if (CGRectContainsPoint(_menuView.frame, point)) {
        
        UIView* rootView = [[panesNavigationController firstVisibleViewController] view];
        CGRect rootViewRect = [rootView convertRect:rootView.bounds toView:self];
        
        if ((rootView) && (CGRectContainsPoint(rootViewRect, point))) {
            CGPoint newPoint = [self convertPoint:point toView:navigationView];
            return [navigationView hitTest:newPoint withEvent:event];
        } else {
            return [_menuView hitTest:point withEvent:event];
        }
        
    } else {
        CGPoint newPoint = [self convertPoint:point toView:navigationView];
        return [navigationView hitTest:newPoint withEvent:event];
    }
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) layoutSubviews {
    
    CGRect bounds = self.bounds;
    
    CGRect menuFrame = CGRectMake(0.0, 0.0, CATEGORIES_VIEW_WIDTH, bounds.size.height);
    _menuView.frame = menuFrame;
    
    CGRect navigationFrame = bounds;
    _navigationView.frame = navigationFrame;
    
    CGRect backgroundViewFrame = CGRectMake(CATEGORIES_VIEW_WIDTH, 0.0, bounds.size.width - CATEGORIES_VIEW_WIDTH, bounds.size.height);
    _backgroundView.frame = backgroundViewFrame;
    
    CGRect dividerViewFrame = CGRectMake(0.0, 0.0, _dividerWidth, bounds.size.height);
    _dividerView.frame = dividerViewFrame;
    
}


#pragma mark -
#pragma mark Setter

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setMenuView:(UIView*) aView {
    if (_menuView != aView) {
        _menuView = aView;
        
        [self addSubview: _menuView];
        [self bringSubviewToFront: _navigationView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setNavigationView:(UIView*) aView {
    if (_navigationView != aView) {
        _navigationView = aView;
        
        [self addSubview: _navigationView];
        [self bringSubviewToFront: _navigationView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setBackgroundView:(UIView*) aView {
    if (_backgroundView != aView) {
        _backgroundView = aView;
        
        [_dividerView removeFromSuperview];
        _dividerView = nil;
        
        if (_navigationView == nil) {
            [self addSubview: _backgroundView];
        } else {
            NSUInteger index = [self.subviews indexOfObject: _navigationView];
            [self insertSubview:_backgroundView atIndex:index];
        }
        
        [self addDivierView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setVerticalDividerImage:(UIImage*) image {
    if (_verticalDividerImage != image) {
        _verticalDividerImage = image;
        
        [self addDivierView];
    }
}

@end
