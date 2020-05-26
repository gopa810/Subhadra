//
//  FDTextHighlighter.m
//  VedabaseB
//
//  Created by Peter Kollath on 18/09/14.
//
//

#import "FDTextHighlighter.h"
#import "VBHighlighterAnchor.h"
#import "FDPartBase.h"
#import "FDPartString.h"
#import "VBPhraseHighlighting.h"

NSCharacterSet * charSetEndings;

@implementation FDTextHighlightPhrase

+(void)initialize
{
    charSetEndings = [NSCharacterSet characterSetWithCharactersInString:@".;,-:)(][?!\"\'\u2013\u2014"];
}

-(id)init
{
    self = [super init];
    if (self) {
        self.words = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)testPart:(FDPartString *)ps
{
    if (self.currentIndex >= 0 && self.currentIndex < self.words.count)
    {
        NSString * str = ps.text;
        while (str.length > 0 && [charSetEndings characterIsMember:[str characterAtIndex:(str.length - 1)]])
        {
            str = [str substringToIndex:(str.length - 1)];
        }
        while(str.length > 0 && [charSetEndings characterIsMember:[str characterAtIndex:0]])
        {
            str = [str substringFromIndex:1];
        }
        
        FDTextHighlightWord * word = [self.words objectAtIndex:self.currentIndex];
        if ([word.predicate evaluateWithObject:str])
        {
            word.part = ps;
            self.currentIndex++;
            return YES;
        }
    }
    
    self.currentIndex = 0;
    return NO;
}

-(void)highlightParts
{
    for (FDTextHighlightWord * word in self.words)
    {
        word.part.highlighted = YES;
    }
}

-(BOOL)isCompleteMatch
{
    return (self.currentIndex >= self.words.count);
}

-(void)reset
{
    self.currentIndex = 0;
}

@end

@implementation FDTextHighlightWord


@end

@implementation FDTextHighlighter



-(id)initWithPhraseSet:(VBHighlightedPhraseSet *)phraseSet
{
	self = [super init];
	if (self)
	{
        self.phrases = [[NSMutableArray alloc] init];
        for (VBHighlightedPhrase * ph in phraseSet.items)
        {
            FDTextHighlightPhrase * phrase = [[FDTextHighlightPhrase alloc] init];
            for (VBFindRangeAd * fr in ph.items)
            {
                FDTextHighlightWord * word = [[FDTextHighlightWord alloc] init];
                word.predicate = fr.predicate;
                [phrase.words addObject:word];
            }
            
            [self.phrases addObject:phrase];
        }
	}
	
	return self;
}

-(void)reset
{
    for (VBHighlightedPhrase * ph in self.phrases)
    {
        [ph reset];
    }
}

@end
