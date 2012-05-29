//
//  FSCascadeNavigationItem.m
//  Base-iOS-client
//
//  Created by Karol S. Mazur on 5/11/12.
//  Copyright (c) 2012 Future Simple. All rights reserved.
//

#import "FSPanesNavigationItem.h"

@implementation FSPanesNavigationItem

@synthesize leftBarItems = _leftBarItems;
@synthesize titleBarItems = _titleBarItems;
@synthesize rightBarItems = _rightBarItems;

- (id)initWithLeftBarItem:(UIView *)leftItem 
             titleBarItem:(UIView *)titleItem 
          andRightBarItem:(UIView *)rightItem
{
    if (self = [super init]) {
        if (leftItem) {
            _leftBarItems = [NSArray arrayWithObject:leftItem];
        }
        
        if (titleItem) {
            _titleBarItems = [NSArray arrayWithObject:titleItem];
        }
        
        if (rightItem) {
            _rightBarItems = [NSArray arrayWithObject:rightItem];
        }
    }
    return self;
}

@end
