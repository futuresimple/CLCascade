//
//  FSPanesMenuViewController.h
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

#import <UIKit/UIKit.h>
#import "FSPanesNavigationController.h"

@interface FSPanesMenuViewController : UITableViewController

@property (copy, nonatomic) NSArray *rootPaneControllers;

- (void)selectPaneAtIndex:(NSUInteger)index;

@end
