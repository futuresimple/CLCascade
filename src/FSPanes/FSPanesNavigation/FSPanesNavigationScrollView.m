//
//  FSPanesNavigationScrollView.m
//  FSPanes
//
//  Created by Emil Wojtaszek on 26.07.2011.
//  Copyright 2011 AppUnite
//
//  Modified by Błażej Biesiada, Karol S. Mazur
//  Copyright 2012 Future Simple Inc.
//
//  Licensed under the Apache License, Version 2.0.
//

#import "FSPanesNavigationScrollView.h"

@implementation FSPanesNavigationScrollView

- (id)init
{
    if (self = [super init]) {
        [self setClipsToBounds: NO];
        [self setDecelerationRate: UIScrollViewDecelerationRateFast];
        [self setScrollsToTop: NO];
        [self setBounces: YES];
        [self setAlwaysBounceVertical: NO];
        [self setAlwaysBounceHorizontal: YES];
        [self setDirectionalLockEnabled: YES];
        [self setDelaysContentTouches:YES];
        [self setMultipleTouchEnabled:NO];
        [self setShowsVerticalScrollIndicator: NO];
        [self setShowsHorizontalScrollIndicator: NO];
        [self setPagingEnabled:NO];
        
        [self setAutoresizingMask:
         UIViewAutoresizingFlexibleBottomMargin | 
         UIViewAutoresizingFlexibleTopMargin | 
         UIViewAutoresizingFlexibleHeight];
        
    }
    return self;
}

@end
