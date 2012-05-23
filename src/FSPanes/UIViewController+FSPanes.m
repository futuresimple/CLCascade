//
//  UIViewController+FSPanes.m
//  FSPanes
//
//  Created by Błażej Biesiada on 5/11/12.
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "UIViewController+FSPanes.h"
#import "FSPanesSplitViewController.h"
#import "FSPanesNavigationController.h"

@implementation UIViewController (FSPanes)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (FSPanesSplitViewController *)panesSplitViewController {
    UIViewController *parent = self.parentViewController;
    
    if ([parent isKindOfClass:[FSPanesSplitViewController class]]) {
        return (FSPanesSplitViewController *)parent;
    }
    else {
        return parent.panesSplitViewController;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (FSPanesNavigationController *)panesNavigationController {
    UIViewController *parent = self.parentViewController;
    
    if ([parent isKindOfClass:[FSPanesNavigationController class]]) {
        return (FSPanesNavigationController *)parent;
    }
    else {
        return parent.panesNavigationController;
    }
}

@end
