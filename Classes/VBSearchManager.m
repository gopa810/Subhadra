//
//  VBSearchManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 15/09/14.
//
//

#import "VBSearchManager.h"
#import "VBPhraseHighlighting.h"
#import "VBFolio.h"
#import "VBSearchResultsCollection.h"
#import "VBUserQuery.h"
#import "VBFolioQuery.h"
#import "VBFindRangeArray.h"
#import "VBUnicodeWordMatcher.h"
#import "VBUnicodeToAsciiConverter.h"
#import "FlatParagraph.h"
#import "FolioTextRecord.h"
#import "FDRecordPart.h"
#import "FDTextHighlighter.h"
#import "FDPartBase.h"

@implementation VBSearchResultItem

-(id)init
{
    self = [super init];
    if (self)
    {
        self.type = 0;
        self.plainText = nil;
        self.recordId = 0;
        self.rawRecord = nil;
    }
    return self;
}

@end

@implementation VBSearchManager


-(id)init
{
    self = [super init];
    if (self) {
        self.queries = [[NSMutableArray alloc] init];
        self.results = [[NSMutableArray alloc] init];
        self.phrases = [[VBHighlightedPhraseSet alloc] init];
    }
    return self;
}

-(void)clear
{
    self.queries = [[NSMutableArray alloc] init];
    self.results = [[NSMutableArray alloc] init];
    self.phrases = [[VBHighlightedPhraseSet alloc] init];
}


-(void)performSearch:(VBUserQuery *)query selectedContent:(NSString *)selText currentRecord:(int)currentRecordId
{
    self.lastQuery = query;
    int minRecord = 1;
    int maxRecord = INT_MAX;

    // looking for current scope
    // in the database
    // query.scope has values: 0 - whole DB, 1 - current book, 2 - current text
    // database has values: 0 - unspecified, 1 - text, 2 - book
    //
    if (query.userScope == 1)
    {
        VBFolioContentItem * fci = [self.folio findContentRangeForRecordId:currentRecordId nodeType:2];
        if (fci != nil)
        {
            minRecord = fci.recordId;
            maxRecord = fci.nextSibling;
        }
    }
    else if (query.userScope == 2)
    {
        VBFolioContentItem * fci = [self.folio findContentRangeForRecordId:currentRecordId nodeType:1];
        if (fci != nil) {
            minRecord = fci.recordId;
            maxRecord = fci.nextSibling;
        } else {
            fci = [self.folio findContentRangeForRecordId:currentRecordId nodeType:2];
            if (fci != nil) {
                minRecord = fci.recordId;
                maxRecord = fci.nextSibling;
            }
        }
    }
    
    NSString * queryText = [query realQuery];
    int bufferSize = 1000;
    NSMutableArray * buffer = [[NSMutableArray alloc] initWithCapacity:bufferSize];
    //VBSearchResultsCollection * currentList = nil;
    //NSMutableArray * currList = nil;
    VBFolioQuery * folioQuery = [[VBFolioQuery alloc] initWithStorage:self.folio.firstStorage];
    //BOOL canAdd = NO;
    NSArray * arr = [folioQuery sourceToArray:[query realQuery]];
    VBSearchTreeContext * ctx = [[VBSearchTreeContext alloc] init];
    ctx.quotes = self.phrases;
    ctx.wordsDomain = @"";
    ctx.exactWords = YES;
    VBFolioQueryOperator * fop = nil;
    int itemIndex = 1;

    [self.results removeAllObjects];
    
    if (queryText == nil || arr.count == 0)
    {
        return;
    }
    
    if (selText != nil)
    {
        VBSearchResultItem * si = [VBSearchResultItem new];
        si.type = SEARCHRESULTITEMTYPE_PLAINTEXT;
        si.plainText = selText;
        [buffer addObject:si];
    }
    
    @try {
        fop = [folioQuery convertArrayToTree:arr context:ctx];
        [fop validate];
        [self.queries addObject:fop];

        if (buffer.count >= bufferSize)
        {
            [self.results addObjectsFromArray:buffer];
            [buffer removeAllObjects];
        }
        
        while([fop endOfStream] == NO)
        {
//            canAdd = YES;
            uint32_t currRecX = [fop currentRecord];
//            if (useSel) {
//                canAdd = [self.folio.firstStorage.content isRecordSelected:currRecX];
//            }

            if (currRecX >= minRecord && currRecX < maxRecord) {
                
                VBSearchResultItem * si = [VBSearchResultItem new];
                si.type = SEARCHRESULTITEMTYPE_RECORDHEADER;
                si.plainText = [NSString stringWithFormat:@"%d", itemIndex];
                si.recordId = currRecX;
                si.visited = NO;
                [buffer addObject:si];
                
                si = [VBSearchResultItem new];
                si.type = SEARCHRESULTITEMTYPE_RECORDPART;
                si.recordId = currRecX;
                si.visited = NO;
                [buffer addObject:si];
                itemIndex++;
            }
            
            [fop gotoNextRecord];
        }
    }
    @catch (NSExpression * expr) {
    }
    
    [self.results addObjectsFromArray:buffer];
}

-(void)releaseAllRaws
{
    self.results = [NSMutableArray new];
}


-(FDRecordBase *)getRawRecord:(unsigned int)recid
{
    int pageNum = recid / SEARCH_RESULTS_RAWS_SIZE;
    int startIndex = pageNum * SEARCH_RESULTS_RAWS_SIZE;
    int maxRec = (int)[self maximumRecord];
    
    if (recid <= maxRec) {

        VBSearchResultItem * sa = [self.results objectAtIndex:recid];
        if (sa.rawRecord == nil)
        {
            //
            // loads all raw records for given "page" of records
            //
            for (int i = startIndex; i < startIndex + SEARCH_RESULTS_RAWS_SIZE && i <= maxRec; i++)
            {
                VBSearchResultItem * si = [self.results objectAtIndex:i];
                if (si.rawRecord == nil)
                {
                    if (si.type == SEARCHRESULTITEMTYPE_PLAINTEXT)
                    {
                        FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:self.folio.firstStorage];
                        FolioTextRecord * textRec = [[FolioTextRecord alloc] init];
                        
                        textRec.recordId = 0;
                        textRec.plainText = si.plainText;
                        si.rawRecord = [fp convertToRaw:textRec];
                    }
                    else if (si.type == SEARCHRESULTITEMTYPE_RECORDHEADER)
                    {
                        FDRecordBase * recRaw = [self makeRawSearchHeader:si.recordId];
                        // adding header
                        recRaw.recordMark = si.plainText;
                        recRaw.recordMarkColor = nil;
                        recRaw.recordId = i;
                        recRaw.linkedRecordId = si.recordId;
                        si.rawRecord = recRaw;
                    }
                    else if (si.type == SEARCHRESULTITEMTYPE_RECORDPART)
                    {
                        FDRecordBase * recRaw = [self makeRawSearchRecord:si.recordId];
                        recRaw.recordId = i;
                        recRaw.linkedRecordId = si.recordId;
                        si.rawRecord = recRaw;
                    }
                }
            }
        }
        
        return sa.rawRecord;
    }
    
    return nil;
}

-(int)setRecordVisited:(int)recId
{
    int maxRec = (int)[self maximumRecord];
    
    if (recId <= maxRec) {
        VBSearchResultItem * sa = [self.results objectAtIndex:recId];
        while (recId > 0 && (sa.rawRecord == nil || sa.rawRecord.recordMark == nil))
        {
            recId --;
            sa = [self.results objectAtIndex:recId];
        }
        if (sa.rawRecord != nil && sa.rawRecord.recordMark != nil)
        {
            sa.rawRecord.recordMarkColor = [UIColor blueColor];
        }
        sa.visited = YES;
    }
    
    return recId;
}

-(NSRange)findRangeOfMatchForWord:(NSString *)word inText:(NSString *)text fromIndex:(int)stIdx
{
    //return [text rangeOfString:word options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:rangeScope];
    if ([word length] == 0)
        return NSMakeRange(NSNotFound, 0);
    
    unichar A;
    
    VBUnicodeWordMatcher * matcher = [[VBUnicodeWordMatcher alloc] init];
    
    matcher.word = [word lowercaseString];
    int i;
    BOOL lastWasNumber = NO;
    for (i = stIdx; i < [text length]; i++)
    {
        A = [VBUnicodeToAsciiConverter unicodeToAscii:[text characterAtIndex:i]];
        if (A == '.' && !lastWasNumber)
            A = ' ';
        if ([matcher sendChar:A atIndex:i])
        {
            NSRange range = NSMakeRange(matcher.startFindRange, matcher.lastFindIndex - matcher.startFindRange);
            //[matcher release];
            return range;
        }
        lastWasNumber = (isdigit(A) ? YES : NO);
    }
    if ([matcher sendChar:32 atIndex:i])
    {
        NSRange range = NSMakeRange(matcher.startFindRange, matcher.lastFindIndex - matcher.startFindRange);
        //[matcher release];
        return range;
    }
    
    //[matcher release];
    return NSMakeRange(NSNotFound, 0);
}

-(FDRecordBase *)makeRawSearchHeader:(int)recId
{
	NSString * path = [self.folio findDocumentPath:recId];
	if (path == nil)
		return nil;
	
    NSMutableString * strPage = [[NSMutableString alloc] init];
	
    [strPage appendFormat:@"<PT:12pt><RL:Link,%d><FC:0,80,0><BD+>%@<BD><FC></RL>", recId, path];
    
    FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:self.folio.firstStorage];
    FolioTextRecord * textRec = [[FolioTextRecord alloc] init];
    
    textRec.recordId = 0;
    textRec.plainText = strPage;
    //NSLog(@"=== %d == SearchConvert ==: %@", textRec.recordId, textRec.plainText);
    FDRecordBase * recordBase = [fp convertToRaw:textRec];
    
    return recordBase;
}

/*
 *  create record base object for context info for searched words
 */

-(FDRecordBase *)makeRawSearchRecord:(int)recId
{
	NSString * text = [FlatFileUtils removeTags:[self.folio plainText:recId]];
	if (text == nil)
        return nil;
	
    NSMutableString * strPage = [[NSMutableString alloc] init];
	
    [strPage appendFormat:@"<PT:10pt><AP:12pt><IN:LF:22pt>"];
    [strPage appendString:text];
	
    FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:self.folio.firstStorage];
    FolioTextRecord * textRec = [[FolioTextRecord alloc] init];
    
    textRec.recordId = 0;
    textRec.plainText = strPage;

    FDRecordBase * recordBase = [fp convertToRaw:textRec];

    FDTextHighlighter * th = [[FDTextHighlighter alloc] initWithPhraseSet:self.phrases];
    
    for (FDRecordPart * part in recordBase.parts)
    {
        [part evaluateHighlighting:th];
        part.evaluateHighlightedWords = NO;
    }

    [recordBase selectPartsAroundHighlighting];
    
    [recordBase shrinkSelectedParts];
    
    return recordBase;
}

-(void)alignSubstringRangeToWords:(NSRange *)range forText:(NSString *)str
{
    NSInteger start = range->location;
    NSInteger end = range->location + range->length;
    
    for (NSInteger i = start; i >= 0; i--)
    {
        unichar uc = [str characterAtIndex:i];
        if (uc == ' ')
        {
            start = i;
            break;
        }
        if (uc == '.')
        {
            start = i + 1;
            break;
        }
    }

    for(NSInteger j = end; j < [str length]; j++)
    {
        unichar uc = [str characterAtIndex:j];
        if (uc == ' ' || uc == '.' || uc == ',')
        {
            end = j;
            break;
        }
    }
    
    range->location = start;
    range->length = end - start;
}


-(int)getRecordCount
{
	return (int)self.results.count;
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    return nil;
}

-(NSString *)getRecordPath:(int)record
{
    return [self.folio.firstStorage getRecordPath:record];
}

-(id)findObject:(NSString *)strName
{
    return [self.folio.firstStorage findObject:strName];
}

-(BOOL)recordHasNote:(int)recid
{
    return NO;
}

-(BOOL)recordHasBookmark:(int)recid
{
    return NO;
}

-(int)bookmarksCount
{
    return 0;
}

-(BOOL)canHaveBookmarks
{
    return NO;
}

-(BOOL)canHaveNotes
{
    return NO;
}

-(NSInteger)minimumRecord
{
    return 0;
}

-(NSInteger)maximumRecord
{
    return (NSInteger)self.results.count - 1;
}

+(NSString *)scopeText:(int)scopeIndex
{
    switch(scopeIndex)
    {
        case 1:
            return @"Current Book";
        case 2:
            return @"Current Article";
        default:
            return @"Whole Database";
    }
}

@end
