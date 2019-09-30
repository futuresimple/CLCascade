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

@property (nonatomic, strong) UIView *contentView;
@end

@implementation FSPanesSplitView

@synthesize splitViewController = _splitViewController;
@synthesize menuViewWidth = _menuViewWidth;
@synthesize menuView = _menuView;
@synthesize navigationView = _navigationView;
@synthesize backgroundView = _backgroundView;
@synthesize verticalDividerImage = _verticalDividerImage;

#pragma mark - FSPanesSplitView ()

- (void)_setupView
{
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.contentView];

    NSDictionary *views = @{@"content": self.contentView};
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];

    // on the iPad in landscape width is 20 and height is 1024 :)
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));

    NSDictionary *metrics = @{@"spacing": @(statusBarHeight)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[content]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[content]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
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
        FSPaneView *firstVisiblePane = [panesNavigationController.navigationView paneAtIndex:index];

        CGRect firstVisiblePaneRect = [firstVisiblePane.superview convertRect:firstVisiblePane.frame toView:self];
                    
        if (firstVisiblePane && CGRectContainsPoint(firstVisiblePaneRect, point)) {
            touchedView = navigationView;
        }
        else {
            touchedView = _menuView;
        }
    }
    else {
        touchedView = nil;
    }

    if (touchedView) {
        CGPoint newPoint = [self convertPoint:point toView:touchedView];
        return [touchedView hitTest:newPoint withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    
    CGRect menuFrame = CGRectMake(0.0, 0.0, self.menuViewWidth, bounds.size.height);
    _menuView.frame = menuFrame;
    
    CGRect navigationFrame = bounds;
    _navigationView.frame = navigationFrame;
    
    CGRect backgroundViewFrame = bounds;
    _backgroundView.frame = backgroundViewFrame;
    
    CGRect dividerViewFrame = CGRectMake(self.menuViewWidth, 0.0, _dividerWidth, bounds.size.height);
    _dividerView.frame = dividerViewFrame;
}

#pragma mark - Setters

- (void)setMenuView:(UIView *)aView
{
    if (_menuView != aView) {
        _menuView = aView;
        
        [self.contentView addSubview:_menuView];
        [self.contentView bringSubviewToFront:_navigationView];
    }
}

- (void)setNavigationView:(UIView *)aView
{
    if (_navigationView != aView) {
        _navigationView = aView;
        
        [self.contentView addSubview:_navigationView];
        [self.contentView bringSubviewToFront:_navigationView];
    }
}

- (void)setBackgroundView:(UIView *)aView
{
    if (_backgroundView != aView) {
        _backgroundView = aView;
        
        [self.contentView addSubview:_backgroundView];
        [self.contentView sendSubviewToBack:_backgroundView];
        
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
