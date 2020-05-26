//
//  FDPartBase.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDPartBase.h"
#import "FDSelection.h"

@implementation FDPartBase

-(id)init
{
	self = [super init];
	if (self) {
		_hidden= NO;
		_orderNo = 0;
		_selected = [FDSelection None];
	}
	return self;
}


-(float)getWidth
{
	return 0;
}

-(int)length
{
    return 1;
}

@end
