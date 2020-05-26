//
//  ContentItemDummyText.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/2/13.
//
//

#import "CIText.h"

@implementation CIText


-(BOOL)hasExpandIcon
{
    return NO;
}

-(UIColor *)titleColor
{
    return [UIColor brownColor];
}


-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    //UIImage * greyLine = [skinManager imageForName:@"gray_line"];
    NSDictionary * attrs = [fontBook valueForKey:@"styleI"];
    CGRect checkMarkArea = CGRectMake(0, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
    checkMarkArea = CGRectInset(checkMarkArea, AREA_INSET, AREA_INSET);
    
    CGRect textArea = CGRectMake(CHECK_MARK_AREA_WIDTH, AREA_INSET, rect.size.width - CHECK_MARK_AREA_WIDTH, rect.size.height - AREA_INSET * 2);
    
    [self.name drawInRect:textArea withAttributes:attrs];
    self.drawingLayout = 0;
    //n[self drawGradientSeparator:greyLine inRect:rect];
}

@end
