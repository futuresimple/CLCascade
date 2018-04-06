//
//  FSPanesMenuViewController.m
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

#import "FSPanesMenuViewController.h"
#import "UIViewController+FSPanes.h"
#import "FSNavigationMenuDataSource.h"

@implementation FSPanesMenuViewController

- (id)init
{
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // reselect cell for currently displayed root pane controller
    NSUInteger selectedIndex = [self.menuDataSource indexOfViewController:self.panesNavigationController.rootViewController];
    if (selectedIndex != NSNotFound) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        [self.tableView selectRowAtIndexPath:newSelectedIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - FSPanesMenuViewController

- (void)selectPaneAtIndex:(NSUInteger)index
{
    NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:newSelectedIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    
    UIViewController *viewController = [self.menuDataSource viewControllerForMenuItemAtIndex:index];
    if (viewController) {
        [self.panesNavigationController setRootViewController:viewController animated:YES];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuDataSource numberOfMenuItems];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FSPanesMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.menuDataSource titleOfViewControllerAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectPaneAtIndex:indexPath.row];
}

@end
