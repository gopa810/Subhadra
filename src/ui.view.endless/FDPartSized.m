//
//  FDPartSized.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDPartSized.h"

@implementation FDPartSized


-(id)init
{
	self = [super init];
	if (self) {
		self.desiredWidth = 1;
		self.desiredHeight = 1;
		self.desiredTop = 1;
		self.desiredBottom = 1;
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



@end
