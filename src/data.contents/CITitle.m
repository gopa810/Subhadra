//
//  ContentItemTitle.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#import "CITitle.h"
#import "VBMainServant.h"

@implementation CITitle


-(id)init
{
    self = [super init];
    if (self)
    {
        self.textSizeIndex = 2;
        self.textAlign = 2;
    }
    
    return self;
}

#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    UIFont * font = [fontBook objectForKey:[NSString stringWithFormat:@"fontR%d", self.textSizeIndex]];
    UIColor * color = [VBMainServant colorForName:@"darkTextColor"];
    self.textFormat = [self createParaFormatingWithFont:font
                                                  align:self.textAlign color:color];

    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(width*2/3,MAXFLOAT)
                                          options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
    
    return rect.size.height + self.paddingBottom + self.paddingTop;
}

-(int)determineLayout
{
    return DL_ALL_TEXT;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    
    CGRect rectText = CGRectMake(rect.origin.x + self.paddingLeft,
                                 rect.origin.y + self.paddingTop,
                                 rect.size.width - self.paddingLeft - self.paddingRight,
                                 rect.size.height - self.paddingBottom - self.paddingTop);
    
    [self.text drawInRect:rectText withAttributes:self.textFormat];

    self.drawingLayout = 0;
}




@end
