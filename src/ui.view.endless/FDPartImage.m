//
//  FDPartImage.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDPartImage.h"

@implementation FDPartImage

-(id)init
{
	self = [super init];
	if (self) {
		self.format = [[NSMutableDictionary alloc] init];
		self.desiredWidth = 16;
		self.desiredHeight = 16;
	}
	return self;
}

-(float)getWidth
{
	return self.desiredWidth;
}

-(float)getHeight
{
	return self.desiredHeight;
}

-(NSString *)description
{
	return @" ";
}


@end
