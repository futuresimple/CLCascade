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

@interface FSPanesNavigationController ()
{
    FSPanesNavigationView *_navigationView;
}

- (void)setRootViewController:(UIViewController *)viewController 
                     animated:(BOOL)animated 
                     viewSize:(FSPaneSize)viewSize;

- (void)addViewController:(UIViewController *)viewController
                   sender:(UIViewController *)sender
                 animated:(BOOL)animated
                 viewSize:(FSPaneSize)size;

- (void)_addPanesRoundedCorners;
- (void)_addRoundedCorner:(UIRectCorner)rectCorner toPaneAtIndex:(NSInteger)index;
- (void)_popPanesFromLastIndexTo:(NSInteger)index;
- (void)_replaceViewControllerAtIndex:(NSUInteger)oldViewControllerIndex
                   withViewController:(UIViewController *)newViewController
                             animated:(BOOL)animated
                             viewSize:(FSPaneSize)size;

@end

@implementation FSPanesNavigationController

@synthesize leftInset, widerLeftInset;

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
    [_navigationView unloadInvisiblePanes];
}

#pragma mark Custom accessors

- (CGFloat)widerLeftInset
{
    return _navigationView.widerLeftInset;
}

- (void)setWiderLeftInset:(CGFloat)inset
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

#pragma mark CLCascadeViewDataSource

- (UIView *)navigationView:(FSPanesNavigationView *)navigationView viewAtIndex:(NSInteger)index
{
    return [[self.childViewControllers objectAtIndex:index] view];    
}

- (NSInteger)numberOfPanesInCascadeView:(FSPanesNavigationView *)navigationView
{
    return [self.childViewControllers count];
}

#pragma mark CLCascadeViewDelegate

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
    
    [self _addPanesRoundedCorners];
}

- (void)cascadeView:(FSPanesNavigationView *)navigationView paneDidDisappearAtIndex:(NSInteger)index
{
    if (index > [self.childViewControllers count] - 1) return;
    
    //TODO: Decide whether we want to send -viewDidDisappear: here or not
    //    UIViewController<CLViewControllerDelegate>* controller = [_viewControllers objectAtIndex: index];
    //    if ([controller respondsToSelector:@selector(pageDidDisappear)]) {
    //        [controller pageDidDisappear];
    //    }
    
    [self _addPanesRoundedCorners];
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

- (void)setRootViewController:(UIViewController <FSPaneControllerDelegate> *)viewController animated:(BOOL)animated
{
    FSPaneSize paneSize = FSPaneSizeRegular;
    if ([viewController respondsToSelector:@selector(paneSize)]) {
        paneSize = viewController.paneSize;
    }
    
    [self setRootViewController:viewController animated:animated viewSize:paneSize];
}

- (void)setRootViewController:(UIViewController *)viewController animated:(BOOL)animated viewSize:(FSPaneSize)viewSize
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

- (void)addViewController:(UIViewController <FSPaneControllerDelegate> *)viewController sender:(UIViewController *)sender animated:(BOOL)animated
{
    FSPaneSize paneSize = FSPaneSizeRegular;
    if ([viewController respondsToSelector:@selector(paneSize)]) {
        paneSize = viewController.paneSize;
    }
    
    [self addViewController:viewController sender:sender animated:animated viewSize:paneSize];
}

- (void)addViewController:(UIViewController *)viewController sender:(UIViewController *)sender animated:(BOOL)animated viewSize:(FSPaneSize)size
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
    NSInteger index = [_navigationView indexOfFirstVisibleView:YES];
    
    if (index != NSNotFound) {
        return [self.childViewControllers objectAtIndex:index];
    }
    
    return nil;
}

#pragma mark -
#pragma mark FSPanesNavigationController (Private)
- (void)_addRoundedCorner:(UIRectCorner)rectCorner toPaneAtIndex:(NSInteger)index {
    
    if (index != NSNotFound) {
        UIViewController* firstVisibleController = [self.childViewControllers objectAtIndex: index];
        
        FSPaneView* view = firstVisibleController.segmentedView;
        [view setShowRoundedCorners: YES];
        [view setRectCorner: rectCorner];
    }
}

- (void)_addPanesRoundedCorners {
    // unload all rounded corners
    for (id item in [_navigationView visiblePanes]) {
        if (item != [NSNull null]) {
            if ([item isKindOfClass:[FSPaneView class]]) {
                FSPaneView* view = (FSPaneView*)item;
                [view setShowRoundedCorners: NO];
            }
        }
    }
    
    NSInteger indexOfFirstVisiblePane = [_navigationView indexOfFirstVisibleView: NO];
    NSInteger indexOfLastVisiblePane = [_navigationView indexOfLastVisibleView: NO];
    
    if (indexOfLastVisiblePane == indexOfFirstVisiblePane) {
        [self _addRoundedCorner:UIRectCornerAllCorners toPaneAtIndex: indexOfFirstVisiblePane];
        
    } else {
        
        [self _addRoundedCorner:UIRectCornerTopLeft | UIRectCornerBottomLeft toPaneAtIndex:indexOfFirstVisiblePane];
        
        if (indexOfLastVisiblePane == [self.childViewControllers count] -1) {
            [self _addRoundedCorner:UIRectCornerTopRight | UIRectCornerBottomRight toPaneAtIndex:indexOfLastVisiblePane];
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
                             viewSize:(FSPaneSize)size
{
    [self _popPanesFromLastIndexTo:oldViewControllerIndex+1];
    
    [self addChildViewController:newViewController];
    [_navigationView replaceViewAtIndex:oldViewControllerIndex
                               withView:[newViewController view]
                               viewSize:size];
    [newViewController didMoveToParentViewController:self];
}

@end
