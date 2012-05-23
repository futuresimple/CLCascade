//
//  FSPanesNavigationController.h
//  Panes
//
//  Created by Emil Wojtaszek on 11-05-06.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>
#import "FSPanesGlobal.h"
#import "FSPanesNavigationView.h"

@interface FSPanesNavigationController : UIViewController <FSPanesNavigationViewDataSource, FSPanesNavigationViewDelegate> {
    // view containing all views on stack
    FSPanesNavigationView *_cascadeView;
}


/*
 * Left inset of normal size pages from left boarder
 */
@property(nonatomic) CGFloat leftInset;

/*
 * Left inset of wider size page from left boarder. Default 220.0f
 */
@property(nonatomic) CGFloat widerLeftInset;

/*
 * Set and push root view controller
 */
- (void) setRootViewController:(UIViewController*)viewController animated:(BOOL)animated;

/*
 * Push new view controller from sender.
 * If sender is not last, then controller pop next controller and push new view from sender
 */
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated;
- (void) addViewController:(UIViewController*)viewController sender:(UIViewController*)sender animated:(BOOL)animated viewSize:(FSViewSize)size;

/* 
 First in hierarchy CascadeViewController (opposite to lastCascadeViewController)
 */
- (UIViewController*) rootViewController;

/* 
 Last in hierarchy CascadeViewController (opposite to rootViewController)
 */
- (UIViewController*) lastCascadeViewController;

/* 
 Return first visible view controller (load if needed)
 */
- (UIViewController*) firstVisibleViewController;


@end
