//
//  FDPartSpace.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDPartSpace.h"


@implementation FDPartSpace


-(id)init
{
	self = [super init];
	if (self) {
		self.breakLine = NO;
		self.tab = NO;
		self.backgroundColor = 0;
	}
	return self;
}

-(float)getWidth
{
	if (self.desiredWidth > 0)
		return self.desiredWidth;
	if (self.format)
	{
        [self getBaseWidth];
	}
	return [super getWidth];
}

-(float)getBaseWidth
{
    CGSize size = [@" " sizeWithAttributes:self.format];
    return size.width;
}

-(float)getHeight
{
	if (self.format) {
		CGSize size = [@" " sizeWithAttributes:self.format];
        return size.height;
	}
	return [super getHeight];
}

-(NSString *)description
{
	return @" ";
}

-(void)applyFont
{
    if (self.typeface)
    {
        [self.format setObject:[self.typeface getUIFont] forKey:NSFontAttributeName];
    }
}

@end
