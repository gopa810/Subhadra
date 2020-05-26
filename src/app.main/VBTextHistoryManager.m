//
//  VBTextHistoryManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 17/09/14.
//
//

#import "VBTextHistoryManager.h"

@implementation VBTextHistoryManager

-(id)init
{
    self = [super init];
    if (self) {
        self.textHistory = [[NSMutableArray alloc] init];
        self.offsetHistory = [[NSMutableArray alloc] init];
        self.textHistoryCurr = -1;
    }
    return self;
}

-(NSUInteger)historyGetPrev
{
	if ([self canGoBack])
	{
		self.textHistoryCurr--;
		return [(NSNumber *)[self.textHistory objectAtIndex:self.textHistoryCurr] unsignedIntValue];
	}
	
	return NSNotFound;
}

-(NSUInteger)historyGetNext
{
	if ([self canGoForward])
	{
		self.textHistoryCurr++;
		return [(NSNumber *)[self.textHistory objectAtIndex:self.textHistoryCurr] unsignedIntValue];
	}
	
	return NSNotFound;
}

-(float)historyGetCurrentOffset
{
    if (self.textHistoryCurr >= 0)
    {
        return [(NSNumber *)[self.textHistory objectAtIndex:self.textHistoryCurr] floatValue];
    }
    
    return 0.0f;
}

-(void)historyPushTop:(NSUInteger)recID offset:(float)textOffset
{
	while ([self canGoForward])
	{
		[self.textHistory removeObjectAtIndex:self.textHistoryCurr];
        [self.offsetHistory removeObjectAtIndex:self.textHistoryCurr];
	}
    
	[self.textHistory addObject:[NSNumber numberWithUnsignedInteger:recID]];
    [self.offsetHistory addObject:[NSNumber numberWithFloat:textOffset]];
	self.textHistoryCurr = [self.textHistory count] - 1;
}

-(void)historyChangeTop:(NSUInteger)recID offset:(float)textOffset
{
	while ([self canGoForward])
	{
		[self.textHistory removeObjectAtIndex:self.textHistoryCurr];
        [self.offsetHistory removeObjectAtIndex:self.textHistoryCurr];
	}
    
    if ([self.textHistory count] > 0)
    {
        [self.textHistory removeLastObject];
        [self.offsetHistory removeLastObject];
        [self.textHistory addObject:[NSNumber numberWithUnsignedInteger:recID]];
        [self.offsetHistory addObject:[NSNumber numberWithFloat:textOffset]];
        self.textHistoryCurr = [self.textHistory count] - 1;
    }
}


-(BOOL)canGoBack
{
	return (self.textHistoryCurr > 0);
}

-(BOOL)canGoForward
{
	return ((self.textHistoryCurr >= 0) && (self.textHistoryCurr < ([self.textHistory count] - 1)));
}

-(BOOL)isAtTopOfHistory
{
    return self.textHistoryCurr == [self.textHistory count];
}

-(void)saveCurrent:(int)currId new:(int)newRecordId offset:(float)textOffset
{
    if (currId != -1) {
        [self historyChangeTop:currId offset:textOffset];
    }
    
    [self historyPushTop:newRecordId offset:0];
}

@end
