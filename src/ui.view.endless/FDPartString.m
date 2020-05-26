//
//  FDPartString.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDPartString.h"


@implementation FDPartString



-(id)init
{
	self = [super init];
	if (self) {
		self.backgroundColor = 0;
	}
	return self;
}

-(float)getWidth
{
	if (self.format && self.text)
	{
		CGSize size = [self.text sizeWithAttributes:self.format];
        return size.height;
	}
	return [super getWidth];
}

-(float)getHeight
{
	if (self.format && self.text) {
		CGSize size = [self.text sizeWithAttributes:self.format];
        return size.height;
	}
	return [super getHeight];
}

-(NSString *)description
{
	return self.text;
}

-(void)applyFont
{
    if (self.typeface)
    {
        [self.format setObject:[self.typeface getUIFont] forKey:NSFontAttributeName];
    }
}

-(int)length
{
    return (int)[self.text length];
}

@end
