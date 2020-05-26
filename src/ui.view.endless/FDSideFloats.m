//
//  FDSideFloats.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDSideFloats.h"
#import "sides_const.h"

@implementation FDSideFloats

-(id)init
{
	self = [super init];
	if (self) {
		for(int i = 0; i < 7; i++)
		{
			items[i] = 0;
		}
	}
	return self;
}

float getValue(float array[], int idx1, int idx2, int idx3)
{
	if (array[idx1] != 0)
		return array[idx1];
	if (array[idx2] != 0)
		return array[idx2];
	return array[idx3];
}

-(float)getSideValue:(int)side
{
	switch(side) {
        case SIDE_LEFT:
            return getValue(items, SIDE_LEFT, SIDE_LEFTRIGHT, SIDE_ALL);
        case SIDE_RIGHT:
            return getValue(items, SIDE_RIGHT, SIDE_LEFTRIGHT, SIDE_ALL);
        case SIDE_TOP:
            return getValue(items, SIDE_TOP, SIDE_TOPBOTTOM, SIDE_ALL);
        case SIDE_BOTTOM:
            return getValue(items, SIDE_BOTTOM, SIDE_TOPBOTTOM, SIDE_ALL);
	}
	return 0;
}

-(void)setSide:(int)side value:(float)val
{
	items[side] = val;
}

-(void)copyFrom:(FDSideFloats *)obj {
    
	for(int i = 0; i < 7; i++) {
		self->items[i] = obj->items[i];
	}
}


@end
