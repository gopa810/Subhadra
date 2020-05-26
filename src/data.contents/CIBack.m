//
//  ContentItemReturnLabel.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#import "CIBack.h"

@implementation CIBack

-(NSString *)name
{
    return self.text;
}

#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    CGFloat wc = [self correctWidth:width forLayout:[self determineLayout]];
    return [self
            calculateHeightForText:[self name]
            font:[fontBook valueForKey:@"smaller"] width:wc];
}

-(int)determineLayout
{
    return DL_ALL_TEXT;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    if (self.drawingPartTouched == DP_TEXT)
    {
        UIImage * image = [skinManager imageForName:@"lite_papyrus"];
        [image drawInRect:rect];
    }
    
    CGSize sztext = [@"Back" sizeWithAttributes:[fontBook valueForKey:@"styleR"]];

    UIImage * backIcon = [skinManager imageForName:@"back_brown"];
    CGRect iconrect = CGRectMake(0, (rect.origin.x + rect.size.height/2 - 20), 30, 40);
    [backIcon drawInRect:iconrect];
    
//    CGRect rectText = CGRectMake(CHECK_MARK_AREA_WIDTH, AREA_INSET, rect.size.width - 2*CHECK_MARK_AREA_WIDTH, rect.size.height - AREA_INSET);
    
    [@"Back" drawAtPoint:CGPointMake(CHECK_MARK_AREA_WIDTH, (rect.origin.x + rect.size.height/2 - sztext.height/2)) withAttributes:[fontBook valueForKey:@"styleR"]];
    
    //[@"Back" drawInRect:rectText withAttributes:[fontBook valueForKey:@"styleR"]];
    self.drawingLayout = DL_ALL_TEXT;
}


@end
