//
//  VBSearchTask.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBSearchTask.h"
#import "VBFolio.h"

@implementation VBSearchTask

@synthesize folio;
@synthesize search;

-(id)initWithFolio:(VBFolio *)infolio query:(NSString *)query
{
	if ((self = [super init]) != nil)
	{
		queryStarted = NO;
		self.folio = infolio;
		[self setQuery:query];
	}
	
	return self;
}


-(void)setQuery:(NSString *)str
{
	//int defaultOper = 0;
	NSString * str1 = str;
	NSString * str2 = str1;
	
	str2 = [str1 stringByReplacingOccurrencesOfString:@"\"" withString:@" \" "];
	str1 = str2;
	str2 = [str1 stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
	str1 = str2;
	str2 = [str1 stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
	str1 = str2;
	str2 = [str1 stringByReplacingOccurrencesOfString:@"|" withString:@" | "];
	str1 = str2;
	str2 = [str1 stringByReplacingOccurrencesOfString:@"&" withString:@" & "];
	str1 = str2;
	str2 = [str1 lowercaseString];
	
	NSArray * src = [str2 componentsSeparatedByString:@" "];
	NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:[src count]];
	//int actOper = defaultOper;
	
	for(NSString * str in src)
	{
		if ([str isEqual:@""] == NO)
		{
			[arr addObject:str];
		}		
	}

	VBSearchOperator * so = [[VBSearchOperator alloc] initWithArray:arr];
	self.search = so;
	[so log:0 operat:0];
	NSLog(@"---------------------");
	[so release];
	[arr release];
}

-(void)findMatches:(uint32_t *)pDocIDs desiredCount:(int)dc actualCount:(int *)pfoundCount
{
	if (queryStarted == NO)
	{
		[self.search startQuery:self.folio];
		queryStarted = YES;
	}
	
	uint32_t nid;
	
	int ac = 0;
	for (int i = 0; i < dc; i++) {
	
		nid = [self.search currentRecordID];
		if ([self.search alive])
		{
			//NSLog(@"Found %d. record id = %d", ac, nid);
			pDocIDs[ac] = nid;
			ac++;
			[self.search gotoNextRecord];
		}
		else {
			break;
		}

	}
	
	*pfoundCount = ac;
}

-(void)extractWords:(NSMutableArray *)array
{
	[self.search extractWords:array];
}


@end
