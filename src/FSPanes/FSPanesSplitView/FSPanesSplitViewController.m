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

@interface FSPanesSplitViewController ()

@property (readwrite, strong, nonatomic) FSPanesMenuViewController *panesMenuViewController;
@property (readwrite, strong, nonatomic) FSPanesNavigationController *panesNavigationController;

@end

@implementation FSPanesSplitViewController

@synthesize panesMenuViewController = _panesMenuViewController;
@synthesize panesNavigationController = _panesNavigationController;

- (id)initWithMenuViewController:(FSPanesMenuViewController *)menuViewController 
          andRootPaneControllers:(NSArray *)rootPaneControllers
{
    if (self = [super init]) {
        menuViewController.rootPaneControllers = rootPaneControllers;
        self.panesMenuViewController = menuViewController;
        
        self.panesNavigationController = [FSPanesNavigationController new];
    }
    return self;
}

- (id)initWithRootPaneControllers:(NSArray *)rootPaneControllers
{
    return [self initWithMenuViewController:[FSPanesMenuViewController new] 
                     andRootPaneControllers:rootPaneControllers];
}

- (void)dealloc
{
    [_panesMenuViewController removeFromParentViewController];
    [_panesNavigationController removeFromParentViewController];
}

#pragma mark Custom accessors

- (void)setPanesMenuViewController:(FSPanesMenuViewController *)viewController 
{
    if (viewController != _panesMenuViewController) {
        _panesMenuViewController = viewController;
        [(FSPanesSplitView*)self.view setMenuView: viewController.view];
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)setPanesNavigationController:(FSPanesNavigationController *)viewController 
{
    if (viewController != _panesNavigationController) {
        _panesNavigationController = viewController;
        [(FSPanesSplitView*)self.view setNavigationView: viewController.view];
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
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

- (void)setDividerImage:(UIImage*)image 
{
    [(FSPanesSplitView *)self.view setVerticalDividerImage:image];
}

@end
