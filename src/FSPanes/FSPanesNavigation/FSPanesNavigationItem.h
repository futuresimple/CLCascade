//
//  FSCascadeNavigationItem.h
//  Base-iOS-client
//
//  Created by Karol S. Mazur on 5/11/12.
//  Copyright (c) 2012 Future Simple. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FSPanesNavigationItem : NSObject

// Array will be nil if there are no bar items
@property (copy, nonatomic) NSArray *leftBarItems;
@property (copy, nonatomic) NSArray *titleBarItems;
@property (copy, nonatomic) NSArray *rightBarItems;

- (id)initWithLeftBarItem:(UIView *)leftItem 
             titleBarItem:(UIView *)titleItem 
          andRightBarItem:(UIView *)rightItem;

@end
