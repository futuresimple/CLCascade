//
//  FSPanesSplitViewController.m
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

#import "FSPanesSplitViewController.h"
#import "FSPanesSplitView.h"
#import "FSPanesMenuViewController.h"
#import "FSPanesNavigationController.h"
#import "FSNavigationMenuDataSource.h"

@interface FSPanesSplitViewController ()

@property (strong, nonatomic, readwrite) FSPanesSplitView *view;
@property (readwrite, strong, nonatomic) FSPanesMenuViewController *panesMenuViewController;
@property (readwrite, strong, nonatomic) FSPanesNavigationController *panesNavigationController;

@end

@implementation FSPanesSplitViewController

#pragma mark - @ properties

@dynamic view; // supplied by super
@dynamic selectedIndex;
@dynamic leftInset;
@synthesize panesMenuViewController = _panesMenuViewController;
@synthesize panesNavigationController = _panesNavigationController;

- (NSUInteger)selectedIndex
{
    return [self.panesMenuViewController.menuDataSource indexOfViewController:self.panesNavigationController.rootViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex < [self.panesMenuViewController.menuDataSource numberOfMenuItems] &&
        self.selectedIndex != selectedIndex) {
        [self.panesMenuViewController selectPaneAtIndex:selectedIndex];
    }
}

- (void)setPanesMenuViewController:(FSPanesMenuViewController *)viewController 
{
    if (_panesMenuViewController == nil) { // single use setter
        _panesMenuViewController = viewController;
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)setPanesNavigationController:(FSPanesNavigationController *)viewController 
{
    if (_panesNavigationController == nil) { // single use setter
        _panesNavigationController = viewController;
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}

- (CGFloat)leftInset
{
    return self.panesNavigationController.navigationView.leftInset;
}

- (void)setLeftInset:(CGFloat)inset
{
    [self.panesNavigationController.navigationView setLeftInset:inset];
    self.view.menuViewWidth = self.panesNavigationController.navigationView.widerLeftInset;
}

#pragma mark - FSPanesSplitViewController

- (id)initWithCustomNavigationController:(FSPanesNavigationController *)navigationController
                      menuViewController:(FSPanesMenuViewController *)menuViewController
           rootPaneControllersDataSource:(id <FSNavigationMenuDataSource>) dataSource;
{
    if (self = [super init]) {
        menuViewController.menuDataSource = dataSource;
        
        if(menuViewController == nil) {
            menuViewController = [FSPanesMenuViewController new];
        }
        self.panesMenuViewController = menuViewController;
        
        if(navigationController == nil) {
            navigationController = [FSPanesNavigationController new];
        }
        self.panesNavigationController = navigationController;

    }
    return self;
}

- (id)initWithRootPaneControllersDataSource:(id <FSNavigationMenuDataSource>)dataSource
{
    return [self initWithCustomNavigationController:nil
                                 menuViewController:nil
                                rootPaneControllersDataSource:dataSource];
}

- (void)dealloc
{
    [_panesMenuViewController removeFromParentViewController];
    [_panesNavigationController removeFromParentViewController];
}

#pragma mark View lifecycle

- (void)loadView 
{    
    FSPanesSplitView *splitView = [FSPanesSplitView new];
    [splitView setMenuView:self.panesMenuViewController.view];
    [splitView setNavigationView:self.panesNavigationController.view];
    [splitView setSplitViewController:self];
    
    self.view = splitView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
                                         duration:(NSTimeInterval)duration 
{
    if ([_panesNavigationController respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) {
        [_panesNavigationController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView 
{
    [(FSPanesSplitView *)self.view setBackgroundView:backgroundView];
}

- (void)setDividerImage:(UIImage *)image 
{
    [(FSPanesSplitView *)self.view setVerticalDividerImage:image];
}

@end
