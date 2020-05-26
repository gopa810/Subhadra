//
//  VBStylistArchive.m
//  Vedabase Styles Builder
//
//  Created by Peter Kollath on 12/2/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "VBStylistArchive.h"

@implementation VBStylistArchive


-(id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self loadData:data];
    }
    
    return self;
}


-(void)dealloc
{
    self.images = nil;
    self.texts = nil;
    //[super dealloc];
}

-(BOOL)loadData:(NSData *)data
{
    BOOL returnValue = NO;
    self.images = [NSDictionary dictionary];
    self.texts = [NSDictionary dictionary];
    NSKeyedUnarchiver * ku = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSString * contentString = [ku decodeObjectForKey:@"content"];
    if ([contentString compare:@"VedabaseLayout"] == NSOrderedSame) {
        self.images = [ku decodeObjectForKey:@"images"];
        self.texts = [ku decodeObjectForKey:@"texts"];
        self.colors = [ku decodeObjectForKey:@"colors"];
        self.styles = [ku decodeObjectForKey:@"styles"];
        //[ku release];
        //return YES;
        returnValue = YES;
    }
    
    ku = nil;
    //[ku release];
    return returnValue;
}

-(UIColor *)colorForName:(NSString *)strName
{
    UIColor * color = nil;
    
    NSString * str = [self.colors objectForKey:strName];
    
    if (color == nil && [str hasPrefix:@"#"])
    {
        str = [str substringFromIndex:1];
        if (str.length == 0)
            str = @"000000";
        NSInteger a = [str length];
        NSInteger b[3] = {0, 2, 1};
        unsigned int red;
        unsigned int green;
        unsigned int blue;
        NSString * comp[3];
        a = a + b[a % 3];
        NSString * s2 = [[str stringByAppendingString:@"000"] substringToIndex:a];
        a = a / 3;
        int len = (int)a;
        if (a > 2) len = 2;
        comp[0] = [s2 substringWithRange:NSMakeRange(0, len)];
        comp[1] = [s2 substringWithRange:NSMakeRange(a, len)];
        comp[2] = [s2 substringWithRange:NSMakeRange(a*2, len)];
        
        NSScanner * sc1 = [NSScanner scannerWithString:comp[0]];
        [sc1 scanHexInt:&red];
        
        sc1 = [NSScanner scannerWithString:comp[1]];
        [sc1 scanHexInt:&green];
        
        sc1 = [NSScanner scannerWithString:comp[2]];
        [sc1 scanHexInt:&blue];
        
        CGFloat fred = red / 255.0;
        CGFloat fgreen = green / 255.0;
        CGFloat fblue = blue / 255.0;
        CGFloat falpha = 1.0;
        color = [UIColor colorWithRed:fred
                                green:fgreen
                                 blue:fblue
                                alpha:falpha];
        
    }
    
    if (color == nil)
    {
        NSCharacterSet * cs = [NSCharacterSet characterSetWithCharactersInString:@",;."];
        NSArray * arr = [str componentsSeparatedByCharactersInSet:cs];
        if (arr.count >= 3)
        {
            CGFloat red = [(NSString *)arr[0] intValue] / 255.0;
            CGFloat green = [(NSString *)arr[1] intValue] / 255.0;
            CGFloat blue = [(NSString *)arr[2] intValue] / 255.0;
            CGFloat alpha = 1.0;
            if (arr.count == 4)
                alpha = [(NSString *)arr[3] intValue] / 255.0;
            color = [UIColor colorWithRed:red
                                    green:green
                                     blue:blue
                                    alpha:alpha];
        }
    }
    return color;
}

-(UIImage *)imageForName:(NSString *)name
{
    return [UIImage imageWithData:[self.images objectForKey:name]];
}

-(NSData *)imageDataForName:(NSString *)str
{
    return [self.images objectForKey:str];
}

-(NSData *)textForName:(NSString *)strName
{
    return [self.texts objectForKey:strName];
}


@end
