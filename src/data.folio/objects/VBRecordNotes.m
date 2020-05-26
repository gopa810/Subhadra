//
//  VBRecordNotes.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "VBRecordNotes.h"
#import "VBHighlighterAnchor.h"

@implementation VBRecordNotes

@synthesize noteText;


-(id)init
{
    self = [super init];
    if (self)
    {
        self.p_highs = [[NSMutableArray alloc] init];
        self.noteParentID = -1;
        self.parentId = -1;
    }
    return self;
}

- (void)cleanDuplicates
{
    // cleaning array
    NSInteger idx = 0;
    int prevId = 0;
    while(idx < self.p_highs.count)
    {
        VBHighlighterAnchor * A = [self.p_highs objectAtIndex:idx];
        if (prevId == A.highlighterId)
        {
            [self.p_highs removeObjectAtIndex:idx];
        }
        else
        {
            prevId = A.highlighterId;
            idx++;
        }
    }
}

-(void)setHighlighter:(int)highlighterId fromChar:(int)start endChar:(int)stop
{
    int lastId = 0;
    BOOL bStartInserted = NO;
    BOOL bEndInserted = NO;
    
    if (start >= stop)
        return;
    
    NSInteger trackIndex = 0;
    
    while (trackIndex < self.p_highs.count)
    {
        VBHighlighterAnchor * A = [self.p_highs objectAtIndex:trackIndex];
        if (!bStartInserted)
        {
            if (A.startChar == start)
            {
                A.highlighterId = highlighterId;
                bStartInserted = YES;
            }
            else if (A.startChar > start)
            {
                VBHighlighterAnchor * nanch = [[VBHighlighterAnchor alloc] init];
                nanch.startChar = start;
                nanch.highlighterId = highlighterId;
                [self.p_highs insertObject:nanch atIndex:trackIndex];
                bStartInserted = YES;
            }
            else
            {
                lastId = A.highlighterId;
            }
        }
        else if (!bEndInserted)
        {
            if (A.startChar == stop)
            {
            }
            else if (A.startChar > stop)
            {
                VBHighlighterAnchor * nanch = [[VBHighlighterAnchor alloc] init];
                nanch.startChar = stop;
                nanch.highlighterId = lastId;
                [self.p_highs insertObject:nanch atIndex:trackIndex];
                bEndInserted = YES;
            }
            else
            {
                lastId = A.highlighterId;
                A.highlighterId = highlighterId;
            }
        }
        
        trackIndex++;
    }

    if (!bStartInserted)
    {
        VBHighlighterAnchor * nanch = [[VBHighlighterAnchor alloc] init];
        nanch.startChar = start;
        nanch.highlighterId = highlighterId;
        [self.p_highs addObject:nanch];
    }
    
    if (!bEndInserted)
    {
        VBHighlighterAnchor * nanch = [[VBHighlighterAnchor alloc] init];
        nanch.startChar = stop;
        nanch.highlighterId = lastId;
        [self.p_highs addObject:nanch];
    }
    
    // removes all highlighters in row with the same highlighterId
    [self cleanDuplicates];

    // logging
    [self logDumpAnchors];
    
}

-(void)logDumpAnchors
{
    // logging
    for(VBHighlighterAnchor * anch in self.p_highs)
    {
        NSLog(@"ANCHOR AT %d ->(%d)", anch.startChar, anch.highlighterId);
    }
    NSLog(@"--------------");
}

-(void)refreshHighlightedTextWithString:(NSString *)str
{
    int startIndex = -1;
    int endIndex = -1;
    NSMutableString * strTemp = [[NSMutableString alloc] init];
    for(int i = 0; i < self.p_highs.count; i++)
    {
        VBHighlighterAnchor * anch = [self.p_highs objectAtIndex:i];
        if (anch.highlighterId > 0 && startIndex < 0)
            startIndex = anch.startChar;
        if (anch.highlighterId == 0 && startIndex >= 0)
            endIndex = anch.startChar;
        if (str.length > 0 && startIndex >= 0 && endIndex >= 0)
        {
            if (startIndex >= str.length)
            {
                startIndex = (int)str.length - 1;
            }
            if (endIndex >= str.length)
            {
                endIndex = (int)str.length - 1;
            }
            @try {
                if ([strTemp length] > 0)
                {
                    [strTemp appendString:@" / "];
                }
                [strTemp appendString:[str substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)]];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
            startIndex = -1;
            endIndex = -1;
        }
    }
    self.highlightedText = strTemp;
    //[strTemp release];
}


-(NSArray *)anchors
{
    return self.p_highs;
}

-(uint32_t)recordId
{
    return self.p_recId;
}

-(void)setRecordId:(uint32_t)recordId
{
    self.p_recId = recordId;
}

-(int)anchorsCount
{
    return (int)[self.p_highs count];
}

-(VBHighlighterAnchor *)anchorAtIndex:(int)index
{
    if (index < (int)[self.p_highs count])
    {
        return [self.p_highs objectAtIndex:index];
    }
    return nil;
}

-(void)removeAllAnchors
{
    [self.p_highs removeAllObjects];
    [self setHighlightedText:@""];
}


-(BOOL)hasText
{
    return (self.noteText != nil && self.noteText.length > 0);
}

-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * __autoreleasing dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:self.recordPath forKey:@"recordPath"];
    [dict setValue:self.highlightedText forKey:@"highlightedText"];
    [dict setValue:self.noteText forKey:@"noteText"];
    [dict setValue:self.createDate forKey:@"createDate"];
    [dict setValue:self.modifyDate forKey:@"modifyDate"];
    [dict setValue:[NSNumber numberWithInt:self.recordId] forKey:@"recordId"];
    [dict setValue:[NSNumber numberWithInteger:self.ID] forKey:@"id"];
    [dict setValue:[NSNumber numberWithInteger:self.parentId] forKey:@"parentid"];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [dict setValue:array forKey:@"anchors"];
    //[array release];
    for (VBHighlighterAnchor * anch in self.anchors)
    {
        [array addObject:[anch dictionaryObject]];
    }
    
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    self.recordPath = [obj valueForKey:@"recordPath"];
    self.highlightedText = [obj valueForKey:@"highlightedText"];
    self.noteText = [obj valueForKey:@"noteText"];
    self.createDate = [obj valueForKey:@"createDate"];
    self.modifyDate = [obj valueForKey:@"modifyDate"];
    self.recordId = [[obj valueForKey:@"recordId"] intValue];
    
    NSArray * array = [obj valueForKey:@"anchors"];
    [self.p_highs removeAllObjects];
    for (NSDictionary * dict in array)
    {
        VBHighlighterAnchor * anch = [[VBHighlighterAnchor alloc] init];
        [anch setDictionaryObject:dict];
        [self.p_highs addObject:anch];
        //[anch release];
    }
    
    NSNumber * n;
    
    n = [obj valueForKey:@"id"];
    if (n) self.ID = n.integerValue;
    else self.ID = -1;
    
    n = [obj valueForKey:@"parentid"];
    if (n) self.parentId = n.integerValue;
    else self.parentId = -1;
}

@end
