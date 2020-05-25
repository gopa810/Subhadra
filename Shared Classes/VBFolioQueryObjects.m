//
//  VBFolioQuery.m
//  Builder_iPad
//
//  Created by Peter Kollath on 4/24/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "VBFolioQueryObjects.h"
#import "VBFolioQueryOperator.h"
#import "VBFolioStorage.h"
#import "FlatFileUtils.h"

#pragma mark -
#pragma mark -
#pragma mark -

BOOL logCurrentRecord = NO;


#pragma mark -
#pragma mark -
#pragma mark -


@implementation VBFolioQueryOperatorContentItems

@synthesize array, simpleText, storage, exactWords;

-(id)init
{
    self = [super init];
    if (self) {
        readIndex = 0;
    }
    return self;
}

-(void)dealloc
{
    self.array = nil;
    //[super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Content items<br><b>%@</b>", simpleText];
}

-(void)validate
{
    if (_valid)
        return;

    if (self.exactWords)
        self.array = [self.storage enumerateContentItemsWithSimpleText:self.simpleText];
    else
        self.array = [self.storage enumerateContentItemsLikeSimpleText:self.simpleText];
    readIndex = 0;
    _valid = YES;
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    

    if (readIndex < [array count])
    {
        if (logCurrentRecord)
            NSLog(@"# OperatorContentItems:%d", [[array objectAtIndex:readIndex] unsignedIntValue]);
        return [[array objectAtIndex:readIndex] unsignedIntValue];
    }
    return 0;
}

-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    self.hitCount = self.hitCount + 1;
    readIndex++;
    if ([self.array count] <= readIndex) {
        _eof = YES;
        return NO;
    }
    
    return YES;
}

-(void)gotoLastRecord
{
    while(_eof == NO)
    {
        [self gotoNextRecord];
    }
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN QueryContentItems\n"];
    [self printSpaces:level toString:target];
    [target appendFormat:@"SIMPLE TEXT: %@\n", self.simpleText];
    [self printSpaces:level toString:target];
    [target appendString:@"END QueryContentItems\n"];
}


@end

#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFolioQueryOperatorContentSubItems

@synthesize array, source, storage;

-(id)init
{
    self = [super init];
    if (self) {
        readIndex = 0;
    }
    return self;
}

-(void)dealloc
{
    self.array = nil;
    //[super dealloc];
}

-(NSString *)description
{
    return @"Content Subitems";
}

-(void)validate
{
    if (_valid)
        return;
    uint32_t rec = [self.source currentRecord];
    if ([self.source endOfStream]) {
        _eof = YES;
        return;
    }
    self.array = [self.storage enumerateContentItemsForParent:rec];
    readIndex = 0;
    _valid = YES;
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    
    if (readIndex < [array count])
    {
        if (logCurrentRecord)
            NSLog(@"# QueryContentSubItems returns: %d", [[array objectAtIndex:readIndex] unsignedIntValue]);
        return [[array objectAtIndex:readIndex] unsignedIntValue];
    }
    return 0;
}

-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    self.hitCount = self.hitCount + 1;
    
    readIndex++;
    if ([self.array count] <= readIndex) {
        BOOL rec = [self.source gotoNextRecord];
        if (rec == NO) {
            _eof = YES;
            return NO;
        }
        self.array = [self.storage enumerateContentItemsForParent:[self.source currentRecord]];
        readIndex = 0;
    }
    
    return YES;
}

-(void)gotoLastRecord
{
    while(_eof == NO)
    {
        [self gotoNextRecord];
    }
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN QueryContentSubItems\n"];
    [self printSpaces:level toString:target];
    [target appendString:@"SOURCE:\n"];
    [self.source printAtLevel:(level + 1) toString:target];
    [self printSpaces:level toString:target];
    [target appendString:@"END QueryContentSubItems\n"];
}


@end


#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFolioQueryOperatorRecords

-(id)init
{
    self = [super init];
    if (self) {
        array = [[NSMutableArray alloc] init];
        readIndex = 0;
    }
    return self;
}

-(void)dealloc
{
    array = nil;//[array release];
    array = nil;
    //[super dealloc];
}

-(NSString *)description
{
    return @"Records";
}

-(void)add:(int)recid
{
    [array addObject:[NSNumber numberWithInt:recid]];
}

-(void)addArray:(NSArray *)arr
{
    [array addObjectsFromArray:arr];
}

-(uint32_t)currentRecord
{
    if (readIndex < [array count])
    {
        return [[array objectAtIndex:readIndex] unsignedIntValue];
    }
    return 0;
}

-(BOOL)gotoNextRecord
{
    readIndex++;
    if (readIndex >= [array count]) {
        _eof = YES;
        return NO;
    }
    self.hitCount = self.hitCount + 1;
    return YES;
}

-(void)gotoLastRecord
{
    while(_eof == NO)
    {
        [self gotoNextRecord];
    }
}



-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN QueryRecords\n"];
    [self printSpaces:level toString:target];
    [target appendString:@"END QueryRecords\n"];
}

@end

#pragma mark -
#pragma mark -
#pragma mark -


@implementation VBFolioQueryOperatorGetSubRanges

@synthesize source;
@synthesize storage;

-(id)init
{
    self = [super init];
    if (self) {
        rangeStart = 0;
        rangeEnd = 0;
        position = 1;
    }
    return self;
}

-(void)dealloc
{
    self.source = nil;
    //[super dealloc];
}

-(NSString *)description
{
    return @"Subranges";
}

-(void)validate
{
    if (_valid)
        return;
    uint32_t rec = [self.source currentRecord];
    if (rec == 0) {
        _eof = YES;
        return;
    }
    rangeStart = rec + 1;
    rangeEnd = [self getSubRangeEnd:rec];
    position = rangeStart;
    _valid = YES;
}

-(uint32_t)getSubRangeEnd:(uint32_t)recId
{
    int value;
    VBFolioContentItem * ci = [self.storage.content findRecordPath:recId];
    if (ci.next == nil)
    {
        while (ci && ci.next == nil)
        {
            ci = ci.parent;
        }
    }
    else
    {
        ci = ci.next;
    }
    if (ci) {
        value = (int)ci.recordId;
    } else {
        value = (int)self.storage.textCount - 1;
    }
    
    return value;
}

-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;

    self.hitCount = self.hitCount + 1;

    position++;
    if (rangeEnd < position) {
        BOOL ret1 = [self.source gotoNextRecord];
        if (ret1 == NO) {
            _eof = YES;
            return NO;
        }
        rangeStart = [self.source currentRecord] + 1;
        rangeEnd = [self getSubRangeEnd:(rangeStart - 1)];
        position = rangeStart;
    }
    
    return YES;
}

-(void)gotoLastRecord
{
    while(_eof == NO)
    {
        [self gotoNextRecord];
    }
    
    [source gotoLastRecord];
}


-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;

    if (logCurrentRecord)
        NSLog(@"# QuerySubRanges returns: %d", (int)position);
    return (int)position;
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN QuerySubRanges\n"];
    [self printSpaces:level toString:target];
    [target appendString:@"SOURCE:\n"];
    [self.source printAtLevel:(level + 1) toString:target];
    [self printSpaces:level toString:target];
    [target appendString:@"END QuerySubRanges\n"];
}

@end


#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFolioQueryOperatorGetLevelRecords

@synthesize levelIndex;
@synthesize storage, levelRecords, simpleTitle;
@synthesize exactWords;

-(id)init
{
    self = [super init];
    if (self) {
        self.storage = nil;
        self.levelRecords = nil;
        readIndex = 0;
        levelIndex = -1;
    }
    return self;
}

-(NSString *)description
{
    return @"Level Records";
}

-(id)initWithFolioStorage:(VBFolioStorage *)aStorage
{
    self = [super init];
    if (self) {
        self.storage = aStorage;
        self.levelRecords = nil;
        readIndex = 0;
        levelIndex = -1;
    }
    return self;
}

-(id)initWithFolioStorage:(VBFolioStorage *)aStorage level:(NSInteger)aLevel
{
    self = [super init];
    if (self) {
        self.storage = aStorage;
        self.levelRecords = nil;
        readIndex = 0;
        levelIndex = aLevel;
    }
    return self;
}

-(void)dealloc
{
    self.storage = nil;
    self.levelRecords = nil;
    //[super dealloc];
}

-(void)validate
{
    if (_valid == YES)
        return;
    if (self.simpleTitle) 
    {
        if (self.exactWords) {
            self.levelRecords = [storage enumerateLevelRecords:self.levelIndex withSimpleTitle:self.simpleTitle];
        } else {
            self.levelRecords = [storage enumerateLevelRecords:self.levelIndex likeSimpleTitle:self.simpleTitle];
        }
    }
    else 
    {
        self.levelRecords = [storage enumerateLevelRecords:self.levelIndex];
    }
    readIndex = 0;
    if ([self.levelRecords count] == 0)
        _eof = YES;
    _valid = YES;
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;

    if (readIndex < [self.levelRecords count]) {
        if (logCurrentRecord)
            NSLog(@"# QueryLevelRecords returns: %d", 
                  [[self.levelRecords objectAtIndex:readIndex] unsignedIntValue]);
        return [[self.levelRecords objectAtIndex:readIndex] unsignedIntValue];
    }
    return 0;
}

-(BOOL)gotoNextRecord
{
    if (_eof == YES)
        return NO;
    
    readIndex++;
    if (readIndex >= [self.levelRecords count]) {
        _eof = YES;
        return NO;
    }
    self.hitCount = self.hitCount + 1;
    
    return YES;
}

-(void)gotoLastRecord
{
    while(_eof == NO) {
        [self gotoNextRecord];
    }
}


-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN QueryLevelItems\n"];
    [self printSpaces:level toString:target];
    [target appendFormat:@"LEVEL: %ld \n", (long)self.levelIndex];
    [self printSpaces:level toString:target];
    [target appendString:@"END QueryLevelItems\n"];
}

@end

#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFolioQueryOperatorAnd
@synthesize items;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.items = [[NSMutableArray alloc] init];
        //self.items = arr;
        //[arr release];
    }
    
    return self;
}

-(NSString *)description
{
    return @"Operator AND";
}

-(void)dealloc
{
    self.items = nil;
    //[super dealloc];
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return 0;
    if (logCurrentRecord)
        NSLog(@"# QueryOperAnd: %d", [[items objectAtIndex:0] currentRecord]);
    return [[items objectAtIndex:0] currentRecord];
}


-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    self.hitCount = self.hitCount + 1;
    
    if ([[items objectAtIndex:0] gotoNextRecord] == NO)
    {
        _eof = YES;
        return NO;
    }
    
    _valid = NO;
    
    [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    return YES;
}

-(void)gotoLastRecord
{
    for (VBFolioQueryOperator * oper in items)
    {
        [oper gotoLastRecord];
    }
}


-(void)validate
{
    if (_valid == YES)
        return;
    
    if ([items count] == 0)
    {
        _valid = NO;
        return;
    }
    for (VBFolioQueryOperator * oper in items)
    {
        [oper validate];
    }
    
    //get maximum record
    uint32_t maxRec = [[items objectAtIndex:0] currentRecord];
    uint32_t rec = 0;
    BOOL bChange = YES;
    
    while (bChange)
    {
        bChange = NO;
        for (VBFolioQueryOperator * oper in items) 
        {
            rec = [oper currentRecord];
            if (rec != maxRec)
                bChange = YES;
            if (rec > maxRec)
            {
                maxRec = rec;
            }
            if (oper.endOfStream)
            {
                _eof = YES;
                return;
            }
        }
        
        if (bChange)
        {
            for (VBFolioQueryOperator * oper in items) 
            {
                if ([oper moveToRecord:maxRec] == NO)
                {
                    _eof = YES;
                    return;
                }
            }            
        }
    }
    
    _valid = YES;
}

-(BOOL)endOfStream
{
    _eof = NO;
    
    for (VBFolioQueryOperator * op in items) {
        if ([op endOfStream] == YES)
        {
            _eof = YES;
            break;
        }
    }
    
    return _eof;
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN OperatorAnd\n"];
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop)
     {
         [(VBFolioQueryOperator *)obj printAtLevel:(level + 1) toString:target];
     }];
    [self printSpaces:level toString:target];
    [target appendString:@"END OperatorAnd\n"];
}

@end


#pragma mark -
#pragma mark -
#pragma mark -


@implementation VBFolioQueryOperatorOr
@synthesize items;

-(id)init
{
    self = [super init];
    if (self)
    {
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        self.items = arr;
        //[arr release];
    }
    
    return self;
}

-(NSString *)description
{
    return @"Operator OR";
}

-(void)dealloc
{
    self.items = nil;
    //[super dealloc];
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return 0;
   
    if (logCurrentRecord)
        NSLog(@"# QueryOperOr: %d", [self smallestRecord]);
    return [self smallestRecord];
}

-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;

    self.hitCount = self.hitCount + 1;

    uint32_t rec = [self smallestRecord];
    
    for (VBFolioQueryOperator * oper in items) 
    {
        if ([oper currentRecord] == rec)
        {
            [oper gotoNextRecord];
        }
    }
    
    return YES;
}

-(void)gotoLastRecord
{
    for (VBFolioQueryOperator * oper in items)
    {
        [oper gotoLastRecord];
    }
}


-(uint32_t)smallestRecord
{
    uint32_t minRec = 0;
    uint32_t rec = 0;
    BOOL bInit = NO;
    
    for (VBFolioQueryOperator * oper in items) 
    {
        if (oper.endOfStream == NO)
        {
            rec = [oper currentRecord];
            if (bInit==NO || rec<minRec)
            {
                minRec = rec;
                bInit = YES;
            }
        }
    }
    
    if (bInit == NO)
    {
        _eof = YES;
    }
    
    return minRec;
}

-(uint16_t)smallestProximity:(int *)index
{
    uint32_t minRec = 0;
    uint32_t rec = 0;
    uint16_t minProx = 0;
    uint16_t prox = 0;
    BOOL bInit = NO;
    int idx = 0;
    
    for (VBFolioQueryOperator * oper in items) 
    {
        if (oper.endOfStream == NO)
        {
            rec = [oper currentRecord];
            if (bInit==NO || rec<minRec)
            {
                minRec = rec;
                minProx = [oper currentProximity];
                bInit = YES;
                if (index != NULL)
                    *index = idx;
            }
            else if (rec == minRec)
            {
                prox = [oper currentProximity];
                if (prox < minProx)
                {
                    minProx = prox;
                    if (index != NULL)
                        *index = idx;
                }
            }
        }
        idx ++;
    }
    
    if (bInit == NO)
    {
        _eof = YES;
    }
    
    return minRec;
}

-(void)validate
{
    if (_valid == YES)
        return;
    
    if ([items count] == 0)
    {
        _valid = NO;
        _eof = YES;
        return;
    }
    int count = 0;
    for (VBFolioQueryOperator * oper in items)
    {
        [oper validate];
        if (oper.valid == YES && [oper endOfStream] == NO)
            count++;        
    }
    
    if (count == 0)
    {
        _valid = NO;
        _eof = YES;
        for(VBFolioQueryOperator * oper in items)
        {
            [oper setEndOfStream:YES];
        }
        return;
    }
    
    _valid = YES;
}


-(uint16_t)currentProximity
{
    return [self smallestProximity:NULL];
}

-(BOOL)gotoNextProximity
{
    int index = 0;
    
    [self smallestProximity:&index];
    
    if (index >= 0 && index < [items count])
    {
        [[items objectAtIndex:index] gotoNextProximity];
    }
    return YES;
}

-(BOOL)endOfStream
{
    _eof = YES;
    
    for (VBFolioQueryOperator * op in items) {
        if ([op endOfStream] == NO)
        {
            _eof = NO;
            break;
        }
    }
    
    return _eof;
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN OperatorOr\n"];
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop)
     {
         [(VBFolioQueryOperator *)obj printAtLevel:(level + 1) toString:target];
     }];
    [self printSpaces:level toString:target];
    [target appendString:@"END OperatorOr\n"];
}


@end

#pragma mark -
#pragma mark -
#pragma mark -


@implementation VBFolioQueryOperatorNot

@synthesize partAnd;
@synthesize partOr;


-(id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

-(NSString *)description
{
    return @"Operator NOT";
}

-(void)dealloc
{
    self.partOr = nil;
    self.partAnd = nil;
    //[super dealloc];
}

-(uint32_t)currentRecord
{
    if (logCurrentRecord)
        NSLog(@"# QueryOperNot: %d", [partAnd currentRecord]); 
    return [partAnd currentRecord];
}

-(BOOL)gotoNextRecord
{
    self.hitCount = self.hitCount + 1;

    _eof = [partAnd gotoNextRecord];
    _valid = NO;
    [self validate];
    return _eof;
}

-(void)gotoLastRecord
{
    [partOr gotoLastRecord];
    [partAnd gotoLastRecord];
}


-(void)validate
{
    if (_valid == NO)
    {
        [partAnd validate];
        [partOr validate];
        if ([partAnd endOfStream] == YES)
            return;
        [partOr moveToRecord:[partAnd currentRecord]];
        while ([partOr endOfStream] == NO 
               && [partAnd currentRecord] == [partOr currentRecord]
               && [partAnd endOfStream] == NO)
        {
            [partAnd gotoNextRecord];
            [partOr moveToRecord:[partAnd currentRecord]];
        }
        _eof = [partAnd endOfStream];
        _valid = (_eof == NO);
    }
}

-(BOOL)endOfStream
{
    return [partAnd endOfStream];
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN OperatorNot\n"];
    [self printSpaces:level toString:target];
    [target appendString:@" AND PART\n"];
    [self.partAnd printAtLevel:(level+1) toString:target];
    [self printSpaces:level toString:target];
    [target appendString:@" OR PART\n"];
    [self.partOr printAtLevel:(level+1) toString:target];
    [self printSpaces:level toString:target];
    [target appendString:@"END OperatorNot\n"];
}



@end

#pragma mark -
#pragma mark -
#pragma mark -

@implementation VBFolioQueryOperatorStream

@synthesize word;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.blobsArray = nil;
        self.blobSize = 0;
        self.currentBufferPosition = 0;
    }
    
    return self;
}

-(NSString *)description
{
    return word;
}

-(uint32_t)currentRecord
{
    if (self.blobSize == 0) {
        _eof = YES;
        return 0;
    }
    uint32_t rec = CFSwapInt32LittleToHost( *(uint32_t *)(buffer + self.currentBufferPosition)) + self.indexBase;
    
    return rec;
}

-(uint16_t)currentProximity
{
    uint16_t rec = CFSwapInt16LittleToHost( *(uint16_t *)(buffer + self.currentBufferPosition + 4));
    
    return rec;
}

-(void)gotoLastRecord
{
    while (_eof == NO) {
        [self gotoNextRecord];
    }
}

-(BOOL)gotoNextRecord
{
    BOOL b = YES;
    uint32_t rec = [self currentRecord];

    self.hitCount = self.hitCount + 1;

    while (rec == [self currentRecord])
    {
        b = [self gotoNextProximity];
        if (b == NO)
        {
            _eof = YES;
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)gotoNextProximity
{
    self.currentBufferPosition = self.currentBufferPosition + BUFFER_ITEM_SIZE;
    while(self.currentBufferPosition >= self.blobSize)
    {
        self.blobSize = 0;
        self.currentBufferPosition = 0;
        self.currentBlobIndex = self.currentBlobIndex + 1;
        if (self.currentBlobIndex >= self.blobsArray.count)
            break;
        [self readBlob:self.currentBlobIndex];
    }
    
    if (self.blobSize == 0) {
        _eof = YES;
        return NO;
    }

    return YES;
}

-(BOOL)readBlob:(NSInteger)index
{
    SQLiteBlob * blob = nil;
    NSDictionary * dict = nil;
    
    if (index < self.blobsArray.count) {
        dict = [self.blobsArray objectAtIndex:index];
    }
    if (dict == nil) {
        return NO;
    }
    
    blob = [self.database openBlob:[[dict objectForKey:@"ROWID"] integerValue]
                          database:[dict objectForKey:@"DBNAME"]
                             table:[dict objectForKey:@"TABLENAME"]
                            column:[dict objectForKey:@"COLUMNNAME"]];
    /*            NSDictionary * item = [NSDictionary dictionaryWithObjectsAndKeys:@"main", @"DBNAME",
     @"words", @"TABLENAME", @"data", @"COLUMNNAME",
     [NSNumber numberWithInt:[cmd intValue:1]], @"INDEXBASE",
     [NSNumber numberWithInteger:[cmd int64Value:0]], @"ROWID",
     nil];*/
    if (blob == nil)
        return NO;
    
    self.blobData = [blob mutableData];
    self.blobSize = self.blobData.length;
    self.currentBufferPosition = 0;
    self.indexBase = [(NSNumber *)[dict objectForKey:@"INDEXBASE"] intValue];
    buffer = (const unsigned char *)self.blobData.bytes;

    blob = nil;
    
    _valid = YES;
    return YES;
}

-(void)setBlobs:(NSArray *)blobsArray
{
    self.blobData = nil;
    self.blobsArray = blobsArray;
    self.currentBlobIndex = 0;
    
    if (blobsArray.count > 0) {
        [self readBlob:0];
    }
    
    _eof = ([self.blobData length] == 0);
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN STREAM\n"];
    [self printSpaces:level toString:target];
    [target appendFormat:@"WORD: %@\n", self.word];
    [self printSpaces:level toString:target];
    [target appendString:@"END STREAM\n"];
}


@end

#pragma mark -
#pragma mark -
#pragma mark -



@implementation VBFolioQueryOperatorQuote
@synthesize items;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.items = [[NSMutableArray alloc] init];
        // arr;
        //[arr release];
    }
    
    return self;
}

-(NSString *)description
{
    return @"Quote";
}

-(void)dealloc
{
    self.items = nil;
    //[super dealloc];
}

-(uint32_t)currentRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return 0;
    
    return [[items objectAtIndex:0] currentRecord];
}

-(BOOL)gotoNextRecord
{
    if (_valid == NO)
        [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    self.hitCount = self.hitCount + 1;
    
    if ([[items objectAtIndex:0] gotoNextRecord] == NO)
    {
        _eof = YES;
        return NO;
    }
    
    _valid = NO;
    
    [self validate];
    if (_valid == NO || _eof == YES)
        return NO;
    
    return YES;
}

-(void)gotoLastRecord
{
    for (VBFolioQueryOperator * oper in items)
    {
        [oper gotoLastRecord];
    }
}

-(void)validate
{
    if (_valid == YES)
        return;
    
    if ([items count] == 0)
    {
        _valid = NO;
        return;
    }
    for (VBFolioQueryOperator * oper in items)
    {
        [oper validate];
    }
    
    //get maximum record
    uint32_t maxRec = [[items objectAtIndex:0] currentRecord];
    uint32_t rec = 0;
    BOOL bChange = YES;
    
    while (bChange)
    {
        bChange = NO;
        for (VBFolioQueryOperator * oper in items) 
        {
            rec = [oper currentRecord];
            if (rec != maxRec)
                bChange = YES;
            if (rec > maxRec)
                maxRec = rec;
            if (oper.endOfStream)
            {
                _eof = YES;
                return;
            }
        }
        
        if (bChange)
        {
            // not all streams has the same record id
            // so trying to align all streams by moving them
            // to the highest record id retrieved
            for (VBFolioQueryOperator * oper in items) 
            {
                if ([oper moveToRecord:maxRec] == NO)
                {
                    _eof = YES;
                    return;
                }
            }            
        }
        else 
        {
            // here all streams points to the same record id
            // so we have to check proximity
            uint16_t prox;
            uint16_t npro;
            BOOL bInit = NO;
            int indexToMove = 0;
            
            // check proximity
            // go through all streams
            // and check if current stream is +1 toward previous stream
            for (VBFolioQueryOperator * stream in items) 
            {
                if (bInit == NO)
                {
                    prox = [stream currentProximity];
                    bInit = YES;
                }
                else 
                {
                    // not in the line with previous stream
                    // change is: goto next promity in previous
                    // stream
                    // we break the loop here, so the index of previous stream
                    // is stored in indexToMove variable
                    npro = [stream currentProximity];
                    if (prox + 1 != npro)
                    {
                        bChange = YES;
                        break;
                    }
                    prox = npro;
                }
                indexToMove++;
                
            }
            
            // we have found item which does not corresponds with
            // previous proximity
            // so we have to move that previous proximity
            // a go the whole loop again
            if (bChange)
            {
                [[items objectAtIndex:indexToMove] gotoNextProximity];
            }
            
        }
    }
    
    _valid = YES;
}

-(BOOL)endOfStream
{
    _eof = NO;
    
    for (VBFolioQueryOperator * op in items) {
        if ([op endOfStream] == YES)
        {
            _eof = YES;
            break;
        }
    }
    
    return _eof;
}


-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"BEGIN OperatorQuote\n"];
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop)
     {
         [(VBFolioQueryOperator *)obj printAtLevel:(level + 1) toString:target];
     }];
    [self printSpaces:level toString:target];
    [target appendString:@"END OperatorQuote\n"];
}


@end


#pragma mark -
#pragma mark -
#pragma mark -







