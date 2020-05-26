//
//  HeaderBar.m
//  VedabaseB
//
//  Created by Peter Kollath on 11/12/14.
//
//

#import "HeaderBar.h"

@implementation HeaderBar

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //NSLog(@"HeaderBar init");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self myInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self myInit];
    }
    return self;
}

-(void)myInit
{
    self.mainColor = [UIColor colorWithRed:150/255.0 green:110/255.0 blue:70/255.0 alpha:1.0];
    self.subColor = [UIColor colorWithRed:196/255.0 green:171/255.0 blue:141/255.0 alpha:1.0];
    self.sides = UIRectEdgeBottom;
    self.sideWidth = 8.0;
    self.mainBottomColor = nil;
}

-(void)drawRect:(CGRect)rect
{
    CGRect subArea = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGRect mainArea  = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    if ((self.sides & UIRectEdgeBottom) == UIRectEdgeBottom)
        mainArea.size.height -= self.sideWidth;
    if ((self.sides & UIRectEdgeRight) == UIRectEdgeRight)
        mainArea.size.width -= self.sideWidth;
    if ((self.sides & UIRectEdgeLeft) == UIRectEdgeLeft)
    {
        mainArea.size.width -= self.sideWidth;
        mainArea.origin.x += self.sideWidth;
    }
    if ((self.sides & UIRectEdgeTop) == UIRectEdgeTop)
    {
        mainArea.size.height -= self.sideWidth;
        mainArea.origin.y += self.sideWidth;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, self.subColor.CGColor);
    CGContextFillRect(ctx, subArea);

    if (self.mainBottomColor == nil) {
        CGContextSetFillColorWithColor(ctx, self.mainColor.CGColor);
        CGContextFillRect(ctx, mainArea);
    } else {
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat colors []  = {0.6, 0.45, 0.3, 1.0, 0.51, 0.36, 0.21, 1.0};
        [self.mainColor getRed:&colors[0] green:&colors[1] blue:&colors[2] alpha:&colors[3]];
        [self.mainBottomColor getRed:&colors[4] green:&colors[5] blue:&colors[6] alpha:&colors[7]];
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
        CGColorSpaceRelease(baseSpace);
        baseSpace = NULL;
        
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx, mainArea);
        CGContextClip(ctx);
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(mainArea), CGRectGetMinY(mainArea));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(mainArea), CGRectGetMaxY(mainArea));
        
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient);
        gradient = NULL;
    }
    
}

@end
