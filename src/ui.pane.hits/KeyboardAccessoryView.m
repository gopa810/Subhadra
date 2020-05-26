//
//  KeyboardAccessoryView.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/22/13.
//
//

#import "KeyboardAccessoryView.h"

@implementation KeyboardAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
