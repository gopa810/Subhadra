//
//  FDPaint.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDColor.h"
#import "FDTypeface.h"

NSMutableDictionary * g_colors;

@implementation FDColor

+(UIColor *)getColor:(int)parts
{
    if (parts == 0)
        return nil;
    NSString * key = [NSString stringWithFormat:@"%d", parts];
    UIColor * color = [g_colors objectForKey:key];
    if (color)
        return color;
    color = [[UIColor alloc] initWithRed:((parts & 0x00ff0000) >> 16) / 255.0f
                                   green:((parts & 0x0000ff00) >> 8) / 255.0f
                                    blue:((parts & 0x000000ff) / 255.0f)
                                   alpha:((parts & 0xff000000) >> 24) / 255.0f];
    [g_colors setObject:color forKey:key];
    return color;
}



+(void)initialize
{
    g_colors = [[NSMutableDictionary alloc] init];
}



@end
