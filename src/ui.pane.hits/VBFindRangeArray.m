//
//  VBFindRangeArray.m
//  VedabaseA
//
//  Created by Peter Kollath on 1/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBFindRangeArray.h"


@implementation VBFindRangeArray

-(id)init
{
	if ((self = [super init]) != nil)
	{
		array = [[NSMutableArray alloc] init];
	}
	
	return self;
}


-(VBFindRange *)findRange:(int)rangeLocation length:(int)rangeLength
{
	for(VBFindRange * item in array)
	{
		if ([item intersectsWithRange:rangeLocation length:rangeLength])
			return item;
	}
	return nil;
}

-(void)addRange:(int)rangeLocation length:(int)rangeLength effective:(NSRange)eRange
{
	VBFindRange * item = [VBFindRange findRange];
	item.location = rangeLocation;
	item.length = rangeLength;
	[item addEffectiveRange:eRange];
	[array addObject:item];
}

-(void)insertRange:(int)rangeLocation length:(int)rangeLength effective:(NSRange)eRange
{
	VBFindRange * item = [self findRange:rangeLocation length:rangeLength];
	if (item == nil)
	{
		[self addRange:rangeLocation length:rangeLength effective:eRange];
	}
	else {
		[item mergeRange:rangeLocation length:rangeLength];
		[item addEffectiveRange:eRange];
	}
}

-(NSInteger)count
{
	return [array count];
}

-(NSRange)rangeAtIndex:(int)i
{
	return [(VBFindRange *)[array objectAtIndex:i] range];
}

-(void)sortArray
{
	NSMutableArray * temp = [[NSMutableArray alloc] initWithCapacity:[array count]];
	[temp addObjectsFromArray:array];
	[array removeAllObjects];
	BOOL inserted = NO;
	
	for(int b = 0; b < [temp count]; b++)
	{
		VBFindRange * item = (VBFindRange *)[temp objectAtIndex:b];
		inserted = NO;
		for(int a = 0; a < [array count]; a++)
		{
			VBFindRange * itemex = (VBFindRange *)[array objectAtIndex:a];
			if (itemex.location > item.location)
			{
				[array insertObject:item atIndex:a];
				inserted = YES;
				break;
			}
		}
		if (inserted == NO)
		{
			[array addObject:item];
		}
	}
	//[temp release];
}

-(NSString *)debugDescription
{
    NSMutableString * str = [[NSMutableString alloc] init];
    [str appendString:@"{\n"];
    for(int i = 0; i < [array count]; i++)
    {
        VBFindRange * fr = (VBFindRange *)[array objectAtIndex:i];
        [str appendFormat:@"  range [%ld,%ld]\n", (long)fr.location, (long)fr.length];
        for (int j = 0; j < [[fr subranges] count]; j++)
        {
            VBFindRange * sub = [[fr subranges] objectAtIndex:j];
            [str appendFormat:@"    subrange [%ld,%ld]\n", (long)sub.location, (long)sub.length];
        }
    }
    [str appendString:@"}\n"];
    
    return str;
}

-(void)applyRange:(int)nIndex fromText:(NSString *)src toFlatText:(NSMutableString *)dest
{	
	VBFindRange * fr = (VBFindRange *)[array objectAtIndex:nIndex];
	NSRange range = [fr range];
	
	if (range.location > 0)
		[dest appendFormat:@" .... "];

	NSInteger currPos = range.location;
	for(VBFindRange * a in [fr subranges])
	{
        @try {
            NSRange extractRange = NSMakeRange(currPos, a.location - currPos);
            if ([src length] < a.location)
            {
                NSLog(@"weird stuff");
            }
            NSString * subString = [src substringWithRange:extractRange];
            [dest appendString:subString];
            [dest appendFormat:@"%@", [src substringWithRange:[a range]]];
            currPos = a.location + a.length;
        }
        @catch (NSException *exception) {
            NSLog(@"source = %@", src);
        }
        @finally {
        }
	}
	if (currPos < (range.location + range.length))
	{
		NSInteger last = [src length];
		if (last > (range.location + range.length))
			last = range.location + range.length;
		//NSLog(@"src length = %d, last = %d", [src length], last);
		[dest appendFormat:@"%@", [src substringWithRange:NSMakeRange(currPos, (last - currPos))]];
	}
	
	if (range.location + range.length < [src length])
		[dest appendFormat:@".... "];
	
	
}

-(void)applyRange:(int)nIndex fromText:(NSString *)src toHtmlText:(NSMutableString *)dest
{
	VBFindRange * fr = (VBFindRange *)[array objectAtIndex:nIndex];
	NSRange range = [fr range];
	
	if (range.location > 0)
		[dest appendFormat:@" &nbsp; ...."];
    
	NSInteger currPos = range.location;
	for(VBFindRange * a in [fr subranges])
	{
        @try {
            NSRange extractRange = NSMakeRange(currPos, a.location - currPos);
            if ([src length] < a.location)
            {
                NSLog(@"weird stuff");
            }
            NSString * subString = [src substringWithRange:extractRange];
            [dest appendString:subString];
            [dest appendFormat:@"<span class=\"FoundText\">%@</span>", [src substringWithRange:[a range]]];
            currPos = a.location + a.length;
        }
        @catch (NSException *exception) {
            NSLog(@"source = %@", src);
        }
        @finally {
        }
	}
	if (currPos < (range.location + range.length))
	{
		NSInteger last = [src length];
		if (last > (range.location + range.length))
			last = range.location + range.length;
		//NSLog(@"src length = %d, last = %d", [src length], last);
		[dest appendFormat:@"%@", [src substringWithRange:NSMakeRange(currPos, (last - currPos))]];
	}
	
	if (range.location + range.length < [src length])
		[dest appendFormat:@".... &nbsp; "];
	
	
}

@end
