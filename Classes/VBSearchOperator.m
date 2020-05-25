//
//  VBSearchOperator.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBSearchOperator.h"


@implementation VBSearchOperator

@synthesize pipes;
@synthesize proximity;
@synthesize oper;
@synthesize word;

-(id)init
{
	if ((self = [super init]) != nil)
	{
		pipes = [[NSMutableArray alloc] init];
		buffer = NULL;
	}
	
	return self;
}

-(id)initWithWord:(NSString *)inword
{
	if ([self init] != nil)
	{
		self.word = inword;
	}
	return self;
}

-(id)initWithArray:(NSArray *)array
{
	if ([self init] != nil)
	{
		[self loadArray:array];
	}
	
	return self;
}

-(id)initWithArray:(NSArray *)array type:(int)intype
{
	if ([self init] != nil)
	{
		[self loadArray:array];
		oper = intype;
	}
	
	return self;
}


-(void)loadArray:(NSArray *)array
{
	int i, j, c;
	NSRange rng;
	NSRange rng1;
	NSRange rng2;
	VBSearchOperator * sop = nil;
	c = [array count];
	i = [array indexOfObject:@"\""];
	if (i  != NSNotFound)
	{
		rng.location = i + 1;
		rng.length = [array count] - rng.location;
		j = [array indexOfObject:@"\"" inRange:rng];
		if (j != NSNotFound)
		{
			rng2.location = j+1;
			rng2.length = c - rng2.location;
			
			rng1.location = i+1;
			rng1.length = j - rng1.location;
			
			rng.location = 0;
			rng.length = i - rng.location;
			
			if (rng.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
			if (rng1.length > 0)
			{
				sop = [[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]];
				sop.oper = 2;
				[pipes addObject:sop];
				[sop release];
			}
			if (rng2.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng2]] autorelease]];
		}
		else 
		{
			rng1.location = i+1;
			rng1.length = c - rng1.location;
			
			rng.location = 0;
			rng.length = i - rng.location;
			
			if (rng.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
			if (rng1.length > 0)
			{
				sop = [[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]];
				sop.oper = 2;
				[pipes addObject:sop];
				[sop release];
			}
		}
		return;

	}
	
	i = [array indexOfObject:@"("];
	if (i != NSNotFound)
	{
		j = [self indexOfClosingBracket:array fromIndex:i];
		if (j != NSNotFound)
		{
			rng2.location = j+1;
			rng2.length = c - rng2.location;
			
			rng1.location = i+1;
			rng1.length = j - rng1.location;
			
			rng.location = 0;
			rng.length = i - rng.location;
			
			if (rng.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
			if (rng1.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
			if (rng2.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng2]] autorelease]];
		}
		else 
		{
			rng1.location = i+1;
			rng1.length = c - rng1.location;
			
			rng.location = 0;
			rng.length = i - rng.location;
			
			if (rng.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
			if (rng1.length > 0)
				[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
		}
		return;
	}
	
	i = [array indexOfObject:@"|"];
	if (i != NSNotFound)
	{
		rng1.location = i+1;
		rng1.length = c - rng1.location;
		
		rng.location = 0;
		rng.length = i - rng.location;
		
		if (rng.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
		if (rng1.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
		if ([pipes count] > 0)
			oper = 1;
		return;
	}
	i = [array indexOfObject:@"or"];
	if (i != NSNotFound)
	{
		rng1.location = i+1;
		rng1.length = c - rng1.location;
		
		rng.location = 0;
		rng.length = i - rng.location;
		
		if (rng.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
		if (rng1.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
		if ([pipes count] > 0)
			oper = 1;
		return;
	}
	i = [array indexOfObject:@"&"];
	if (i != NSNotFound)
	{
		rng1.location = i+1;
		rng1.length = c - rng1.location;
		
		rng.location = 0;
		rng.length = i - rng.location;
		
		if (rng.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
		if (rng1.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
		return;
	}
	i = [array indexOfObject:@"and"];
	if (i != NSNotFound)
	{
		rng1.location = i+1;
		rng1.length = c - rng1.location;
		
		rng.location = 0;
		rng.length = i - rng.location;
		
		if (rng.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng]] autorelease]];
		if (rng1.length > 0)
			[pipes addObject:[[[VBSearchOperator alloc] initWithArray:[array subarrayWithRange:rng1]] autorelease]];
		return;
	}
	if ([array count] == 1)
	{
		self.word = [array objectAtIndex:0];
		return;
	}
	for (i = 0; i < [array count]; i++) {
		[pipes addObject:[[[VBSearchOperator alloc] initWithWord:[array objectAtIndex:i]] autorelease]];
	}
}

-(int)indexOfClosingBracket:(NSArray *)array fromIndex:(int)idx
{
	int level = 0;
	for(int i = idx; i < [array count]; i++)
	{
		if ([[array objectAtIndex:i] isEqual:@"("])
		{
			level ++;
		}
		if ([[array objectAtIndex:i] isEqual:@")"])
		{
			level --;
			if (level == 0)
				return i;
		}
	}
	return NSNotFound;
}


-(void)log:(int)level operat:(int)op
{
	if ([pipes count] == 0)
		NSLog(@" %d : %@ : oper(%d)", level, self.word, op);
	else 
	{
		for(VBSearchOperator * so in pipes)
		{
			[so log:(level + 1) operat:oper];
		}
	}
}

-(BOOL)isPipe
{
	return [pipes count] == 0;
}

#define BUFFER_ITEMS 1024
#define ITEM_SIZE        6

-(uint32_t)currentRecordID
{
	if (endOfStream)
		return 0;
	if ([self isPipe])
	{
		return CFSwapInt32BigToHost(*(uint32_t *)(buffer + (currIndexInPage * ITEM_SIZE)));
	}
	else 
	{
		uint32_t val = [self synchronizedRecordID];
		if (endOfStream == YES)
			return 0;
		return val;
	}

}

-(uint16_t)currentProximity
{
	if (endOfStream)
		return 0;
	if ([self isPipe])
	{
		return CFSwapInt16BigToHost(*(uint16_t *)(buffer + (currIndexInPage * ITEM_SIZE) + 4));
	}
	else {
		return [self minProximitySubpipes];
	}

}

-(uint32_t)maxRecordFromSubpipes
{
	if ([self isPipe]) return 0;
	uint32_t currVal = 0;
	uint32_t maxVal = 0;
	
	for(VBSearchOperator * so in pipes)
	{
		if ([so alive])
		{
			currVal = [so currentRecordID];
			if (maxVal == 0 || currVal > maxVal)
				maxVal = currVal;
		}
		else {
			endOfStream = YES;
			return 0;
		}
		
	}
	
	return maxVal;
}

-(uint16_t)minProximitySubpipes
{
	if ([self isPipe])
		return [self currentProximity];
	else {
		uint16_t minVal = 0;
		uint16_t currVal = 0;
		for(VBSearchOperator * so in pipes)
		{
			currVal = [so minProximitySubpipes];
			if (minVal == 0 || currVal < minVal)
				minVal = currVal;
		}
		return minVal;
	}

}

// for AND return record id same for all pipes
// for OR returns najmensi record id from all pipes
// for PROX returns record id same for all pipes with proximity according array
-(uint32_t)synchronizedRecordID
{
	if ([self isPipe])
		return [self currentRecordID];
	
	uint32_t retval = 0;
	uint32_t maxVal = 0;
	uint32_t currVal = 0;
	BOOL again = YES;
	
	if (oper == 0)
	{
		// and operator
		// records must be same
		// proximity not important
		// all pipes must be alive
		
		// finds max  record id
		// or exits if one of the pipes is not alive
		maxVal = [self maxRecordFromSubpipes];
		if (endOfStream)
			return 0;

		// moves all pipes to value
		// which is common for all of pipes
		// this is AND functions - all records must be same
		while (again && (endOfStream == NO)) 
		{
			again = NO;
			for(VBSearchOperator * so in pipes)
			{
				currVal = [so moveToRecordID:maxVal];
				if ([so alive] == NO) {
					endOfStream = YES;
					return 0;
				}
				if (currVal > maxVal) {
					maxVal = currVal;
					again = YES;
					break;
				}
			}
		}
		
		retval = maxVal;
	}
	else if (oper == 1)
	{
		// or operator
		// if at least one pipe is alive
		// then this stream is alive
		uint32_t minVal = 0;
		uint32_t currVal = 0;
		
		// finds least record
		for(VBSearchOperator * so in pipes)
		{
			if ([so alive])
			{
				currVal = [so currentRecordID];
				if (minVal == 0 || currVal < minVal)
					minVal = currVal;
			}
		}
		retval = minVal;
	}
	else if (oper == 2)
	{
		// proximity search
		// records must be same
		// proximity must be in order with array elements
		//if one pipe is end
		// then whole stream is end
		// finds max  record id
		// or exits if one of the pipes is not alive
		maxVal = [self maxRecordFromSubpipes];
		if (endOfStream)
			return 0;
		
		int prevProx = 0;
		int prox = 0;
		// moves all pipes to value
		// which is common for all of pipes
		// this is AND functions - all records must be same
		while (again && (endOfStream == NO)) 
		{
			again = NO;
			for(VBSearchOperator * so in pipes)
			{
				currVal = [so moveToRecordID:maxVal];
				if ([so alive] == NO) {
					endOfStream = YES;
					return 0;
				}
				if (currVal > maxVal) {
					maxVal = currVal;
					again = YES;
					break;
				}
			}
			
			if (again == NO)
			{
				// first we have aligned by AND function
				// now we will check proximity matching
				for (VBSearchOperator * so in pipes) 
				{
					currVal = [so currentRecordID];
					prox = [so minProximitySubpipes];
					if (prevProx + 1 >= prox)
					{
						prevProx = prox;
					}
					else 
					{
						// tries to move in proximity
						// going to next record proximity or record id (not only record id)
						if ([so moveNext])
						{
							endOfStream = YES;
							return 0;
						}
						if (currVal != [so currentRecordID])
						{
							maxVal = currVal;
							again = YES;
							break;
						}
						
					}

				} // end FOR: proximity aligment
				  // if again == NO
				  // then we will finish with this record
				
			} // enf if - blcok for alignemnt of proximity values
		}
		
		retval = maxVal;
	}
	
	return retval;
}

-(BOOL)moveNext
{
	if ([self isPipe])
	{
		currIndexInPage++;
		if (currIndexInPage >= maxIndex - currPageIndexOffset)
		{
			endOfStream = YES;
			return YES;
		}
		if (currIndexInPage < BUFFER_ITEMS)
			return NO;
		currIndexInPage = 0;
		currPageIndexOffset += BUFFER_ITEMS;
		unsigned newOffset = (currPageIndexOffset*ITEM_SIZE);
		if (newOffset > scopeLength)
		{
			endOfStream = YES;
			return YES;
		}
		unsigned newSize = BUFFER_ITEMS * ITEM_SIZE;
		if (newSize > (scopeLength - newOffset))
			newSize = scopeLength - newOffset;
		NSLog(@"Before load references");
		[folio loadWordReferences:(scopeOffset + newOffset) size:newSize toBuffer:buffer];
		NSLog(@"After load references");
	}
	else 
	{
		uint32_t minVal = [self minProximitySubpipes];
		for(VBSearchOperator * so in pipes)
		{
			if ([so minProximitySubpipes] == minVal)
			{
				if ([so moveNext] == YES)
				{
					endOfStream = YES;
					return YES;
				}				
			}
		}
	}

	
	return endOfStream;
}

// return max record id from one of the pipes
// if that value is greater than recID on input
// then there is need to call this func again
-(uint32_t)moveToRecordID:(uint32_t)recID
{
	if ([self isPipe])
	{
		//BOOL b;
		//uint32_t ra;
		uint32_t rb = [self currentRecordID];
		
		while (endOfStream == NO && rb < recID) {
			endOfStream = [self moveNext];
			rb = [self currentRecordID];
		}
		
		return rb;
	}

	uint32_t retval = 0;
	uint32_t temp = 0;

	for(VBSearchOperator * so in pipes)
	{
		temp = [so moveToRecordID:recID];
		if ([so alive] == NO)
		{
			endOfStream = YES;
			return 0;
		}
		if (temp > retval)
			retval = temp;
	}
	
	return retval;
}


-(uint32_t)gotoNextRecord
{
	if ([self isPipe])
	{
		//BOOL b;
		uint32_t ra;
		uint32_t rb;
		
		ra = rb = [self currentRecordID];
		while (endOfStream == NO && rb == ra) {
			endOfStream = [self moveNext];
			rb = [self currentRecordID];
		}
		
		return rb;
	}
	
	uint32_t retval = 0;
	
	if (oper == 0)
	{
		// and operator
		// records must be same
		// proximity not important
		// all pipes must be alive
		VBSearchOperator * so = [pipes objectAtIndex:0];
		retval = [so gotoNextRecord];
	}
	else if (oper == 1)
	{
		// or operator
		// if at least one pipe is alive
		// then this stream is alive
		uint32_t minVal = 0;
		uint32_t currVal = 0;
		
		// finds least record
		for(VBSearchOperator * so in pipes)
		{
			if ([so alive])
			{
				currVal = [so currentRecordID];
				if (minVal == 0 || currVal < minVal)
					minVal = currVal;
			}
		}
		retval = minVal;
		for (VBSearchOperator * so in pipes) 
		{
			if ([so alive])
			{
				if ([so currentRecordID] == retval)
				{
					[so gotoNextRecord];
				}
			}
		}
	}
	else if (oper == 2)
	{
		// proximity search
		// records must be same
		// proximity must be in order with array elements
		//if one pipe is end
		// then whole stream is end
		VBSearchOperator * so = [pipes objectAtIndex:0];
		retval = [so gotoNextRecord];
	}
	
	return retval;
}

-(void)startQuery:(VBFolio *)inf
{
	if ([self isPipe])
	{
		folio = inf;
		NSManagedObject * obj = nil;//[folio findWordRef:self.word];
		if (obj != nil)
		{
			NSLog(@"WordRef %@ found", self.word);
			scopeOffset = [[obj valueForKey:@"fileOffset"] unsignedLongLongValue];
			scopeLength = [[obj valueForKey:@"fileLength"] unsignedIntValue];
			currPageIndexOffset = 0;
			currIndexInPage = 0;
			endOfStream = NO;
			maxIndex = scopeLength / ITEM_SIZE;
			buffer = (uint8_t *)malloc(BUFFER_ITEMS * ITEM_SIZE);
			unsigned toLoad = scopeLength;
			if (scopeLength > BUFFER_ITEMS * ITEM_SIZE)
				toLoad = BUFFER_ITEMS * ITEM_SIZE;
			[folio loadWordReferences:scopeOffset size:toLoad toBuffer:buffer];
			
			NSLog(@"Loaded %d bytes from %d items", toLoad, maxIndex);
		}
		else {
			endOfStream = YES;
		}

	}
	else 
	{
		for(VBSearchOperator * so in pipes)
		{
			[so startQuery:inf];
		}
	}
}

-(BOOL)alive
{
	return !endOfStream;
}

-(void)extractWords:(NSMutableArray *)array
{
	if ([self isPipe])
	{
		[array addObject:self.word];
	}
	else {
		for(VBSearchOperator * so in pipes)
		{
			[so extractWords:array];
		}
	}
}

-(void)dealloc
{
	[pipes release];
	[super dealloc];
}

@end
