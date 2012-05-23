//
//  FSPaneView+Extension.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 09.04.2012.
//  Copyright (c) 2012 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPaneView+Extension.h"

@implementation FSPaneView (Extension)
@dynamic viewSize;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setViewSize:(FSViewSize)viewSize {
    _viewSize = viewSize;
}

@end
