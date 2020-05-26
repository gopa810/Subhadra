//
//  VBHighlightedPhraseSet.m
//  VedabaseA2
//
//  Created by Peter Kollath on 8/13/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBPhraseHighlighting.h"

@implementation VBHighlightedPhraseSet
@synthesize items;

-(id)init
{
	self = [super init];
	
	if (self)
	{
		self.items = [[NSMutableArray alloc] init];
		self.highRanges = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)removeAllObjects
{
	[items removeAllObjects];
}

-(NSMutableArray *)itemsArray
{
	return items;
}

-(NSInteger)count
{
	return [items count];
}

-(void)addObject:(id)obj
{
	[items addObject:obj];
}


-(BOOL)testWord:(NSString *)str withRange:(NSRange)range
{
	BOOL addedItems = NO;
	for(VBHighlightedPhrase * phrase in items)
	{
		if ([phrase testWord:str withRange:range])
		{
			if ([phrase isLastWord])
			{
				NSInteger i;
				NSInteger length = [phrase count];
				for(i = 0; i < length; i++)
				{
					VBFindRangeAd * found = [phrase rangeAtIndex:i];
					VBFindRangeAd * newRange = [[VBFindRangeAd alloc] init];
					newRange.location = found.location;
					newRange.length = found.length;
					newRange.partial = found.partial;
					[self.highRanges addObject:newRange];
					//[newRange release];
					addedItems = YES;
				}
				[phrase reset];
			}
		}
	}
	return addedItems;
}

-(NSArray *)highlightedRanges
{
	return self.highRanges;
}

-(void)clearHighlightedRanges
{
	[self.highRanges removeAllObjects];
}

-(void)OnNewParagraphTag
{
	for(VBHighlightedPhrase * hp in items)
	{
		if ([hp resetParaFlag] == YES)
		{
			[hp reset];
		}
	}
}


@end


#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFindRangeAd

@synthesize location, length, predicate, partial;
@synthesize  word;
-(id)init
{
	if ((self = [super init]) != nil)
	{
		self.location = NSNotFound;
		self.length = 0;
		self.predicate = nil;
		self.partial = NO;
        self.word = nil;
	}
	return self;
}

-(id)initWithRange:(NSRange)range
{
	if ((self = [super init]) != nil)
	{
		self.location = range.location;
		self.length = range.length;
		self.predicate = nil;
		self.partial = NO;
        self.word = nil;
	}
	return self;
}

+(id)findRange
{
	return [[VBFindRangeAd alloc] init];
}

-(BOOL)intersectsWithRange:(int)rangeLocation length:(int)rangeLength
{
	if (rangeLocation >= (self.location + self.length))
		return NO;
	if (self.location >= (rangeLocation + rangeLength))
		return NO;
	return YES;
}

-(void)mergeRange:(int)rangeLocation length:(int)rangeLength
{
	int xmin, xmax;
	
	xmin = (self.location < rangeLocation) ? (int)self.location : rangeLocation;
	xmax = ((self.location + self.length) < (rangeLocation + rangeLength)) ? (rangeLocation + rangeLength) : (int)(self.location + self.length) ;
    
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



@end


#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBRecordRange



-(id)initWithStart:(uint32_t)theStart stop:(uint32_t)theEnd
{
    self = [super init];
    if (self)
    {
        _start = theStart;
        _end = theEnd;
    }
    return self;
}


-(BOOL)isMember:(uint32_t)rec
{
    return ((rec >= _start) && (rec < _end));
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<from %d to %d>", _start, _end];
}

@end



#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBHighlightedPhrase

@synthesize resetParaFlag;
@synthesize proximity;

-(id)init
{
	self = [super init];
	
	if (self != nil)
	{
		self.items = [[NSMutableArray alloc] init];
		currentItem = 0;
		currentProximity = 1;
		self.proximity = 1;
		self.resetParaFlag = YES;
	}
	
	return self;
}

-(void)addWord:(NSString *)str
{
	VBFindRangeAd * vb = [[VBFindRangeAd alloc] init];
	vb.predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@", [[str stringByReplacingOccurrencesOfString:@"%" withString:@"*"] stringByReplacingOccurrencesOfString:@"_" withString:@"?"]];
    vb.word = str;
	[_items addObject:vb];
	//[vb release];
}

-(NSArray *)ranges
{
    return self.items;
}

// returns:
// 0 - not match
-(BOOL)testWord:(NSString *)str withRange:(NSRange)range
{
	if (currentItem >= [self.items count])
		currentItem = 0;
	if (currentItem >= [self.items count])
		return 0;
	
	VBFindRangeAd * pvb = [self.items objectAtIndex:currentItem];
	// test current word
	BOOL result = [[pvb predicate] evaluateWithObject:str];
	currentProximity--;
	if (result)
	{
		pvb.location = range.location;
		pvb.length = range.length;
		currentItem++;
		currentProximity = proximity;
	}
	// test preceeding word
	else if (currentItem > 0)
	{
		pvb = [_items objectAtIndex:(currentItem - 1)];
		result = [[pvb predicate] evaluateWithObject:str];
		if (result)
		{
			pvb.location = range.location;
			pvb.length = range.length;
			currentProximity = proximity;
		}
	}
    
	if (currentProximity <= 0)
	{
		currentItem = 0;
	}
	return result;
}

-(BOOL)isLastWord
{
	return (currentItem == [_items count] && [_items count] > 0);
}

-(void)reset
{
	currentItem = 0;
}

-(NSInteger)count
{
	return [_items count];
}

-(VBFindRangeAd *)rangeAtIndex:(NSInteger)pos
{
	return [_items objectAtIndex:pos];
}

@end


