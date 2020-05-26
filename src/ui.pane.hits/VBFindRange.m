//
//  VBFindRange.m
//  VedabaseA
//
//  Created by Peter Kollath on 1/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBFindRange.h"


@implementation VBFindRange

@synthesize location, length;

-(id)init
{
	if ((self = [super init]) != nil)
	{
		self.location = NSNotFound;
		self.length = 0;
		subArr = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id)initWithRange:(NSRange)range
{
	if ((self = [super init]) != nil)
	{
		self.location = range.location;
		self.length = range.length;
	}
	return self;
}

+(id)findRange
{
	return [[VBFindRange alloc] init];
}

-(BOOL)intersectsWithRange:(NSInteger)rangeLocation length:(NSInteger)rangeLength
{
	if (rangeLocation >= (self.location + self.length))
		return NO;
	if (self.location >= (rangeLocation + rangeLength))
		return NO;
	return YES;
}

-(void)mergeRange:(NSInteger)rangeLocation length:(NSInteger)rangeLength
{
	NSInteger xmin, xmax;
	
	xmin = (self.location < rangeLocation) ? self.location : rangeLocation;
	xmax = ((self.location + self.length) < (rangeLocation + rangeLength)) ? (rangeLocation + rangeLength) : (self.location + self.length) ;

	self.location = xmin;
	self.length = xmax - xmin;
}

-(NSRange)range
{
	NSRange ran;
	if (location < 0)
	{
		length = location + length;
		location = 0;
	}
	ran.location = location;
	ran.length = length;
	
	return ran;
}

-(void)addEffectiveRange:(NSRange)eRange
{
	int i = 0;
	for (i = 0; i < [subArr count]; i++) 
    {
        VBFindRange * rn = (VBFindRange *)[subArr objectAtIndex:i];
        if ([rn intersectsWithRange:eRange.location length:eRange.length])
            return;
		if (rn.location > eRange.location)
		{
			VBFindRange * r = [VBFindRange findRange];
			r.location = eRange.location;
			r.length = eRange.length;
			[subArr insertObject:r atIndex:i];
			return;
		}
	}
	
	VBFindRange * r = [VBFindRange findRange];
	r.location = eRange.location;
	r.length = eRange.length;
	[subArr addObject:r];
}

-(NSArray *)subranges
{
	return subArr;
}


@end
