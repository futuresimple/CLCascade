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
- (void) addPagesRoundedCorners;
- (void) addRoundedCorner:(UIRectCorner)rectCorner toPageAtIndex:(NSInteger)index;
- (void) popPagesFromLastIndexTo:(NSInteger)index;
- (void) removeAllPageViewControllers;
@end

@implementation FSPanesNavigationController

@synthesize leftInset, widerLeftInset;

- (void)dealloc
{
    _navigationView = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // unload all invisible pages in cascadeView
    [_navigationView unloadInvisiblePages];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set background color
    [self.view setBackgroundColor: [UIColor clearColor]];
    
    _navigationView = [[FSPanesNavigationView alloc] initWithFrame:self.view.bounds];
    _navigationView.delegate = self;
    _navigationView.dataSource = self;
    [self.view addSubview:_navigationView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_navigationView removeFromSuperview];
    _navigationView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:( UIInterfaceOrientation )interfaceOrientation
                                         duration:( NSTimeInterval )duration {
    [_navigationView updateContentLayoutToInterfaceOrientation:interfaceOrientation
                                                   duration:duration ];
}


#pragma mark -
#pragma mark Setters & getters

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) widerLeftInset {
    return _navigationView.widerLeftInset;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setWiderLeftInset:(CGFloat)inset {
    [_navigationView setWiderLeftInset: inset];    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) leftInset {
    return _navigationView.leftInset;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setLeftInset:(CGFloat)inset {
    [_navigationView setLeftInset: inset];
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

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*) cascadeView:(FSPanesNavigationView *)cascadeView pageAtIndex:(NSInteger)index {
    return [[self.childViewControllers objectAtIndex:index] view];    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) numberOfPagesInCascadeView:(FSPanesNavigationView*)cascadeView {
    return [self.childViewControllers count];
}


#pragma mark -
#pragma marl CLCascadeViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didLoadPage:(UIView*)page {
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didUnloadPage:(UIView*)page {
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didAddPage:(UIView*)page animated:(BOOL)animated {
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView didPopPageAtIndex:(NSInteger)index {
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView pageDidAppearAtIndex:(NSInteger)index {
    if (index > [self.childViewControllers count] - 1) return;
    
    //TODO: Decide whether we want to send -viewDidAppear: here or not
    //    UIViewController<CLViewControllerDelegate>* controller = [_viewControllers objectAtIndex: index];
    //    if ([controller respondsToSelector:@selector(pageDidAppear)]) {
    //        [controller pageDidAppear];
    //    }
    
    [self addPagesRoundedCorners];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeView:(FSPanesNavigationView*)cascadeView pageDidDisappearAtIndex:(NSInteger)index {
    if (index > [self.childViewControllers count] - 1) return;
    
    //TODO: Decide whether we want to send -viewDidDisappear: here or not
    //    UIViewController<CLViewControllerDelegate>* controller = [_viewControllers objectAtIndex: index];
    //    if ([controller respondsToSelector:@selector(pageDidDisappear)]) {
    //        [controller pageDidDisappear];
    //    }
    
    [self addPagesRoundedCorners];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeViewDidStartPullingToDetachPages:(FSPanesNavigationView*)cascadeView {
    /*
     Override this methods to implement own actions, animations
     */
    
    NSLog(@"cascadeViewDidStartPullingToDetachPages");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeViewDidPullToDetachPages:(FSPanesNavigationView*)cascadeView {
    /*
     Override this methods to implement own actions, animations
     */
    NSLog(@"cascadeViewDidPullToDetachPages");
    
    // pop page from back
    [self popPagesFromLastIndexTo:0];
    //load first page
    [cascadeView loadPageAtIndex:0];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) cascadeViewDidCancelPullToDetachPages:(FSPanesNavigationView*)cascadeView {
    /*
     Override this methods to implement own actions, animations
     */
    NSLog(@"cascadeViewDidCancelPullToDetachPages");
}

#pragma mark -
#pragma mark Calss methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setRootViewController:(UIViewController*)viewController animated:(BOOL)animated {
    // pop all pages
    [_navigationView popAllPagesAnimated: NO];
    // remove all controllers
    [self removeAllPageViewControllers];
    // add root view controller
    [self addViewController:viewController sender:nil animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated {
    [self addViewController:viewController sender:sender animated:animated viewSize:FSViewSizeNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated viewSize:(FSViewSize)size {
    // if in not sent from categoirs view
    if (sender) {
        
        // get index of sender
        NSInteger indexOfSender = [self.childViewControllers indexOfObject:sender];
        
        // if sender is not last view controller
        if (indexOfSender != [self.childViewControllers count] - 1) {
            
            // pop views and remove from _viewControllers
            [self popPagesFromLastIndexTo:indexOfSender];
        }
    }
    
    [self addChildViewController:viewController];
    
    // push view
    [_navigationView pushPage:[viewController view] 
                  fromPage:[sender view] 
                  animated:animated
                  viewSize:size];
    
    [viewController didMoveToParentViewController:self];
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
    for (id item in [_navigationView visiblePages]) {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) popPagesFromLastIndexTo:(NSInteger)toIndex {
    NSUInteger count = [self.childViewControllers count];
    
    if (count == 0) {
        return;
    }
    
    if (toIndex < 0) toIndex = 0;
    
    // index of last page
    NSUInteger index = count - 1;
    // pop page from back
    NSEnumerator* enumerator = [self.childViewControllers reverseObjectEnumerator];
    // enumarate pages
    while ([enumerator nextObject] && self.childViewControllers.count > toIndex+1) {
        if (![_navigationView canPopPageAtIndex: index]) {
            //dodikk - maybe break fits better
            continue;
        }
        
        UIViewController* viewController = [self.childViewControllers objectAtIndex:index];
        [viewController willMoveToParentViewController:nil];
        
        // pop page at index
        [_navigationView popPageAtIndex:index animated:NO];
        
        [viewController removeFromParentViewController];
        
        index--;
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeAllPageViewControllers {
    
    // pop page from back
    NSEnumerator* enumerator = [self.childViewControllers reverseObjectEnumerator];
    // enumarate pages
    while ([enumerator nextObject]) {
        
        UIViewController* viewController = [self.childViewControllers lastObject];
        [viewController willMoveToParentViewController:nil];
        
        [viewController removeFromParentViewController];
    }
}

@end
