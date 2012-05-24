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

@implementation FSPanesSplitViewController

@synthesize panesMenuViewController = _panesMenuViewController;
@synthesize panesNavigationController = _panesNavigationController;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithNavigationController:(FSPanesNavigationController*)navigationController {
    self = [super init];
    if (self) {
        _panesNavigationController = navigationController;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    _panesMenuViewController = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
    NSString *nib = self.nibName;
    if (nib) {
        NSBundle *bundle = self.nibBundle;
        if(!bundle) bundle = [NSBundle mainBundle];
        
        NSString *path = [bundle pathForResource:nib ofType:@"nib"];
        
        if(path) {
            self.view = [[bundle loadNibNamed:nib owner:self options:nil] objectAtIndex: 0];
            FSPanesSplitView* view_ = (FSPanesSplitView*)self.view;
            [view_ setMenuView: self.panesMenuViewController.view];
            [view_ setNavigationView: self.panesNavigationController.view];
            
            return;
        }
    }
    
    FSPanesSplitView* view_ = [[FSPanesSplitView alloc] init];
    self.view = view_;
    
    [view_ setMenuView: self.panesMenuViewController.view];
    [view_ setNavigationView: self.panesNavigationController.view];
    [view_ setSplitViewController:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.panesNavigationController = nil;
    self.panesMenuViewController = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    if ([_panesNavigationController respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) {
        [_panesNavigationController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    }
}

#pragma mark -
#pragma mark Class methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setBackgroundView:(UIView*)backgroundView {
    [(FSPanesSplitView*)self.view setBackgroundView: backgroundView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDividerImage:(UIImage*)image {
    [(FSPanesSplitView*)self.view setVerticalDividerImage: image];
    
}


#pragma mark -
#pragma mark Setters 

/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPanesMenuViewController:(FSPanesMenuViewController *)viewController {
    if (viewController != _panesMenuViewController) {
        _panesMenuViewController = viewController;
        [(FSPanesSplitView*)self.view setMenuView: viewController.view];
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPanesNavigationController:(FSPanesNavigationController *)viewController {
    if (viewController != _panesNavigationController) {
        _panesNavigationController = viewController;
        [(FSPanesSplitView*)self.view setNavigationView: viewController.view];
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}


@end
