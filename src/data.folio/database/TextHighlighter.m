//
//  TextHighlighter.m
//  VedabaseA
//
//  Created by Gopal on 16.10.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextHighlighter.h"
#import "VBFolioStorage.h"
#import "VBTextParserMachine.h"
#import "VBHtmlElementsParserMachine.h"
#define kSearchMax 10

@implementation TextHighlighter

@synthesize arrWords;


-(id)initWithPhraseSet:(VBHighlightedPhraseSet *)phraseSet
{
	self = [super init];
	if (self)
	{
		self.arrWords = phraseSet;
	}
	
	return self;
}

//
// returns range within text with alignment for word endings
//

-(NSRange)fullStringRangeForText:(NSString *)text initialRange:(NSRange)fran
{
	int j0 = 0, jc = (int)fran.location;
	int k0 = 0, kc = (int)fran.location+(int)fran.length, ke = (int)[text length] - 1;
	unichar rc = 0;
	
	for(j0 = jc; j0 >= 0; j0--)
	{
		rc = [text characterAtIndex:j0];
		if (rc == ' ' || rc == '.' || rc == ',' || rc == ';'  || rc=='?' || rc== '-' || rc == 0x2013 || rc == 0x2014)
		{
			j0++;
			break;
		}
	}
	if (j0 < 0) j0++;
	
	for(k0 = kc; k0 <= ke; k0++)
	{
		rc = [text characterAtIndex:k0];
		if (rc == ' ' || rc == '.' || rc == ',' || rc == ';' || rc=='?' || rc == '-' || rc == 0x2013 || rc == 0x2014)
		{
			break;
		}
	}
	
	if (k0 > j0)
		return NSMakeRange(j0, k0-j0);
	return NSMakeRange(NSNotFound,0);
}

-(BOOL)comparePartialRange:(NSRange)rang1 withRange:(NSRange)rang2 options:(int)method
{
	switch (method) {
		case 1:
			if (rang1.location == rang2.location)
				return YES;
			return NO;
		case 2:
			if ((rang1.location + rang1.length) == (rang2.location + rang2.length))
				return YES;
			return NO;
		case 3:
			if ((rang1.location == rang2.location) && (rang1.length == rang2.length))
				return YES;
			return NO;
		default:
			break;
	}
	return YES;
}

//================================================
// return NO - if end of text was reached and no more words are available
// return YES - if outWord contains valid word
// text - input - text for search of words
// pPos - input/output - position for start of searching
// outWord - output - foudn word
// outRange - output - original range of word within text

-(NSInteger)findNextPlainWord:(NSString *)text position:(NSInteger *)pPos buffer:(NSMutableString *)outWord range:(NSRange *)pOutRange
{
	NSInteger pos = *pPos;
	unichar rc = 0;
	BOOL finished = NO;
	
	NSInteger event = 0;

	if ([text length] <= *pPos)
		return NO;
	
	VBTextParserMachine * pm = [[VBTextParserMachine alloc] init];
	[pm reset];
	NSInteger startIndex = pos;

	while((finished == NO) && (pos <= [text length]))
	{
		if (pos == [text length])
		{
            [pm setCharacter:32];
			break;
		}
		else 
		{
			rc = [text characterAtIndex:pos];
			event = [pm setCharacter:rc];
		}

		if (event == kStateEventWordBegin || event == kStateEventNumberBegin)
		{
			startIndex = pos;
		}
		if (event == kStateEventWordEnd || event == kStateEventNumberEnd)
		{
			finished = YES;
		}
		pos++;
	}
	
	[outWord setString:[pm stringValue]];
	*pOutRange = NSMakeRange(startIndex, pos - startIndex);
	*pPos = pos;
	//[pm release];
	
	return YES;
}

//================================================
// return NO - if end of text was reached and no more words are available
// return YES - if outWord contains valid word
// text - input - text for search of words
// pPos - input/output - position for start of searching
// outWord - output - foudn word
// outRange - output - original range of word within text

-(NSInteger)findNextHtmlWord:(const char  *)text length:(NSInteger)maxLen position:(NSInteger *)pPos buffer:(NSMutableString *)outWord range:(NSRange *)pOutRange
{
	NSInteger pos = *pPos;
	//unichar rc = 0;
	BOOL finished = NO;
	NSInteger lastCharStart = 0;
	
	NSInteger event = 0;
	
	if (maxLen <= *pPos)
		return NO;
	
	VBTextParserMachine * pm = [[VBTextParserMachine alloc] init];
	VBHtmlElementsParserMachine * hm = [[VBHtmlElementsParserMachine alloc] init];
	[pm reset];
	NSInteger startIndex = pos;
	
	while((finished == NO) && (pos <= maxLen))
	{
		event = 0;
		if (pos == maxLen)
		{
			[pm setCharacter:32];
			break;
		}
		else 
		{
			[hm setChar: text[pos]];
			if (hm.charStart)
				lastCharStart = pos;
			if (hm.tagNameAvailable == YES)
			{
				if ([[hm stringValue] isEqual:@"p"])
				{
					[arrWords OnNewParagraphTag];
				}
			}
			else if (hm.charAvailable == YES)
			{
				event = [pm setCharacter:[hm unicodeCharacter]];
			}
		}
		
		if (event == kStateEventWordBegin || event == kStateEventNumberBegin)
		{
			startIndex = lastCharStart;
		}
		if (event == kStateEventWordEnd || event == kStateEventNumberEnd)
		{
			finished = YES;
		}
		//NSLog(@"char %c, pos %d, event %d, charAvailable %d", text[pos], pos, event, hm.charAvailable);
		pos++;
	}
	
	[outWord setString:[pm stringValue]];
	*pOutRange = NSMakeRange(startIndex, pos - startIndex);
	*pPos = pos;
	//[pm release];
	//[hm release];
	
	return YES;
}

-(void)findHighlightedWords:(NSMutableArray *)ranges inPlainText:(NSString *)text
 {
	 NSInteger startPos = 0;
	 NSMutableString * word = [[NSMutableString alloc] init];
	 NSRange wordRange;
	 
	 while([self findNextPlainWord:text position:&startPos buffer:word range:&wordRange])
	 {
		if ([arrWords testWord:word withRange:wordRange])
		{
			[ranges addObjectsFromArray:[arrWords highlightedRanges]];
			[arrWords clearHighlightedRanges];
		}
	 }
	 
	 //[word release];
 }


-(void)findHighlightedWords:(NSMutableArray *)ranges inHtmlData:(NSData *)textData
{
	NSInteger startPos = 0;
	NSMutableString * word = [[NSMutableString alloc] init];
	NSRange wordRange;
	const char * text = [textData bytes];
	NSInteger maxLen = [textData length];
	while([self findNextHtmlWord:text length:maxLen position:&startPos buffer:word range:&wordRange])
	{
		if ([arrWords testWord:word withRange:wordRange])
		{
			[ranges addObjectsFromArray:[arrWords highlightedRanges]];
			[arrWords clearHighlightedRanges];
		}
	}
	
	[self sortFindArray:ranges];
	
	//[word release];
}


+(NSString *)htmlTextToPlainText:(NSString *)htmlText
{
	NSMutableString * str = [[NSMutableString alloc] init];
	VBHtmlElementsParserMachine * hpm = [[VBHtmlElementsParserMachine alloc] init];
	unichar rc = 0;
	int status = 0;
	int i = 0;
	int m = (int)[htmlText length];
	for(; i < m; i++)
	{
		rc = [htmlText characterAtIndex:i];
		[hpm setChar:rc];
		if (hpm.tagStart == YES)
		{
			status = 1;
		}
		else if (hpm.tagEnd == YES)
		{
			status = 0;
		}
		else if (status == 0)
		{
			[str appendFormat:@"%C", rc];
		}
	}
	
    //[hpm release];
	return str;
}

+(NSString *)htmlTextToAsciiHtmlText:(NSString *)htmlText
{
	NSMutableString * str = [[NSMutableString alloc] init];
	
	unichar rc = 0;
	int i = 0;
	int m = (int)[htmlText length];
	for(; i < m; i++)
	{
		rc = [htmlText characterAtIndex:i];
		if (rc > 127)
		{
			[str appendFormat:@"&#%d;", rc];
		}
		else
		{
			[str appendFormat:@"%c", rc];
		}
	}
	
	return str;
}

+(NSString *)htmlTextToOEMHtmlText:(NSString *)origHtmlText
{
	NSData * oemedData = [origHtmlText dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString * oemedText = [[NSString alloc] initWithData:oemedData encoding:NSASCIIStringEncoding];
	//[oemedText autorelease];
	return oemedText;
}

#pragma mark ========= load modified html file with selected words ===============


-(NSData *)highlightSearchWords:(NSData *)srcFile
{
	if ([arrWords count] == 0)
		return srcFile;
	int rdMax = (int)[srcFile length];
	const char * rdChars = [srcFile bytes]; 
	NSMutableData * target = nil;
	const char * pHighlightBefore = "<span class=\'FolioFoundText\'>"; 
	const char * pHighlightAfter = "</span>";
	NSMutableArray * ranges = [[NSMutableArray alloc] init];

	//NSMutableString * strTemp = [[NSMutableString alloc] initWithCapacity:128];
	
	[self findHighlightedWords:ranges inHtmlData:srcFile];

    for(VBFindRangeAd * range in ranges)
    {
        NSLog(@"Range: %ld,%ld", (long)range.location, (long)range.length);
    }
	target = [[NSMutableData alloc] initWithCapacity:(32 + rdMax+[ranges count]*(strlen(pHighlightAfter) + strlen(pHighlightBefore)))];
	[target setLength:0];
	
	NSInteger prevPos = 0;
	for(int i = 0; i < [ranges count]; i++)
	{
		VBFindRangeAd * rng = [ranges objectAtIndex:i];
		[target appendBytes:(rdChars + prevPos) length:(rng.location - prevPos)];
		[target appendBytes:pHighlightBefore length:strlen(pHighlightBefore)];
		[target appendBytes:(rdChars + rng.location) length:(rng.length)];
		[target appendBytes:pHighlightAfter length:strlen(pHighlightAfter)];
		prevPos = rng.location + rng.length;
	}
	[target appendBytes:(rdChars + prevPos) length:(rdMax - prevPos)];
	
	//[strTemp release];
	
	//[ranges release];
	return target;
}

-(void)clearHighlightWords
{
	[arrWords removeAllObjects];
}

-(void)sortFindArray:(NSMutableArray *)farr
{
	NSMutableArray * temp = [[NSMutableArray alloc] initWithCapacity:[farr count]];
	[temp addObjectsFromArray:farr];
	[farr removeAllObjects];
	BOOL inserted = NO;
	
	for(int b = 0; b < [temp count]; b++)
	{
		VBFindRangeAd * item = (VBFindRangeAd *)[temp objectAtIndex:b];
		inserted = NO;
		for(int a = 0; a < [farr count]; a++)
		{
			VBFindRangeAd * itemex = (VBFindRangeAd *)[farr objectAtIndex:a];
			if (itemex.location == item.location)
            {
                inserted = YES;
                break;
            }
            else if (itemex.location > item.location)
			{
				[farr insertObject:item atIndex:a];
				inserted = YES;
				break;
			}
		}
		if (inserted == NO)
		{
			[farr addObject:item];
		}
	}
	//[temp release];
}

@end
