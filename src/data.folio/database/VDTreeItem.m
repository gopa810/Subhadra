//
//  VDTreeItem.m
//  VedabaseB
//
//  Created by Peter Kollath on 26/11/14.
//
//

#import "VDTreeItem.h"

@implementation VDTreeItem


-(id)init
{
    self = [super init];
    if (self)
    {
        self.children = [NSMutableArray new];
    }
    return self;
}


-(VDTreeItem *)addChild:(NSString *)t count:(NSString *)c
{
    VDTreeItem * vd = [VDTreeItem new];
    
    vd.title = t;
    vd.count = c;
    
    [self.children addObject:vd];
    
    return vd;
}

-(CGPoint)getEndpointWithFont:(NSDictionary *)fontAttr lastEndpoint:(CGRect *)currentRect
{
    CGPoint startPoint;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    CGFloat minY = 10000;
    CGPoint temp;

    CGSize size1 = [self.title sizeWithAttributes:fontAttr];
    CGSize size2 = [self.count sizeWithAttributes:fontAttr];
    
    if (self.children && self.children.count > 0)
    {
        for (VDTreeItem * t in self.children)
        {
            temp = [t getEndpointWithFont:fontAttr lastEndpoint:currentRect];
            maxX = MAX(maxX, temp.x);
            maxY = MAX(maxY, temp.y);
            minY = MIN(minY, temp.y);
        }
        startPoint = CGPointMake(maxX + 20, (minY + maxY) / 2);
    }
    else
    {
        startPoint.x = 20;
        startPoint.y = currentRect->origin.y + currentRect->size.height + size1.height + 10;
    }

    self.startPoint = startPoint;
    

//    CGFloat halfSize = MAX(size1.height / 2, size2.height / 2);
    
    self.titlePos = CGPointMake(startPoint.x + 10, startPoint.y - size1.height - 2);
    self.countPos = CGPointMake(self.titlePos.x, self.titlePos.y + size1.height + 4);
    self.endPoint = CGPointMake(startPoint.x + MAX(size1.width, size2.width) + 20, startPoint.y);
    
    CGFloat rectTop = startPoint.y - size1.height - 4;
    self.itemRect = CGRectMake(startPoint.x, rectTop, self.endPoint.x - startPoint.x, self.countPos.y + size2.height + 4 - rectTop);
    
    currentRect->size.width = MAX(currentRect->size.width, self.endPoint.x);
    currentRect->size.height = MAX(currentRect->size.height, self.endPoint.y + 2*size2.height);
    

    return self.endPoint;
}

-(void)draw:(CGContextRef)context styles:(NSDictionary *)styles
{

    CGFloat minY = 10000;
    CGFloat maxY = 0;
    if (self.children && self.children.count > 0)
    {
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 2);

        for (VDTreeItem * t in self.children)
        {
            [t draw:context styles:styles];
            CGContextMoveToPoint(context, t.endPoint.x, t.endPoint.y);
            CGContextAddLineToPoint(context, self.startPoint.x - 10, t.endPoint.y);
            CGContextStrokePath(context);
            
            maxY = MAX(maxY, t.endPoint.y);
            minY = MIN(minY, t.endPoint.y);
        }
        CGContextMoveToPoint(context, self.startPoint.x - 10, minY);
        CGContextAddLineToPoint(context, self.startPoint.x - 10, maxY);
        CGContextStrokePath(context);
        CGContextMoveToPoint(context, self.startPoint.x - 10, self.startPoint.y);
        CGContextAddLineToPoint(context, self.startPoint.x, self.startPoint.y);
        CGContextStrokePath(context);
    }

    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.itemRect cornerRadius:5];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    [self.title drawAtPoint:self.titlePos withAttributes:[styles valueForKey:@"title"]];
    [self.count drawAtPoint:self.countPos withAttributes:[styles valueForKey:@"count"]];
}


@end
