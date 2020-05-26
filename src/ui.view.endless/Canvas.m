//
//  Canvas.m
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import "Canvas.h"

@implementation Canvas


-(id)init
{
    self = [super init];
    if (self) {
        self.context = UIGraphicsGetCurrentContext();
        self.startSelectionValid = NO;
        self.endSelectionValid = NO;
    }
    return self;
}

-(void)setStrokeColor:(UIColor *)color
{
    CGContextSetStrokeColorWithColor(self.context, color.CGColor);
}

-(void)setFillColor:(UIColor *)color
{
    CGContextSetFillColorWithColor(self.context, color.CGColor);
}

-(void)setFillColorRef:(CGColorRef)color
{
    CGContextSetFillColorWithColor(self.context, color);
}

-(void)setStrokeWidth:(float)width
{
    CGContextSetLineWidth(self.context, width);
}

-(void)lineFrom:(CGPoint)fp to:(CGPoint)tp
{
    CGContextMoveToPoint(self.context, fp.x, fp.y);
    CGContextAddLineToPoint(self.context, tp.x, tp.y);
    CGContextStrokePath(self.context);
}

-(void)moveToPoint:(CGPoint)point
{
    CGContextMoveToPoint(self.context, point.x, point.y);
}

-(void)lineTo:(CGPoint)point
{
    CGContextAddLineToPoint(self.context, point.x, point.y);
}

-(void)fillCircleWithRect:(CGRect)rect
{
    CGContextAddEllipseInRect(self.context, rect);
    CGContextFillPath(self.context);
}

-(void)strokeCircleWithRect:(CGRect)rect
{
    CGContextAddEllipseInRect(self.context, rect);
    CGContextStrokePath(self.context);
}

-(void)fillCircleWithCornersLeft:(float)xLeft top:(float)yTop right:(float)xRight bottom:(float)yBottom
{
    CGContextAddEllipseInRect(self.context, CGRectMake(xLeft, yTop, xRight-xLeft, yBottom-yTop));
    CGContextFillPath(self.context);
}

-(void)strokeCircleWithCornersLeft:(float)xLeft top:(float)yTop right:(float)xRight bottom:(float)yBottom
{
    CGContextAddEllipseInRect(self.context, CGRectMake(xLeft, yTop, xRight-xLeft, yBottom-yTop));
    CGContextStrokePath(self.context);
}

-(void)strokeRect:(CGRect)rect
{
    CGContextAddRect(self.context, rect);
    CGContextStrokePath(self.context);
}

-(void)fillRect:(CGRect)rect
{
    CGContextAddRect(self.context, rect);
    CGContextFillPath(self.context);
}

-(void)drawImage:(UIImage *)image rect:(CGRect)rect
{
    [image drawInRect:rect];
    //CGContextDrawImage(self.context, rect, image.CGImage);
}

-(void)drawSelectionStart
{
    if (self.startSelectionValid)
    {
        CGContextMoveToPoint(self.context, self.startSelectionPointA.x, self.startSelectionPointA.y);
        CGContextAddLineToPoint(self.context, self.startSelectionPointB.x, self.startSelectionPointB.y);
        CGContextAddEllipseInRect(self.context, self.startSelectionRect);
        CGContextStrokePath(self.context);
        
        [self fillCircleWithRect:self.startSelectionRect];
    }
}

-(void)drawSelectionEnd
{
    if (self.endSelectionValid)
    {
        CGContextMoveToPoint(self.context, self.endSelectionPointA.x, self.endSelectionPointA.y);
        CGContextAddLineToPoint(self.context, self.endSelectionPointB.x, self.endSelectionPointB.y);
        CGContextAddEllipseInRect(self.context, self.endSelectionRect);
        CGContextStrokePath(self.context);
        
        [self fillCircleWithRect:self.endSelectionRect];
    }
}

-(void)saveState
{
    CGContextSaveGState(self.context);
}

-(void)restoreState
{
    CGContextRestoreGState(self.context);
}

@end
