//
//  ContentItemHorizontalLine.m
//  VedabaseB
//
//  Created by Peter Kollath on 21/07/16.
//
//

#import "CIHorizontalLine.h"
#import "Canvas.h"

@implementation CIHorizontalLine

-(id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    return self.paddingBottom + self.paddingTop + 1.5f;
}

-(int)determineLayout
{
    return DL_ALL_TEXT;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    Canvas * canvas = [Canvas new];
    
    [canvas setStrokeColor:[skinManager colorForName:@"darkTextColor"]];
    [canvas setStrokeWidth:1.5f];
    [canvas lineFrom:CGPointMake(self.paddingLeft, self.paddingTop)
                  to:CGPointMake(rect.origin.x + rect.size.width - self.paddingRight, self.paddingTop)];
    
}





@end
