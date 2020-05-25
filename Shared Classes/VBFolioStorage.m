//
//  VBFolioStorage.m
//  Builder_iPad
//
//  Created by Peter Kollath on 4/14/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "VBFolioStorage.h"
#import "VBFolioStorageObjects.h"
#import "VBRecordNotes.h"
#import "VBBookmark.h"
#import "VBFolioQuery.h"
#import "VBFolioQueryOperator.h"
#import "FDRecordBaseBulk.h"
#import "FlatParagraph.h"
#import "FolioTextRecord.h"
#import "FDTextFormat.h"
#import "FDRecordPart.h"
#import "FDParagraph.h"
#import "FDPartBase.h"
#import "FDPartString.h"
#import "FDParaFormat.h"
#import "VBSearchResultsCollection.h"

UInt8 g_storageIdCounter = 1;
NSMutableDictionary * g_stylesMap;
NSDictionary * g_alternateStylesMap;

@implementation VBFolioStorage

@synthesize content;
@synthesize inclusionPath;
@synthesize fileName;
@synthesize bookmarksChanged;


+(void)initialize
{
    g_alternateStylesMap = nil;
    g_stylesMap = nil;
}

+(void)setAlternateStylesMap:(NSDictionary *)dict
{
    g_alternateStylesMap = dict;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        statCounter = 0;
        textCountValid = NO;
        self.p_recordNotes = [[NSMutableArray alloc] init];
        self.p_bookmarks = [[NSMutableArray alloc] init];
        self.bookmarksChanged = NO;
        self.commands = [[NSMutableDictionary alloc] init];
        self.inclusionPath = [[NSMutableArray alloc] init];
        bulks = [[NSMutableArray alloc] initWithCapacity:20];
        bulkLock = [[NSLock alloc] init];
        pagesLock = [[NSLock alloc] init];
        pagesToLoad = [[NSMutableArray alloc] init];
        self.loadPageLock = [NSLock new];
    }
    return self;
}


-(NSString *)valueForProperty:(NSString *)propName
{
    SQLiteCommand * stat = [self commandForKey:@"get_property"];
    
    if (stat)
    {
        if ([stat execute] == SQLITE_ROW)
        {
            return [stat stringValue:0];
        }
    }
    
    return @"";
}


-(BOOL)stringContainsWildcards:(NSString *)word
{
    NSRange range;
    range = [word rangeOfString:@"%"];
    if (range.location == NSNotFound)
    {
        range = [word rangeOfString:@"?"];
    }
    
    return range.location != NSNotFound;
}


-(NSInteger)count
{
    NSLog(@"what the hell");
    return 0;
}


-(BOOL)record:(uint32_t)rec inRanges:(NSArray *)arr
{
    if (arr == nil)
        return YES;
    
    for (VBRecordRange * recItem in arr) 
    {
        if ([recItem isMember:rec])
            return YES;
    }
    
    return NO;
}

//
// queryText - input
// resultArray - output
//

-(NSInteger)searchFirstRecord:(NSString *)queryText 
{
    VBFolioQuery * folioQuery = [[VBFolioQuery alloc] initWithStorage:self];
    NSArray * arr = [folioQuery sourceToArray:queryText];
    NSInteger firstRecord = NSNotFound;

    VBSearchTreeContext * ctx = [[VBSearchTreeContext alloc] init];
    ctx.quotes = nil;
    ctx.wordsDomain = @"";
    ctx.exactWords = YES;
    
    VBFolioQueryOperator * fop = [folioQuery convertArrayToTree:arr context:ctx];
    [fop validate];
    
    //NSMutableString * str2 = [[[NSMutableString alloc] init] autorelease];
    //[fop printAtLevel:0 toString:str2];
    //NSLog(@"------QUERY----------\n%@\n---------------------", str2);

    if ([fop endOfStream] == NO)
    {
        firstRecord = [fop currentRecord];
    }
    
    return firstRecord;
}

-(NSInteger)searchFirstRecordLike:(NSString *)queryText
{
    VBFolioQuery * folioQuery = [[VBFolioQuery alloc] initWithStorage:self];
    NSArray * arr = [folioQuery sourceToArray:queryText];
    NSInteger firstRecord = NSNotFound;
    
    VBSearchTreeContext * ctx = [[VBSearchTreeContext alloc] init];
    ctx.quotes = nil;
    ctx.wordsDomain = @"";
    ctx.exactWords = NO;
    
    VBFolioQueryOperator * fop = [folioQuery convertArrayToTree:arr context:ctx];
    [fop validate];
    
    //NSMutableString * str2 = [[[NSMutableString alloc] init] autorelease];
    //[fop printAtLevel:0 toString:str2];
    //NSLog(@"------QUERY----------\n%@\n---------------------", str2);
    
    if ([fop endOfStream] == NO)
    {
        firstRecord = [fop currentRecord];
    }
    
    if (firstRecord == NSNotFound || firstRecord == 0)
    {
        NSRange rans = [queryText rangeOfString:@"'"];
        if (rans.location != NSNotFound)
        {
            NSLog(@"--- changed text: %@", [queryText stringByReplacingOccurrencesOfString:@"'" withString:@"\'"]);
        }
    }
    
    return firstRecord;
}




-(void)search:(NSString *)queryText 
  resultArray:(NSMutableArray *)results 
  quotesArray:(VBHighlightedPhraseSet *)quotes 
 ignoreSelection:(BOOL)ignoreSel
   queryArray:(NSMutableArray *)queries
{
    VBSearchResultsCollection * currentList = nil;
    //NSMutableArray * currList = nil;
    VBFolioQuery * folioQuery = [[VBFolioQuery alloc] initWithStorage:self];
    BOOL canAdd = NO;
    NSArray * arr = [folioQuery sourceToArray:queryText];
    VBSearchTreeContext * ctx = [[VBSearchTreeContext alloc] init];
    ctx.quotes = quotes;
    ctx.wordsDomain = @"";
    ctx.exactWords = YES;
    VBFolioQueryOperator * fop = nil;
    [results removeAllObjects];
    
    if (queryText == nil || arr.count == 0)
    {
        //[folioQuery release];
        return;
    }
    
    @try {
        fop = [folioQuery convertArrayToTree:arr context:ctx];
        [fop validate];
        [queries addObject:fop];
        
        VBSearchResultsCollection * lastList = ([results count] > 0) ? [results lastObject] : nil;
        currentList = lastList;
        
        while([fop endOfStream] == NO)
        {
            

            //if (currList != nil)
            {
                canAdd = YES;
                uint32_t currRecX = [fop currentRecord];
                if (!ignoreSel) {
                    canAdd = [content isRecordSelected:currRecX];
                }
                //NSInteger globalRecordId = currRecX;
                if (canAdd && currRecX != 0) {
                    if (currentList == nil || [currentList hasSpace] == NO)
                    {
                        currentList = [[VBSearchResultsCollection alloc] init];
                        [results addObject:currentList];
                    }
                    [currentList add:currRecX];
                }
            }

            [fop gotoNextRecord];
        }
    }
    @catch (NSExpression * expr) {
    }
  
}


-(NSInteger)halfStep:(NSInteger)a
{
    return (a < 2) ? 1 : (a / 2);
}

-(void)findRecordNoteIndexForRecord:(uint32_t)recId outNotes:(VBRecordNotes **)notes outIndex:(int *)index
{
    int prevPos = -1;
    int prevPrevPos = -2;
    int pos = 0;
    NSInteger max = [self.p_recordNotes count];
    NSInteger step = [self halfStep:[self.p_recordNotes count]];
    
    if (notes)
        *notes = nil;
    
    while(1)
    {
        if (pos < 0)
        {
            if (index) *index = 0;
            return;
        }
        if (pos >= max)
        {
            // this means we shoudl not insert, but add new item
            if (index) *index = -1;
            return;
        }
        if (pos == prevPrevPos)
        {
            if (index) *index = ((pos > prevPos) ? pos : prevPos);
            return;
        }
        VBRecordNotes * item = [self.p_recordNotes objectAtIndex:pos];
        if (item.recordId > recId)
        {
            prevPrevPos = prevPos;
            prevPos = pos;
            pos -= step;
            step = [self halfStep:step];
        }
        else if (item.recordId == recId)
        {
            if (notes) *notes = item;
            if (index) *index = pos;
            return;
        }
        else
        {
            prevPrevPos = prevPos;
            prevPos = pos;
            pos += step;
            step = [self halfStep:step];
        }
    }
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    VBRecordNotes * notes = nil;
    [self findRecordNoteIndexForRecord:recId outNotes:&notes outIndex:NULL];
    return notes;
}

-(VBRecordNotes *)createNoteForRecord:(uint32_t)recId
{
    VBRecordNotes * item;
    int newIndex;
    
    [self findRecordNoteIndexForRecord:recId outNotes:&item outIndex:&newIndex];
    if (!item)
    {
        item = [[VBRecordNotes alloc] init];
        item.recordId = recId;
        item.createDate = [NSDate date];
        item.modifyDate = [NSDate date];
        if (newIndex < 0)
        {
            [self.p_recordNotes addObject:item];
        }
        else
        {
            [self.p_recordNotes insertObject:item atIndex:newIndex];
        }
        //[item release];
    }

    return item;
}


-(VBRecordNotes *)setHighlighter:(int)highlighterId forRecord:(uint32_t)recId startChar:(int)startIndex endChar:(int)endIndex
{
    VBRecordNotes * item = [self createNoteForRecord:recId];
    if (item)
    {
        [item setHighlighter:highlighterId fromChar:startIndex endChar:endIndex];
        NSDictionary * flatText = [self readText:recId forKey:@"plain"];
        NSString * plainText = [FlatFileString removeTags:[flatText objectForKey:@"plain"]];
        [item refreshHighlightedTextWithString:plainText];
        return item;
    }
    return NULL;
}


-(BOOL)bookmarkExists:(NSString *)bkmkName
{
    for (VBBookmark * vbb in self.p_bookmarks)
    {
        if ([vbb.name isEqualToString:bkmkName])
            return YES;
    }
    return NO;
}

-(void)saveBookmark:(NSString *)bkmkName recordId:(uint32_t)recId
{
    VBBookmark * vbb = [[VBBookmark alloc] init];
    vbb.name = bkmkName;
    vbb.recordId = recId;
    vbb.createDate  = [NSDate date];
    self.bookmarksChanged = YES;
    [self.p_bookmarks addObject:vbb];
    //[vbb release];
}

-(NSArray *)bookmarks
{
    return self.p_bookmarks;
}

-(int)indexOfBookmarkName:(NSString *)name
{
    for (int j = 0; j < self.p_bookmarks.count; j++)
    {
        VBBookmark * vbb = [self.p_bookmarks objectAtIndex:j];
        if ([vbb.name isEqualToString:name])
            return j;
    }
    return -1;
}

-(void)removeBookmarkWithName:(NSString *)name
{
    int i = [self indexOfBookmarkName:name];
    if (i >= 0)
    {
        [self.p_bookmarks removeObjectAtIndex:i];
        self.bookmarksChanged = YES;
    }
    
}

-(VBBookmark *)bookmarkWithName:(NSString *)name
{
    int i = [self indexOfBookmarkName:name];
    if (i >= 0)
        return [self.p_bookmarks objectAtIndex:i];
    return nil;
}

-(NSArray *)notesList
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (VBRecordNotes * item in self.p_recordNotes)
    {
        if ([item.noteText length] > 0)
        {
            [array addObject:item];
        }
    }
    return array;
}

-(NSArray *)highlightersList
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (VBRecordNotes * item in self.p_recordNotes)
    {
        if ([item.anchors count] > 0 || item.highlightedText.length > 0)
        {
            [array addObject:item];
        }
    }
    return array;
}

-(void)removeNote:(VBRecordNotes *)note
{
    [self.p_recordNotes removeObjectIdenticalTo:note];
}


-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSMutableArray * array;
    
    [dict setValue:self.fileName forKey:@"fileName"];
    [dict setValue:[NSNumber numberWithInt:[[self valueForProperty:@"Version"] intValue]] forKey:@"fileVersion"];
    [dict setValue:[NSNumber numberWithInt:[[self valueForProperty:@"TBUILD"] intValue]] forKey:@"fileBuild"];
    
    array = [[NSMutableArray alloc] init];
    [dict setValue:array forKey:@"notes"];
    //[array release];
    for (VBRecordNotes * note in self.p_recordNotes)
    {
        [array addObject:[note dictionaryObject]];
    }
    
    array = [[NSMutableArray alloc] init];
    [dict setValue:array forKey:@"bookmarks"];
    //[array release];
    for (VBBookmark * bkmk in self.p_bookmarks)
    {
        [array addObject:[bkmk dictionaryObject]];
    }
    
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    NSArray * array;
    
    array = [obj valueForKey:@"notes"];
    [self.p_recordNotes removeAllObjects];
    for (NSDictionary * dict in array)
    {
        VBRecordNotes * note = [[VBRecordNotes alloc] init];
        [note setDictionaryObject:dict];
        [self.p_recordNotes addObject:note];
        //[note release];
    }
    
    array = [obj valueForKey:@"bookmarks"];
    [self.p_bookmarks removeAllObjects];
    for (NSDictionary * dict in array)
    {
        VBBookmark * bkmk = [[VBBookmark alloc] init];
        [bkmk setDictionaryObject:dict];
        [self.p_bookmarks addObject:bkmk];
        //[bkmk release];
    }
    
    //int version = [[obj valueForKey:@"fileVersion"] intValue];
    //int build = [[obj valueForKey:@"fileBuild"] intValue];
    
    
}

-(void)removeAllBulks
{
    bulks = [NSMutableArray new];
}

-(BOOL)recordIsLoaded:(unsigned int)recid
{
    unsigned int page = recid / BULK_SIZE;
    
    for(FDRecordBaseBulk * bulk in bulks)
    {
        if (bulk.bulkPage == page)
            return YES;
    }
    return NO;
}

-(FDRecordBase *)getRawRecord:(unsigned int)recid
{
    BOOL hasLower = NO;
    BOOL hasHigher = NO;
    int page = recid / BULK_SIZE;
    FDRecordBase * retVal = nil;
    
    if (recid > [self textCount])
        return retVal;
    
    for (FDRecordBaseBulk * bulk in bulks) {
        if (bulk.bulkPage == page) {
            bulk.age = 0;
            retVal = [bulk.records objectAtIndex:(recid - bulk.baseId)];
        } else if (bulk.bulkPage == page - 1) {
            hasLower = YES;
            bulk.age = 0;
        } else if (bulk.bulkPage == page + 1) {
            hasHigher = YES;
            bulk.age = 0;
        }
    }

    BOOL needs = NO;
    
    if (!hasHigher || !hasLower) {
        [pagesLock lock];
        NSNumber * newNum;
        if (!hasHigher) {
            // load higher page
            newNum = [NSNumber numberWithInt:(page + 1)];
            if ([pagesToLoad indexOfObject:newNum] == NSNotFound)
            {
                [pagesToLoad addObject:newNum];
                needs = YES;
            }
        }
        
        if (!hasLower) {
            // load lower page
            newNum = [NSNumber numberWithInt:(page - 1)];
            if ([pagesToLoad indexOfObject:newNum] == NSNotFound)
            {
                [pagesToLoad addObject:newNum];
                needs = YES;
            }
        }
        [pagesLock unlock];
    }
    
    if (retVal) {
        if (needs) {
            [self loadNextPages];
        }
        return retVal;
    }
    
    FDRecordBaseBulk * bulk = [self loadRecordsPage:page];
    if (recid >= bulk.baseId && recid < bulk.baseId + BULK_SIZE)
    {
        return [bulk.records objectAtIndex:(recid - bulk.baseId)];
    }
    
    return nil;
}

-(void)loadRecordsPageAsync:(NSNumber *)numPage
{
    [self loadRecordsPage:[numPage intValue]];
    [self removeNextPage:numPage];
}

- (NSMutableDictionary *)readObjectNamesForContentRecords
{
    NSString * query = [NSString stringWithFormat:@"select record, objectname from contents_icons"];
    NSString * objectName;
    NSInteger record;
    NSMutableDictionary * map = [NSMutableDictionary new];
    
    SQLiteCommand * cmd = [self.database createCommand:query];
    
    if (cmd)
    {
        while ([cmd execute] == SQLITE_ROW)
        {
            record = [cmd intValue:0];
            objectName = [cmd stringValue:1];
            //NSLog(@"READ OBJCONT  %ld %@", record, objectName);
            [map setObject:objectName forKey:[NSNumber numberWithInteger:record]];
        }
    }
    
    return map;
}

- (void)readRecordsInPage:(int)recid recs:(NSMutableArray *)recs
{
    FolioTextRecord * result = nil;
    NSString * query = [NSString stringWithFormat:@"select plain, levelname, recid from texts where recid >= %d and recid < %d", recid, recid + BULK_SIZE];
    
    SQLiteCommand * cmd = [self.database createCommand:query];
    
    if (cmd)
    {
        while ([cmd execute] == SQLITE_ROW)
        {
            result = [[FolioTextRecord alloc] init];
            result.plainText = [cmd stringValue:0];
            result.levelName = [cmd stringValue:1];
            result.recordId = [cmd intValue:2];
            
            [recs addObject:result];
        }
    }
}

-(FDRecordBaseBulk *)loadRecordsPage:(int)page
{
    //NSLog(@"start load page %d", page);
    int baseId = page * BULK_SIZE;

    [self.loadPageLock lock];
    for (FDRecordBaseBulk * B in bulks)
    {
        if (B.bulkPage == page)
        {
            //NSLog(@"Refusing to load page %d", page);
            [self.loadPageLock unlock];
            return B;
        }
    }
    
    NSMutableArray * recs = [[NSMutableArray alloc] initWithCapacity:BULK_SIZE];
    FDRecordBaseBulk * bulk = [[FDRecordBaseBulk alloc] init];
    bulk.age = 0;
    bulk.baseId = baseId;
    bulk.count = BULK_SIZE;
    bulk.bulkPage = page;
    int recid = page * BULK_SIZE;
    
    [self readRecordsInPage:recid recs:recs];
    
    int recordsInserted = 0;
    for(FolioTextRecord * rec in recs)
    {
        int i = rec.recordId - baseId;
        if (i >= 0 && i < BULK_SIZE) {
            FDRecordBase * recBase = [self convert:rec];
            [bulk.records replaceObjectAtIndex:i withObject:recBase];
            recordsInserted ++;
        }
    }
    [self removeOldBulks];
    [self addBulk:bulk];

    [self loadNextPages];

    [self.loadPageLock unlock];

    return bulk;
}

#pragma mark -
#pragma mark pages-to-load management

-(void)loadNextPages
{
    [pagesLock lock];
    NSNumber * ptl = [pagesToLoad firstObject];
    if (ptl)
    {
        [self performSelectorInBackground:@selector(loadRecordsPageAsync:) withObject:ptl];
    }
    [pagesLock unlock];
}

-(void)removeNextPage:(NSNumber *)num
{
    [pagesLock lock];
    [pagesToLoad removeObject:num];
    [pagesLock unlock];
}

#pragma mark -
#pragma mark Bulk Management

-(void)addBulk:(FDRecordBaseBulk *)bulkObject
{
    [bulkLock lock];
    [bulks addObject:bulkObject];
    [bulkLock unlock];
}

-(void)removeOldBulks
{
    NSMutableArray * toremove = [[NSMutableArray alloc] init];
    for(FDRecordBaseBulk * bulka in bulks) {
        bulka.age++;
        if (bulka.age > MAX_BULK_AGE) {
            [toremove addObject:bulka];
        }
    }
    [bulkLock lock];
    [bulks removeObjectsInArray:toremove];
    [bulkLock unlock];
}


-(FDRecordBase *)convert:(FolioTextRecord *)recDict
{
    FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:self];
    
    FDRecordBase * recordBase = [fp convertToRaw:recDict];
    
    return recordBase;
}

- (void)initRawStyles
{
    if ([g_stylesMap count] > 0)
    {
        return;
    }

    g_stylesMap = [[NSMutableDictionary alloc] init];
    
    SQLiteCommand * stat = [self commandForKey:@"enum_styles"];
    NSString * prevStyleName = nil;
    NSString * currStyleName = nil;
    NSString * currDetailName = nil;
    NSString * currDetailValue = nil;
    FDTextFormat * currentFormat;
    if (stat)
    {
        while ([stat execute] == SQLITE_ROW)
        {
            currStyleName = [stat stringValue:0];
            currDetailName = [stat stringValue:1];
            currDetailValue = [stat stringValue:2];
            if ([currStyleName isEqualToString:@"PA_DevaNagariQ"]) {
                NSLog(@"      DevanagariQ: %@ -> %@", currDetailName, currDetailValue);
            }
            if (prevStyleName == nil || [prevStyleName isEqualToString:currStyleName] == NO)
            {
                currentFormat = [[FDTextFormat alloc] init];
                currentFormat.name = currStyleName;
                [g_stylesMap setObject:currentFormat forKey:currStyleName];
                prevStyleName = currStyleName;
            }
            
            [currentFormat setHtmlProperty:currDetailName value:currDetailValue];
            
        }
    }
}

-(FDTextFormat *)getRawStyle:(NSString *)nameRequested
{
    //
    // first try alternate styles map defined by
    // currently selected skin
    //
    if (g_alternateStylesMap != nil && g_alternateStylesMap.count > 0)
    {
        FDTextFormat * value = [g_alternateStylesMap objectForKey:nameRequested];
        if (value)
            return value;
    }

    if ([g_stylesMap count] == 0)
    {
        [self initRawStyles];
    }
    
    FDTextFormat * value = [g_stylesMap objectForKey:nameRequested];
    if (value) {
        //NSLog(@"GETRAWSTYLE: --- %@ --- success", nameRequested);
        return value;
    }
    //NSLog(@"GETRAWSTYLE: --- %@ --- not found", nameRequested);
    return nil;
}

+(void)setValue:(NSString *)strValue forHtmlProperty:(NSString *)strProp forStyle:(NSString *)strStyle dictionary:(NSMutableDictionary *)dict
{
    FDTextFormat * tf = [dict objectForKey:strStyle];
    if (tf == nil)
    {
        tf = [[FDTextFormat alloc] init];
        [dict setObject:tf forKey:strStyle];
    }
    
    [tf setHtmlProperty:strProp value:strValue];
}

-(void)refreshRecordData:(int)recid
{
    FDRecordBase * record = [self getRawRecord:recid];
    
    FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:self];

    [fp refresh:record];
}

-(void)setNeedsUpdateHighlightPhrases
{
    for(FDRecordBaseBulk * bulka in bulks) {
        for (int i = 0; i < bulka.records.count; i++)
        {
            FDRecordBase * rec = (FDRecordBase *)[bulka.records objectAtIndex:i];
            if (rec)
            {
                for (FDRecordPart * part in rec.parts)
                {
                    part.evaluateHighlightedWords = YES;
                }
            }
        }
    }
}

-(void)invalidateRecordWidths
{
    for(FDRecordBaseBulk * bulka in bulks) {
        for (int i = 0; i < bulka.records.count; i++)
        {
            FDRecordBase * rec = (FDRecordBase *)[bulka.records objectAtIndex:i];
            [rec setCalculatedWidth:0];
        }
    }
}

@end











