//
//  VBEditMenu.m
//  VedabaseB
//
//  Created by Peter Kollath on 19/01/15.
//
//

#import "VBEditMenu.h"
#import "VBMainServant.h"


VBEditMenu * globalEditMenuView;

@implementation VBEditMenuItem


@end

@implementation VBEditMenu

+(void)initialize
{
    globalEditMenuView = nil;
}

+(void)hide
{
    if (globalEditMenuView)
    {
        [globalEditMenuView removeFromSuperview];
        [globalEditMenuView setHidden:YES];
        globalEditMenuView = nil;
    }
}

-(void)showForRect:(CGRect)hotRect
{
    [VBEditMenu hide];
    
    CGFloat dim = [UIFont systemFontSize];
    if (self.font == nil)
    {
        self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }

    CGFloat yCurr = 0;
    CGFloat xMax = 0;
    self.drawItems = [NSMutableArray new];
    for (UIMenuItem * mi in self.menuItems) {
        
        SEL action = mi.action;
        NSString * title = mi.title;

        CGSize sizeText = [title sizeWithAttributes:@{NSFontAttributeName: self.font}];
        CGSize areaSize = CGSizeMake(sizeText.width + dim*2, sizeText.height + dim*2);
        
        VBEditMenuItem * emi = [VBEditMenuItem new];
        
        emi.area = CGRectMake(0, yCurr, areaSize.width, areaSize.height);
        emi.textOrigin = CGPointMake(dim, dim);
        emi.text = title;
        emi.target = self.actionTarget;
        emi.selector = action;
        
        yCurr += 1 + areaSize.height;
        if (areaSize.width > xMax)
            xMax = areaSize.width;
        
        [self.drawItems addObject:emi];
    }
    
    for (VBEditMenuItem * emi in self.drawItems)
    {
        emi.area = CGRectMake(emi.area.origin.x, emi.area.origin.y, xMax, emi.area.size.height);
    }

    CGPoint origRef;
    self.dim = dim;
    CGFloat yStart = 20;
    if (hotRect.origin.x + hotRect.size.width + xMax < self.frame.size.width)
    {
        self.anchorPoint = CGPointMake(hotRect.origin.x + hotRect.size.width, hotRect.origin.y + hotRect.size.height / 2);
        yStart = MAX(self.anchorPoint.y - yCurr/2, yStart);
        yStart = MIN(self.frame.size.height - yCurr, yStart);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, MAX(self.anchorPoint.y, yStart + self.dim));
        origRef = CGPointMake(self.anchorPoint.x + self.dim, yStart);
        self.atLeft = YES;
    }
    else
    {
        CGFloat p = MAX(xMax + self.dim, hotRect.origin.x);
        self.anchorPoint = CGPointMake(p, hotRect.origin.y + hotRect.size.height / 2);
        yStart = MAX(self.anchorPoint.y - yCurr/2, yStart);
        yStart = MIN(self.frame.size.height - yCurr, yStart);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, MAX(self.anchorPoint.y, yStart + self.dim));
        origRef = CGPointMake(self.anchorPoint.x - self.dim - xMax, yStart);
        self.atLeft = NO;
    }
    
    for (VBEditMenuItem * emi in self.drawItems) {
        emi.area = CGRectOffset(emi.area, origRef.x, origRef.y);
    }
    
    
    VBMainServant * s = [VBMainServant instance];
    self.backgroundColor = [UIColor clearColor];
    
    [s.window addSubview:self];
    
    globalEditMenuView = self;
}


-(void)drawRect:(CGRect)rect
{
    CGContextRef cg = UIGraphicsGetCurrentContext();

    self.menuRect = CGRectMake(10, 10, 40, 40);
    CGContextSetFillColorWithColor(cg, [UIColor blackColor].CGColor);

    CGContextMoveToPoint(cg, self.anchorPoint.x, self.anchorPoint.y);
    if (self.atLeft)
    {
        CGContextAddLineToPoint(cg, self.anchorPoint.x + self.dim, self.anchorPoint.y - self.dim);
        CGContextAddLineToPoint(cg, self.anchorPoint.x + self.dim, self.anchorPoint.y + self.dim);
        CGContextAddLineToPoint(cg, self.anchorPoint.x, self.anchorPoint.y);
        CGContextFillPath(cg);
    }
    else
    {
        CGContextAddLineToPoint(cg, self.anchorPoint.x - self.dim, self.anchorPoint.y - self.dim);
        CGContextAddLineToPoint(cg, self.anchorPoint.x - self.dim, self.anchorPoint.y + self.dim);
        CGContextAddLineToPoint(cg, self.anchorPoint.x, self.anchorPoint.y);
        CGContextFillPath(cg);
    }

    for (VBEditMenuItem * emi in self.drawItems) {
        if (emi.selected)
        {
            CGContextSetFillColorWithColor(cg, [UIColor blueColor].CGColor);
            CGContextFillRect(cg, emi.area);
        }
        else
        {
            CGContextSetFillColorWithColor(cg, [UIColor blackColor].CGColor);
            CGContextFillRect(cg, emi.area);
        }
    }

    NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    for (VBEditMenuItem * emi in self.drawItems)
    {
        [emi.text drawAtPoint:CGPointMake(emi.area.origin.x + emi.textOrigin.x, emi.area.origin.y + emi.textOrigin.y)
               withAttributes:attr];
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL b = [self checkItem:point];
    
    if (b == NO)
    {
        [self removeFromSuperview];
        [self setHidden:YES];
        globalEditMenuView = nil;
    }
    else
    {
        [self setNeedsDisplay];
    }
    
    return b;
}

-(void)clearSelection
{
    for (VBEditMenuItem * emi in self.drawItems) {
        emi.selected = NO;
    }
}

-(BOOL)checkItem:(CGPoint)point
{
    BOOL b = NO;
    
    for (VBEditMenuItem * emi in self.drawItems) {
        if (CGRectContainsPoint(emi.area, point))
        {
            emi.selected = YES;
            b = YES;
            break;
        }
    }

    return b;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    [self clearSelection];
    [self checkItem:pt];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    BOOL b = [self checkItem:pt];
    if (b)
    {
        for (VBEditMenuItem * emi in self.drawItems) {
            if (emi.selected)
            {
                if ([emi.target respondsToSelector:emi.selector])
                {
                    [emi.target performSelector:emi.selector withObject:nil afterDelay:0.1];
                }
            }
        }
    }
    
    [super touchesEnded:touches withEvent:event];
    [VBEditMenu hide];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [VBEditMenu hide];
}


@end
