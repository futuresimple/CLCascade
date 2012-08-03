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

@implementation FSPanesMenuViewController

@synthesize rootPaneControllers = _rootPaneControllers;

- (id)init
{
    return [super initWithStyle:UITableViewStylePlain];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - FSPanesMenuViewController

- (void)selectPaneAtIndex:(NSUInteger)index
{
    if (index < [self tableView:self.tableView numberOfRowsInSection:0]) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:newSelectedIndexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:newSelectedIndexPath];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rootPaneControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FSPanesMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIViewController *paneController = [self.rootPaneControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = paneController.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [self.rootPaneControllers objectAtIndex:indexPath.row];
    [self.panesNavigationController setRootViewController:viewController animated:YES];
}

@end
