//
//  FSPanesNavigationController.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 11-05-06.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPanesNavigationController.h"
#import "FSPaneView.h"
#import "UIViewController+FSPanes.h"

@interface FSPanesNavigationController ()

@property (strong, nonatomic, readwrite) FSPanesNavigationView *view;

- (void)_setRootViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                      viewSize:(FSPaneSize)viewSize;
- (void)_addViewController:(UIViewController *)viewController
                    sender:(UIViewController *)sender
                  animated:(BOOL)animated
                  viewSize:(FSPaneSize)size;
- (void)_popPanesFromLastIndexTo:(NSInteger)index;
- (void)_replaceViewControllerAtIndex:(NSUInteger)oldViewControllerIndex
                   withViewController:(UIViewController *)newViewController
                             animated:(BOOL)animated
                             viewSize:(FSPaneSize)size;

@end

@implementation FSPanesNavigationController

@dynamic view; // supplied by super

- (FSPanesNavigationView *)navigationView
{
    return self.view;
}

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[FSPanesNavigationView alloc] init];
    
    self.view.delegate = self;
    self.view.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self.navigationView updateContentLayoutToInterfaceOrientation:interfaceOrientation
                                                          duration:duration];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
    [self.navigationView unloadInvisiblePanes];
}

#pragma mark - <FSPanesNavigationViewDataSource>

- (UIView *)navigationView:(FSPanesNavigationView *)navigationView contentViewAtIndex:(NSInteger)index
{
    return [[self.childViewControllers objectAtIndex:index] view];
}

- (UIView *)navigationView:(FSPanesNavigationView *)navigationView headerViewAtIndex:(NSInteger)index
{
    UIView *header = nil;
    UIViewController <FSPaneControllerDelegate> *controller = [self.childViewControllers objectAtIndex:index];
    if ([controller respondsToSelector:@selector(paneNavigationBarView)]) {
        header = controller.paneNavigationBarView;
    }
    return header;
}

- (NSInteger)numberOfPanesInNavigationView:(FSPanesNavigationView *)navigationView
{
    return [self.childViewControllers count];
}

#pragma mark <FSPanesNavigationViewDelegate>

- (void)navigationView:(FSPanesNavigationView *)navigationView didLoadPaneAtIndex:(NSInteger)index
{
    
}

- (void)navigationView:(FSPanesNavigationView *)navigationView didUnloadPaneAtIndex:(NSInteger)index
{
    
}

- (void)navigationView:(FSPanesNavigationView *)navigationView didAddPane:(UIView *)pane animated:(BOOL)animated
{
    
}

- (void)navigationView:(FSPanesNavigationView *)navigationView didPopPaneAtIndex:(NSInteger)index
{
    UIViewController *vc = [self.childViewControllers objectAtIndex:index];
    [vc removeFromParentViewController];
}

- (void)navigationView:(FSPanesNavigationView *)navigationView paneDidAppearAtIndex:(NSInteger)index
{
    
}

- (void)navigationView:(FSPanesNavigationView *)navigationView paneDidDisappearAtIndex:(NSInteger)index
{
    
}

- (void)navigationViewDidStartPullingToDetachPanes:(FSPanesNavigationView *)navigationView
{
    /*
     Override this methods to implement own actions, animations
     */
}

- (void)navigationViewDidPullToDetachPanes:(FSPanesNavigationView *)navigationView
{
    /*
     Override this methods to implement own actions, animations
     */
}

- (void)navigationViewDidCancelPullToDetachPanes:(FSPanesNavigationView *)navigationView
{
    /*
     Override this methods to implement own actions, animations
     */
}

#pragma mark - FSPanesNavigationController

- (void)setRootViewController:(UIViewController <FSPaneControllerDelegate> *)viewController animated:(BOOL)animated
{
    if (viewController != [self rootViewController]) {
        FSPaneSize paneSize = FSPaneSizeRegular;
        if ([viewController respondsToSelector:@selector(paneSize)]) {
            paneSize = viewController.paneSize;
        }
        
        [self _setRootViewController:viewController animated:animated viewSize:paneSize];
    }
}

- (void)addViewController:(UIViewController <FSPaneControllerDelegate> *)viewController sender:(UIViewController *)sender animated:(BOOL)animated
{
    FSPaneSize paneSize = FSPaneSizeRegular;
    if ([viewController respondsToSelector:@selector(paneSize)]) {
        paneSize = viewController.paneSize;
    }
    
    [self _addViewController:viewController sender:sender animated:animated viewSize:paneSize];
}

- (void)popViewControler:(UIViewController *)viewController animated:(BOOL)animated
{
    NSUInteger indexOfViewControllerBeingPoped = [self.childViewControllers indexOfObject:viewController];
    if (indexOfViewControllerBeingPoped != NSNotFound) {        
        [self _popPanesFromLastIndexTo:indexOfViewControllerBeingPoped];
    }
}

- (UIViewController *)rootViewController
{
    if ([self.childViewControllers count] > 0) {
        return [self.childViewControllers objectAtIndex:0];
    }
    return nil;
}

- (UIViewController *)lastViewController
{
    return [self.childViewControllers lastObject];
}

- (UIViewController *)firstVisibleViewController
{
    NSInteger index = [self.navigationView indexOfFirstVisibleView:YES];
    
    if (index != NSNotFound) {
        return [self.childViewControllers objectAtIndex:index];
    }
    
    return nil;
}

#pragma mark - FSPanesNavigationController ()

- (void)_setRootViewController:(UIViewController *)viewController animated:(BOOL)animated viewSize:(FSPaneSize)viewSize
{
    if ([self.childViewControllers count] > 0) {
        [self _replaceViewControllerAtIndex:0
                         withViewController:viewController
                                   animated:animated
                                   viewSize:viewSize];
    }
    else {
        [self _addViewController:viewController sender:nil animated:animated viewSize:viewSize];
    }
}

- (void)_addViewController:(UIViewController *)viewController sender:(UIViewController *)sender animated:(BOOL)animated viewSize:(FSPaneSize)size
{
    NSUInteger indexOfSender = [self.childViewControllers indexOfObject:sender];
    NSUInteger indexOfLastViewController = [self.childViewControllers count] - 1;
    
    if (indexOfSender != NSNotFound && indexOfSender != indexOfLastViewController) {
        [self _replaceViewControllerAtIndex:indexOfSender+1
                         withViewController:viewController
                                   animated:animated
                                   viewSize:size];
    }
    else {
        [self addChildViewController:viewController];
        [self.navigationView pushPane:[viewController view]
                             animated:animated
                             viewSize:size];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)_popPanesFromLastIndexTo:(NSInteger)toIndex
{
    NSUInteger childControllersCount = [self.childViewControllers count];
    
    if (toIndex >= 0 && toIndex < childControllersCount) {
        for (NSUInteger index=childControllersCount-1; index >= toIndex; index--) {
            UIViewController *viewController = [self.childViewControllers objectAtIndex:index];
            [viewController willMoveToParentViewController:nil];
            
            [self.navigationView popPaneAtIndex:index animated:NO];
        }
    }    
}

- (void)_replaceViewControllerAtIndex:(NSUInteger)oldViewControllerIndex
                   withViewController:(UIViewController *)newViewController
                             animated:(BOOL)animated
                             viewSize:(FSPaneSize)size
{
    UIViewController *oldViewController = [self.childViewControllers objectAtIndex:oldViewControllerIndex];
    
    if (newViewController != oldViewController) {
        NSUInteger childControllersCount = [self.childViewControllers count];
        NSUInteger lastControllerIndex = childControllersCount-1;
        
        if (oldViewControllerIndex < lastControllerIndex) {
            for (NSUInteger index = lastControllerIndex; index > oldViewControllerIndex; index--) {
                UIViewController *viewController = [self.childViewControllers objectAtIndex:index];
                [viewController willMoveToParentViewController:nil];
            }
        }
        
        [self addChildViewController:newViewController];
        [oldViewController willMoveToParentViewController:nil];
        [self.navigationView replacePaneAtIndex:oldViewControllerIndex
                                       withView:[newViewController view]
                                       viewSize:size
                               popAnyPanesAbove:YES];
        [newViewController didMoveToParentViewController:self];
    }
}

@end
