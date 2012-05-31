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
#import "UIViewController+FSPaneView.h"
#import "UIViewController+FSPanes.h"

@interface FSPanesNavigationController (Private)
- (void)addPagesRoundedCorners;
- (void)addRoundedCorner:(UIRectCorner)rectCorner toPageAtIndex:(NSInteger)index;
- (void)_popPanesFromLastIndexTo:(NSInteger)index;
- (void)_replaceViewControllerAtIndex:(NSUInteger)oldViewControllerIndex
                   withViewController:(UIViewController *)newViewController
                             animated:(BOOL)animated
                             viewSize:(FSViewSize)size;
@end

@implementation FSPanesNavigationController

@synthesize leftInset, widerLeftInset;

#pragma mark -
#pragma mark UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
    [_navigationView unloadInvisiblePanes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor clearColor]];
    
    _navigationView = [[FSPanesNavigationView alloc] initWithFrame:self.view.bounds];
    _navigationView.delegate = self;
    _navigationView.dataSource = self;
    [self.view addSubview:_navigationView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_navigationView removeFromSuperview];
    _navigationView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [_navigationView updateContentLayoutToInterfaceOrientation:interfaceOrientation
                                                      duration:duration];
}

#pragma mark -
#pragma mark Setters & getters
- (CGFloat)widerLeftInset
{
    return _navigationView.widerLeftInset;
}

- (void) setWiderLeftInset:(CGFloat)inset
{
    [_navigationView setWiderLeftInset:inset];    
}

- (CGFloat)leftInset
{
    return _navigationView.leftInset;
}

- (void)setLeftInset:(CGFloat)inset
{
    [_navigationView setLeftInset:inset];
}

#pragma mark -
#pragma marl test

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*) rootViewController {
    if ([self.childViewControllers count] > 0) {
        return [self.childViewControllers objectAtIndex: 0];
    }
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*) lastViewController {
    return [self.childViewControllers lastObject];
}


#pragma mark -
#pragma marl CLCascadeViewDataSource
- (UIView *)navigationView:(FSPanesNavigationView *)navigationView viewAtIndex:(NSInteger)index
{
    return [[self.childViewControllers objectAtIndex:index] view];    
}

- (NSInteger)numberOfPanesInCascadeView:(FSPanesNavigationView *)navigationView
{
    return [self.childViewControllers count];
}

#pragma mark -
#pragma marl CLCascadeViewDelegate
- (void)cascadeView:(FSPanesNavigationView *)navigationView didLoadPane:(UIView *)pane
{
    
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView didUnloadPane:(UIView *)pane
{
    
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView didAddPane:(UIView *)pane animated:(BOOL)animated
{
    
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView didPopPaneAtIndex:(NSInteger)index
{
    UIViewController *vc = [self.childViewControllers objectAtIndex:index];
    [vc removeFromParentViewController];
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView paneDidAppearAtIndex:(NSInteger)index
{
    if (index > [self.childViewControllers count] - 1) return;
    
    //TODO: Decide whether we want to send -viewDidAppear: here or not
    //    UIViewController<CLViewControllerDelegate>* controller = [_viewControllers objectAtIndex: index];
    //    if ([controller respondsToSelector:@selector(pageDidAppear)]) {
    //        [controller pageDidAppear];
    //    }
    
    [self addPagesRoundedCorners];
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView paneDidDisappearAtIndex:(NSInteger)index
{
    if (index > [self.childViewControllers count] - 1) return;
    
    //TODO: Decide whether we want to send -viewDidDisappear: here or not
    //    UIViewController<CLViewControllerDelegate>* controller = [_viewControllers objectAtIndex: index];
    //    if ([controller respondsToSelector:@selector(pageDidDisappear)]) {
    //        [controller pageDidDisappear];
    //    }
    
    [self addPagesRoundedCorners];
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

#pragma mark -
#pragma mark FSPanesNavigationController
- (void)setRootViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setRootViewController:viewController animated:animated viewSize:FSViewSizeNormal];
}

- (void)setRootViewController:(UIViewController *)viewController animated:(BOOL)animated viewSize:(FSViewSize)viewSize
{
    if ([self.childViewControllers count] > 0) {
        [self _replaceViewControllerAtIndex:0
                         withViewController:viewController
                                   animated:animated
                                   viewSize:viewSize];
    }
    else {
        [self addViewController:viewController sender:nil animated:animated viewSize:viewSize];
    }
}

- (void)addViewController:(UIViewController *)viewController sender:(UIViewController *)sender animated:(BOOL)animated
{
    [self addViewController:viewController sender:sender animated:animated viewSize:FSViewSizeNormal];
}

- (void)addViewController:(UIViewController *)viewController sender:(UIViewController *)sender animated:(BOOL)animated viewSize:(FSViewSize)size
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
        [_navigationView pushView:[viewController view]
                         animated:animated
                         viewSize:size];
        [viewController didMoveToParentViewController:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*) firstVisibleViewController {
    NSInteger index = [_navigationView indexOfFirstVisibleView: YES];
    
    if (index != NSNotFound) {
        return [self.childViewControllers objectAtIndex: index];
    }
    
    return nil;
}


#pragma mark -
#pragma mark Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addRoundedCorner:(UIRectCorner)rectCorner toPageAtIndex:(NSInteger)index {
    
    if (index != NSNotFound) {
        UIViewController* firstVisibleController = [self.childViewControllers objectAtIndex: index];
        
        FSPaneView* view = firstVisibleController.segmentedView;
        [view setShowRoundedCorners: YES];
        [view setRectCorner: rectCorner];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addPagesRoundedCorners {
    
    // unload all rounded corners
    for (id item in [_navigationView visiblePanes]) {
        if (item != [NSNull null]) {
            if ([item isKindOfClass:[FSPaneView class]]) {
                FSPaneView* view = (FSPaneView*)item;
                [view setShowRoundedCorners: NO];
            }
        }
    }
    
    // get index of first visible page
    NSInteger indexOfFirstVisiblePage = [_navigationView indexOfFirstVisibleView: NO];
    
    // get index of last visible page
    NSInteger indexOfLastVisiblePage = [_navigationView indexOfLastVisibleView: NO];
    
    if (indexOfLastVisiblePage == indexOfFirstVisiblePage) {
        [self addRoundedCorner:UIRectCornerAllCorners toPageAtIndex: indexOfFirstVisiblePage];
        
    } else {
        
        [self addRoundedCorner:UIRectCornerTopLeft | UIRectCornerBottomLeft toPageAtIndex:indexOfFirstVisiblePage];
        
        if (indexOfLastVisiblePage == [self.childViewControllers count] -1) {
            [self addRoundedCorner:UIRectCornerTopRight | UIRectCornerBottomRight toPageAtIndex:indexOfLastVisiblePage];
        }    
    }
}


- (void)_popPanesFromLastIndexTo:(NSInteger)toIndex
{
    NSUInteger childControllersCount = [self.childViewControllers count];
    
    if (toIndex >= 0 && toIndex < childControllersCount) {
        for (NSUInteger index=childControllersCount-1; index >= toIndex; index--) {
            UIViewController *viewController = [self.childViewControllers objectAtIndex:index];
            [viewController willMoveToParentViewController:nil];
            
            [_navigationView popPaneAtIndex:index animated:NO];
        }
    }    
}

- (void)_replaceViewControllerAtIndex:(NSUInteger)oldViewControllerIndex
                   withViewController:(UIViewController *)newViewController
                             animated:(BOOL)animated
                             viewSize:(FSViewSize)size
{
    [self _popPanesFromLastIndexTo:oldViewControllerIndex+1];
    
    [self addChildViewController:newViewController];
    [_navigationView replaceViewAtIndex:oldViewControllerIndex
                               withView:[newViewController view]
                               viewSize:size];
    [newViewController didMoveToParentViewController:self];
}

@end
