//
//  TGTouchArea.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/27/13.
//
//

#import "TGTouchArea.h"

@implementation TGTouchArea

-(id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundImageSize = CGSizeMake(0, 0);
        self.topColor = nil;
        self.bottomColor = nil;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTabButtonPressed:)]) {
        [self.delegate onTabButtonPressed:self];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTabButtonReleasedOut:)]) {
        [self.delegate onTabButtonReleasedOut:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTabButtonReleased:)]) {
        [self.delegate onTabButtonReleased:self];
    }
}

-(void)drawRect:(CGRect)rect
{
    if (self.topColor != nil && self.bottomColor != nil)
    {
    }
    
    if (self.backgroundImage)
    {
        if (self.backgroundImageSize.width < 1)
        {
            [self.backgroundImage drawInRect:rect];
        }
        else
        {
            CGRect rc = CGRectMake(rect.size.width / 2 - self.backgroundImageSize.width/2, rect.size.height / 2 - self.backgroundImageSize.height / 2,
                                   self.backgroundImageSize.width,
                                   self.backgroundImageSize.height);
            [self.backgroundImage drawInRect:rc];
        }
    }
}

@end
