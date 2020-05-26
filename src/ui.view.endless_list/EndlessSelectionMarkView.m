//
//  EndlessSelectionMarkView.m
//  VedabaseB
//
//  Created by Peter Kollath on 18/01/15.
//
//

#import "EndlessSelectionMarkView.h"

@implementation EndlessSelectionMarkView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.reverseImage = NO;
        self.hotSpotOffset = CGSizeMake(0,0);
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    if (self.reverseImage)
    {
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextTranslateCTM(ctx, 0, -rect.size.height);
    }
    
    CGContextDrawImage(ctx, rect, self.image.CGImage);
    CGContextRestoreGState(ctx);    
}

-(CGPoint)hotSpotLocation
{
    return CGPointMake(self.frame.origin.x + self.hotSpotOffset.width, self.frame.origin.y + self.hotSpotOffset.height);
}

-(void)setHotSpotLocation:(CGPoint)pt
{
    self.frame = CGRectMake(pt.x - self.hotSpotOffset.width, pt.y - self.hotSpotOffset.height, self.frame.size.width, self.frame.size.height);
}

-(void)setOrigin:(CGPoint)pt
{
    self.frame = CGRectMake(pt.x, pt.y, self.frame.size.width, self.frame.size.height);
}

-(void)setHandleLocation:(CGPoint)pt
{
    self.frame = CGRectMake(pt.x - self.handlePoint.x, pt.y - self.handlePoint.y, self.frame.size.width, self.frame.size.height);
}


@end
