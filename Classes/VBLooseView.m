//
//  VBLooseView.m
//  VedabaseB
//
//  Created by Peter Kollath on 26/01/15.
//
//

#import "VBLooseView.h"

@implementation VBLooseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
//    if (CGRectContainsPoint(self.frame, point))
    {
        [self.delegate looseViewClicked:self];
    }
    return NO;
}

@end
