//
//  VBFolioQuery.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import "VBFolioQuery.h"

extern BOOL logCurrentRecord;

@implementation VBFolioQuery

@synthesize storage;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        tableCounter = 1;
    }
    
    return self;
}

-(id)initWithStorage:(VBFolioStorage *)store
{
    self = [super init];
    
    if (self)
    {
        self.storage = store;
        tableCounter = 1;
    }
    
    return self;
}

-(NSArray *)sourceToArray:(NSString *)queryText
{
    NSString * query = [[NSString alloc]
                        initWithData: [queryText dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                        encoding:NSASCIIStringEncoding];
    
    NSMutableString * currentWord = nil;
    NSMutableArray * currentArray = nil;
    NSMutableArray * arrayStack = [[NSMutableArray alloc] init];
    NSMutableDictionary * currentDictionary = nil;
    
    NSMutableArray * queryArray = nil;
    BOOL inQuote = NO;
    
    NSInteger len = [query length];
    
    for (int a = 0; a < len; a++)
    {
        unichar c = [query characterAtIndex:a];
        if (isalnum(c) || c=='%' || c=='*' || c=='?' || c=='\'' || c=='-' || c=='.')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            if (currentWord == nil)
            {
                currentDictionary = [[NSMutableDictionary alloc] init];
                [currentArray addObject:currentDictionary];
                //[currentDictionary release];
                currentWord = [[NSMutableString alloc] init];
                [currentDictionary setObject:currentWord forKey:@"word"];
                //[currentWord release];
                [currentDictionary setObject:@"word" forKey:@"type"];
            }
            
            if (c == '*')
                c = '%';
            [currentWord appendFormat:@"%C", c];
        }
        else if (c == '\"' || c=='\'')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            
            if (inQuote)
            {
                if ([arrayStack count] > 1)
                {
                    [arrayStack removeLastObject];
                    currentArray = [arrayStack lastObject];
                    currentDictionary = [currentArray lastObject];
                }
                inQuote = NO;
            }
            else
            {
                currentDictionary = [[NSMutableDictionary alloc] init];
                [currentArray addObject:currentDictionary];
                //[currentDictionary release];
                [currentDictionary setObject:@"string" forKey:@"type"];
                currentArray = [[NSMutableArray alloc] init];
                [currentDictionary setObject:currentArray forKey:@"array"];
                //[currentArray release];
                [arrayStack addObject:currentArray];
                inQuote = YES;
            }
            currentWord = nil;
        }
        else if (c == '(' || c == '[')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            currentDictionary = [[NSMutableDictionary alloc] init];
            [currentArray addObject:currentDictionary];
            //[currentDictionary release];
            [currentDictionary setObject:(c == '(' ? @"array" : @"meta") forKey:@"type"];
            currentArray = [[NSMutableArray alloc] init];
            [currentDictionary setObject:currentArray forKey:@"array"];
            //[currentArray release];
            [arrayStack addObject:currentArray];
            currentWord = nil;
        }
        else if (c == ')' || c == ']')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            if ([arrayStack count] > 1)
            {
                [arrayStack removeLastObject];
                currentArray = [arrayStack lastObject];
                currentDictionary = [currentArray lastObject];
            }
            currentWord = nil;
        }
        else if (c == '&')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            
            //[currentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"and", @"word", @"word", @"type", nil]];
            currentWord = nil;
            
        }
        else if (c=='|' || c=='/')
        {
            if (queryArray == nil)
            {
                queryArray = [[NSMutableArray alloc] init];
                [arrayStack addObject:queryArray];
                currentArray = queryArray;
            }
            [currentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"or", @"word", @"word", @"type", nil]];
            currentWord = nil;
            
        }
        else if (c == ',')
        {
            [currentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"meta:comma", @"type", nil]];
            currentWord = nil;
        }
        else if (c == ':')
        {
            [currentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"meta:dots", @"type", nil]];
            currentWord = nil;
        }
        else // other characters are just separators
        {
            currentWord = nil;
        }
    }
    
    //[query release];
    return queryArray;
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

#pragma mark Methods for converting into SQL query

-(NSString *)convertQuoteToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes
{
    NSMutableString * str = [[NSMutableString alloc] init];
    
    [str appendFormat:@"select distinct wi%d.recid from ", tableCounter];
    
    VBHighlightedPhrase * arrTemp = nil;
    if (quotes)
    {
        arrTemp = [[VBHighlightedPhrase alloc] init];
        [quotes addObject:arrTemp];
        //[arrTemp release];
    }
    
    int i = 0;
    for (i = 0; i < array.count; i++) {
        if (i > 0)
            [str appendString:@", "];
        [str appendFormat:@"words w%d, windex wi%d", i+tableCounter, i+tableCounter];
    }
    [str appendString:@" where "];
    i = tableCounter;
    for (NSDictionary * d in array) {
        if (i > tableCounter)
            [str appendString:@" and "];
        NSString * key = [d objectForKey:@"word"];
        if (arrTemp)
            [arrTemp addWord:key];
        if ([self stringContainsWildcards:key])
            [str appendFormat:@"w%d.word like '%@' and wi%d.wordid = w%d.uid", i, key,i, i];
        else
            [str appendFormat:@"w%d.word='%@' and wi%d.wordid = w%d.uid", i, key,i, i];
        i++;
    }
    for (i = 1; i < array.count; i++) {
        [str appendFormat:@" and wi%d.recid=wi%d.recid and wi%d.proximity=wi%d.proximity+1", i+tableCounter-1, i+tableCounter,i+tableCounter, i+tableCounter-1];
    }
    
    tableCounter = tableCounter + (int)array.count;
    
    return str;
}

-(NSString *)convertAndToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes
{
    NSMutableString * str = [[NSMutableString alloc] init];
    
    [str appendFormat:@"select distinct wi%d.recid from ", tableCounter];
    
    int i = tableCounter;
    for (i = tableCounter; i < array.count + tableCounter; i++) {
        if (i > tableCounter)
            [str appendString:@", "];
        [str appendFormat:@"words w%d, windex wi%d", i, i];
    }
    [str appendString:@" where "];
    i = tableCounter;
    for (NSDictionary * d in array) {
        if (i > tableCounter)
            [str appendString:@" and "];
        NSString * key = [d objectForKey:@"word"];
        if (quotes)
        {
            VBHighlightedPhrase * hp = [[VBHighlightedPhrase alloc] init];
            [quotes addObject:hp];
            [hp addWord:key];
            //[hp release];
        }
        if ([self stringContainsWildcards:key])
            [str appendFormat:@"w%d.word like '%@' and wi%d.wordid = w%d.uid", i, key,i, i];
        else
            [str appendFormat:@"w%d.word='%@' and wi%d.wordid = w%d.uid", i, key,i, i];
        i++;
    }
    i = tableCounter;
    for (i = tableCounter; i < array.count + tableCounter; i++) {
        if (i > tableCounter)
            [str appendFormat:@" and wi%d.recid=wi%d.recid", i-1, i];
    }
    
    tableCounter = i;
    return str;
}

-(NSString *)convertAndNotArrayToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes
{
    BOOL hasNot = NO;
    BOOL hasArray = NO;
    BOOL hasString = NO;
    for (NSDictionary * d1 in array) {
        if ([[d1 objectForKey:@"type"] isEqualToString:@"word"]
            && [[d1 objectForKey:@"word"] isEqualToString:@"not"])
        {
            hasNot = YES;
        }
        else if ([[d1 objectForKey:@"type"] isEqualToString:@"string"])
        {
            hasString = YES;
        }
        else if ([[d1 objectForKey:@"type"] isEqualToString:@"array"])
        {
            hasArray = YES;
        }
    }
    
    if (hasNot == NO && hasString == NO && hasArray == NO)
    {
        return [self convertAndToQuery:array quotesArray:quotes];
    }
    else
    {
        NSMutableArray * andArray = [[NSMutableArray alloc] init];
        NSMutableArray * quoteArray = [[NSMutableArray alloc] init];
        NSMutableArray * notArray = [[NSMutableArray alloc] init];
        NSMutableString * str = [[NSMutableString alloc] init];
        NSString * temp1 = nil;
        BOOL moveToNot = NO;
        for (NSDictionary * d in array) {
            if ([[d objectForKey:@"type"] isEqualToString:@"word"] &&
                [[d objectForKey:@"word"] isEqualToString:@"not"])
            {
                moveToNot = YES;
            }
            else if (moveToNot == YES)
            {
                [notArray addObject:d];
                moveToNot = NO;
            }
            else if ([[d objectForKey:@"type"] isEqualToString:@"string"])
            {
                [quoteArray addObject:d];
            }
            else {
                [andArray addObject:d];
            }
        }
        
        if ([andArray count] > 0)
        {
            temp1 = [self convertAndToQuery:andArray quotesArray:quotes];
            if ([temp1 length] > 0)
                [str appendString:temp1];
        }
        for (NSDictionary * d in quoteArray)
        {
            temp1 = [self convertQuoteToQuery:[d objectForKey:@"array"] quotesArray:quotes];
            if ([str length] > 0)
                [str appendString:@" INTERSECT "];
            [str appendString:temp1];
        }
        for (NSDictionary * d in notArray)
        {
            NSArray * array5 = [[NSArray alloc] initWithObjects:d, nil];
            temp1 = [self convertArrayToQuery:array5 quotesArray:nil];
            //[array5 release];
            if ([str length] > 0)
                [str appendFormat:@" EXCEPT %@", temp1];
        }
        
        //[notArray release];
        //[andArray release];
        //[quoteArray release];
        
        return str;
    }
    
}

-(NSString *)convertArrayToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes
{
    BOOL hasOr = NO;
    for (NSDictionary * d1 in array) {
        if ([[d1 objectForKey:@"type"] isEqualToString:@"word"])
        {
            if ([[d1 objectForKey:@"word"] isEqualToString:@"or"])
            {
                hasOr = YES;
                break;
            }
        }
    }
    
    if (hasOr == NO)
    {
        return [self convertAndNotArrayToQuery:array quotesArray:quotes];
    }
    else
    {
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        NSMutableArray * arr2 = [[NSMutableArray alloc] init];
        [arr1 addObject:arr2];
        //[arr2 release];
        
        //BOOL needIntersection = NO;
        NSInteger count = 0;
        NSInteger maxCount = 0;
        for (NSDictionary * d1 in array) {
            if ([[d1 objectForKey:@"type"] isEqualToString:@"word"] &&
                [[d1 objectForKey:@"word"] isEqualToString:@"or"])
            {
                arr2 = [[NSMutableArray alloc] init];
                [arr1 addObject:arr2];
                //[arr2 release];
            }
            else {
                [arr2 addObject:d1];
                count = [arr2 count];
                if (count > maxCount)
                    maxCount = count;
                // if part of or statement is more than two words or is subquery
                // we have to indicate that UNION statement should be used in the
                // output query string
                // so just increase the number of maxCount
                // because in the next check if maxCount is > 1 then UNION statement
                // will be used
                if ([[d1 objectForKey:@"type"] isEqualToString:@"word"] == NO)
                {
                    maxCount = 10;
                }
            }
        }
        
        NSMutableString * str = [[NSMutableString alloc] init];
        
        if (maxCount == 1)
        {
            //BOOL needOr = NO;
            [str appendString:@"select distinct wi1.recid from words w1, windex wi1 where ("];
            for (NSArray * arr3 in arr1)
            {
                NSDictionary * d = [arr3 lastObject];
                NSString * word = [d objectForKey:@"word"];
                if ([self stringContainsWildcards:word])
                {
                    [str appendFormat:@"w1.word like '%@'", word];
                }
                else
                {
                    [str appendFormat:@"w1.word='%@'", word];
                }
                //needOr = YES;
            }
            [str appendString:@") and wi1.wordid = w1.uid"];
        }
        else
        {
            NSString * str2;
            [str setString:@"("];
            for (NSArray * arr3 in arr1)
            {
                str2 = [self convertAndNotArrayToQuery:arr3 quotesArray:quotes];
                if ([str2 length] > 0)
                {
                    if ([str length] > 1)
                        [str appendString:@" UNION "];
                    [str appendString:str2];
                }
            }
            [str setString:@")"];
        }
        
        
        //[arr1 release];
        
        return str;
    }
}


#pragma mark Methods for converting into genuine VBFolio query

-(VBFolioQueryOperator *)convertQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctxi
{
    VBHighlightedPhrase * arrTemp = nil;
    if (ctxi.quotes)
    {
        arrTemp = [[VBHighlightedPhrase alloc] init];
        [ctxi.quotes addObject:arrTemp];
        //[arrTemp release];
    }
    
    VBSearchTreeContext * ctx = [[VBSearchTreeContext alloc] initWithContext:ctxi];
    VBFolioQueryOperatorQuote * vq = [[VBFolioQueryOperatorQuote alloc] init];
    
    for (NSDictionary * d in array)
    {
        NSString * key = [d objectForKey:@"word"];
        NSRange dashRange = [key rangeOfString:@"-"];
        // words containing dash character
        // will be splitted into parts
        if ([key isEqualToString:@"kw"])
        {
            ctx.wordsDomain = @"keywords";
        }
        else if (dashRange.location == NSNotFound)
        {
            [arrTemp addWord:key];
            [vq.items addObject:[self convertWordToTree:key context:ctx]];
        }
        else
        {
            NSArray * parts = [key componentsSeparatedByString:@"-"];
            for(NSString * part in parts)
            {
                if (part.length > 0)
                {
                    [arrTemp addWord:part];
                    [vq.items addObject:[self convertWordToTree:part context:ctx]];
                }
            }
        }
    }
    
    return vq;
}

-(VBFolioQueryOperator *)convertWordToTree:(NSString *)word context:(VBSearchTreeContext *)ctx
{
    if ([self stringContainsWildcards:word])
    {
        NSArray * words = [storage searchWords:word forIndex:ctx.wordsDomain];
        VBFolioQueryOperatorOr * vor2 = [[VBFolioQueryOperatorOr alloc] init];
        for (NSString * strWord in words)
        {
            VBFolioQueryOperatorStream * vbs = [[VBFolioQueryOperatorStream alloc] init];
            vbs.database = storage.database;
            [vbs setBlobs:[storage getWordIndexBlob:[strWord lowercaseString] forIndex:ctx.wordsDomain]];
            vbs.word = strWord;
            [vor2.items addObject:vbs];
            //[vbs release];
        }
        return vor2;
    }
    else
    {
        VBFolioQueryOperatorStream * vbs = [[VBFolioQueryOperatorStream alloc] init];
        vbs.database = storage.database;
        [vbs setBlobs:[storage getWordIndexBlob:[word lowercaseString] forIndex:ctx.wordsDomain]];
        vbs.word = word;
        return vbs;
    }
}

//
// converting scope tags into tree
// [Headings ...]
// [Contents ...]
// [Level ......]
// [Group ......]
// [Field ......]
// [Note .......]
// [Popup ......]
//
-(VBFolioQueryOperator *)convertMetaToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx
{
    NSDictionary * item = nil;
    if ([array count] > 0)
    {
        item = [array objectAtIndex:0];
        //
        // [Note ....]
        //
        if ([(NSString *)[item objectForKey:@"type"] compare:@"word"] == NSOrderedSame &&
            [[item objectForKey:@"word"] compare:@"note" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSArray * args = [array subarrayWithRange:NSMakeRange(1, [array count]-1)];
            VBSearchTreeContext * ctx2 = [[VBSearchTreeContext alloc] initWithContext:ctx];
            ctx2.wordsDomain = @"Note";
            
            if ([args count] > 0) {
                return [self convertArrayToTree:args context:ctx2];
            } else {
                return [self convertWordToTree:@"<all>" context:ctx2];
            }
        }
        //
        // Popup .....
        //
        else if ([(NSString *)[item objectForKey:@"type"] compare:@"word"] == NSOrderedSame &&
                 [[item objectForKey:@"word"] compare:@"popup" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSArray * args = [array subarrayWithRange:NSMakeRange(1, [array count]-1)];
            VBSearchTreeContext * ctx2 = [[VBSearchTreeContext alloc] initWithContext:ctx];
            //ctx2.quotes = ctx.quotes;
            ctx2.wordsDomain = @"Popup";
            //ctx2.exactWords = ctx.exactWords;
            
            if ([args count] > 0) {
                return [self convertArrayToTree:args context:ctx2];
            } else {
                return [self convertWordToTree:@"<all>" context:ctx2];
            }
        }
        //
        // Group .....
        //
        else if ([(NSString *)[item objectForKey:@"type"] compare:@"word"] == NSOrderedSame &&
                 [[item objectForKey:@"word"] compare:@"group" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSMutableString * groupName = [[NSMutableString alloc] init];
            int i = 1;
            while([array count] > i) {
                NSDictionary * d = [array objectAtIndex:i];
                if ([[d objectForKey:@"type"] isEqual:@"word"])
                {
                    if ([groupName length] > 0)
                        [groupName appendString:@" "];
                    [groupName appendString:[d objectForKey:@"word"]];
                }
                i++;
            }
            VBFolioQueryOperatorRecords * grec = [[VBFolioQueryOperatorRecords alloc] init];
            [grec addArray:[storage enumerateGroupRecords:groupName]];
            
            VBFolioQueryOperatorGetSubRanges * subs = [[VBFolioQueryOperatorGetSubRanges alloc] init];
            subs.storage = storage;
            subs.source = grec;
            
            return subs;
        }
        //
        // Field N : .....
        //
        else if ([(NSString *)[item objectForKey:@"type"] compare:@"word"] == NSOrderedSame &&
                 [[item objectForKey:@"word"] compare:@"field" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSMutableString * fieldName = [[NSMutableString alloc] init];
            NSMutableArray * args = [[NSMutableArray alloc] init];
            
            int i = 1;
            while([array count] > i) {
                NSDictionary * d = [array objectAtIndex:i];
                if ([[d objectForKey:@"type"] isEqual:@"meta:dots"]) {
                    i++;
                    break;
                }
                if ([[d objectForKey:@"type"] isEqual:@"word"])
                {
                    if ([fieldName length] > 0)
                        [fieldName appendString:@" "];
                    [fieldName appendString:[d objectForKey:@"word"]];
                }
                i++;
            }
            while([array count] > i) {
                [args addObject:[array objectAtIndex:i]];
                i++;
            }
            VBFolioQueryOperator * prevOper = nil;
            if (fieldName != nil && [fieldName length] > 0)
            {
                if ([args count] > 0) {
                    VBSearchTreeContext * ctx2 = [[VBSearchTreeContext alloc] initWithContext:ctx];
                    ctx2.wordsDomain = fieldName;
                    
                    
                    prevOper = [self convertArrayToTree:args context:ctx2];
                }
                else {
                    VBSearchTreeContext * ctx2 = [[VBSearchTreeContext alloc] initWithContext:ctx];
                    ctx2.wordsDomain = fieldName;
                    
                    prevOper = [self convertWordToTree:@"<all>" context:ctx2];
                }
            }
            else {
                VBSearchTreeContext * ctx2 = [[VBSearchTreeContext alloc] initWithContext:ctx];
                ctx2.wordsDomain = @"<all>";
                
                prevOper = [self convertWordToTree:@"<all>" context:ctx2];
            }
            //[args release];
            
            return prevOper;
        }
        //
        // Level N : .....
        //
        else if ([(NSString *)[item objectForKey:@"type"] compare:@"word"] == NSOrderedSame &&
                 [[item objectForKey:@"word"] compare:@"level" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSMutableString * levelName = [[NSMutableString alloc] init];
            NSMutableArray * args = [[NSMutableArray alloc] init];
            
            int i = 1;
            while([array count] > i) {
                NSDictionary * d = [array objectAtIndex:i];
                if ([[d objectForKey:@"type"] isEqual:@"meta:dots"]) {
                    i++;
                    break;
                }
                if ([[d objectForKey:@"type"] isEqual:@"word"])
                {
                    if ([levelName length] > 0)
                        [levelName appendString:@" "];
                    [levelName appendString:[d objectForKey:@"word"]];
                }
                i++;
            }
            while([array count] > i) {
                [args addObject:[array objectAtIndex:i]];
                i++;
            }
            int level = [storage findOriginalLevelIndex:levelName];
            
            VBFolioQueryOperatorGetLevelRecords * levelOper = [[VBFolioQueryOperatorGetLevelRecords alloc] initWithFolioStorage:storage];
            levelOper.levelIndex = level;
            levelOper.exactWords = ctx.exactWords;
            VBFolioQueryOperator * prevOper = levelOper;
            
            if ([args count] > 0) {
                VBFolioQueryOperatorGetSubRanges * subs = [[VBFolioQueryOperatorGetSubRanges alloc] init];
                
                subs.storage = storage;
                subs.source = prevOper;
                
                
                VBFolioQueryOperator * oper = [self convertArrayToTree:args context:ctx];
                
                VBFolioQueryOperatorAnd * ands = [[VBFolioQueryOperatorAnd alloc] init];
                [ands.items addObject:subs];
                [ands.items addObject:oper];
                
                prevOper = ands;
            }
            //[args release];
            
            return prevOper;
        }
        //
        // Headings X, N1, N2, ... NN
        //
        else if ([[item objectForKey:@"type"] isEqual:@"word"] &&
                 [[item objectForKey:@"word"] compare:@"headings" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSMutableArray * args = [[NSMutableArray alloc] init];
            NSMutableString * str1 = [[NSMutableString alloc] init];
            [args addObject:str1];
            //[str1 release];
            
            int i = 1;
            while([array count] > i)
            {
                NSDictionary * d = [array objectAtIndex:i];
                if ([[d objectForKey:@"type"] isEqual:@"meta:comma"]) {
                    str1 = [[NSMutableString alloc] init];
                    [args addObject:str1];
                    //[str1 release];
                }
                if ([[d objectForKey:@"type"] isEqual:@"word"])
                {
                    if ([str1 length] > 0)
                        [str1 appendString:@" "];
                    [str1 appendString:[d objectForKey:@"word"]];
                }
                i++;
            }
            int level = [storage findOriginalLevelIndex:[args objectAtIndex:0]];
            
            VBFolioQueryOperatorGetLevelRecords * levelOper = [[VBFolioQueryOperatorGetLevelRecords alloc] initWithFolioStorage:storage];
            levelOper.levelIndex = level;
            levelOper.exactWords = ctx.exactWords;
            VBFolioQueryOperator * prevOper = levelOper;
            
            for(int subi = 1; subi < [args count]; subi++)
            {
                if (subi == 1) {
                    levelOper.simpleTitle = [[(NSString *)[args objectAtIndex:subi] lowercaseString] stringByReplacingOccurrencesOfString:@". " withString:@" "];
                } else if (subi > 1) {
                    VBFolioQueryOperatorContentSubItems * subIt1 = [[VBFolioQueryOperatorContentSubItems alloc] init];
                    subIt1.storage = storage;
                    subIt1.source = prevOper;
                    prevOper = subIt1;
                    
                    VBFolioQueryOperatorContentItems * cit = [[VBFolioQueryOperatorContentItems alloc] init];
                    //[cit autorelease];
                    cit.storage = storage;
                    cit.simpleText = [[(NSString *)[args objectAtIndex:subi] lowercaseString] stringByReplacingOccurrencesOfString:@". " withString:@" "];
                    cit.exactWords = ctx.exactWords;
                    
                    VBFolioQueryOperatorAnd * join1 = [[VBFolioQueryOperatorAnd alloc] init];
                    [join1.items addObject:cit];
                    [join1.items addObject:prevOper];
                    prevOper = join1;
                }
            }
            
            VBFolioQueryOperatorGetSubRanges * subOper = [[VBFolioQueryOperatorGetSubRanges alloc] init];
            //[subOper autorelease];
            subOper.storage = storage;
            subOper.source = prevOper;
            
            //[args release];
            return subOper;
            
        }
        //
        // Contents N1, N2, .... NN
        //
        else if ([[item objectForKey:@"type"] isEqual:@"word"] &&
                 [[item objectForKey:@"word"] compare:@"contents" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            NSMutableArray * args = [[NSMutableArray alloc] init];
            NSMutableString * str1 = [[NSMutableString alloc] init];
            [args addObject:str1];
            //[str1 release];
            
            int i = 1;
            while([array count] > i)
            {
                NSDictionary * d = [array objectAtIndex:i];
                if ([[d objectForKey:@"type"] isEqual:@"meta:comma"]) {
                    str1 = [[NSMutableString alloc] init];
                    [args addObject:str1];
                    //[str1 release];
                }
                if ([[d objectForKey:@"type"] isEqual:@"word"])
                {
                    if ([str1 length] > 0)
                        [str1 appendString:@" "];
                    [str1 appendString:[d objectForKey:@"word"]];
                }
                i++;
            }
            
            VBFolioQueryOperatorRecords * recsOper = [[VBFolioQueryOperatorRecords alloc] init];
            [recsOper add:0];
            
            
            VBFolioQueryOperator * prevOper = recsOper;
            
            for(int subi = 0; subi < [args count]; subi++)
            {
                VBFolioQueryOperatorContentSubItems * subIt1 = [[VBFolioQueryOperatorContentSubItems alloc] init];
                subIt1.storage = storage;
                subIt1.source = prevOper;
                prevOper = subIt1;
                
                VBFolioQueryOperatorContentItems * cit = [[VBFolioQueryOperatorContentItems alloc] init];
                //[cit autorelease];
                cit.storage = storage;
                cit.simpleText = [(NSString *)[args objectAtIndex:subi] lowercaseString];
                
                VBFolioQueryOperatorAnd * join1 = [[VBFolioQueryOperatorAnd alloc] init];
                [join1.items addObject:cit];
                [join1.items addObject:prevOper];
                prevOper = join1;
                
            }
            
            VBFolioQueryOperatorGetSubRanges * subOper = [[VBFolioQueryOperatorGetSubRanges alloc] init];
            //[subOper autorelease];
            subOper.storage = storage;
            subOper.source = prevOper;
            
            //[args release];
            return subOper;
        }
        
    }
    
    return nil;
}

-(VBFolioQueryOperator *)convertItemToTree:(NSDictionary *)d context:(VBSearchTreeContext *)ctx
{
    if ([[d objectForKey:@"type"] isEqual:@"meta"])
    {
        return [self convertMetaToTree:[d objectForKey:@"array"] context:ctx];
    }
    else if ([[d objectForKey:@"type"] isEqual:@"string"])
    {
        return [self convertQuoteToTree:[d objectForKey:@"array"] context:ctx];
    }
    else if ([[d objectForKey:@"type"] isEqual:@"array"])
    {
        return [self convertArrayToTree:[d objectForKey:@"array"] context:ctx];
    }
    else if ([[d objectForKey:@"type"] isEqual:@"word"])
    {
        NSString * word = [d objectForKey:@"word"];
        if ([word compare:@"and" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return nil;
        return [self convertWordWithDashesToTree:word context:ctx];
    }
    return nil;
}

-(VBFolioQueryOperator *)convertWordWithDashesToTree:(NSString *)wordx context:(VBSearchTreeContext *)ctx
{
    VBHighlightedPhrase * hp = nil;
    if (ctx.quotes)
    {
        hp = [[VBHighlightedPhrase alloc] init];
        [ctx.quotes addObject:hp];
        //[hp release];
    }
    NSRange rangeDash = [wordx rangeOfString:@"-"];
    if (rangeDash.location == NSNotFound)
    {
        [hp addWord:wordx];
        return [self convertWordToTree:wordx context:ctx];
    }
    else
    {
        VBFolioQueryOperatorQuote * vq = [[VBFolioQueryOperatorQuote alloc] init];
        NSArray * parts = [wordx componentsSeparatedByString:@"-"];
        for (NSString * part in parts)
        {
            if (part.length > 0)
            {
                [hp addWord:part];
                [vq.items addObject:[self convertWordToTree:part context:ctx]];
            }
        }
        return vq;
    }
}

-(VBFolioQueryOperator *)convertAndQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx
{
    if ([array count] == 1) {
        return [self convertItemToTree:[array objectAtIndex:0] context:ctx];
    }
    else {
        VBFolioQueryOperatorAnd * van = [[VBFolioQueryOperatorAnd alloc] init];
        for (NSDictionary * d in array)
        {
            VBFolioQueryOperator * newOper = [self convertItemToTree:d context:ctx];
            if (newOper) {
                [van.items addObject:newOper];
            }
        }
        return van;
    }
}

-(VBFolioQueryOperator *)convertOrQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx
{
    VBFolioQueryOperatorOr * van = [[VBFolioQueryOperatorOr alloc] init];
    for (NSDictionary * d in array)
    {
        if ([[d objectForKey:@"type"] isEqual:@"string"])
        {
            [van.items addObject:[self convertQuoteToTree:[d objectForKey:@"array"] context:ctx]];
        }
        else if ([[d objectForKey:@"type"] isEqual:@"array"])
        {
            [van.items addObject:[self convertArrayToTree:[d objectForKey:@"array"] context:ctx]];
        }
        else if ([[d objectForKey:@"type"] isEqual:@"word"])
        {
            NSString * word = [d objectForKey:@"word"];
            [van.items addObject:[self convertWordWithDashesToTree:word context:ctx]];
        }
    }
    
    return van;
}

-(VBFolioQueryOperator *)convertAndNotArrayToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx
{
    BOOL hasNot = NO;
    for (NSDictionary * d1 in array) {
        if ([[d1 objectForKey:@"type"] isEqualToString:@"word"]
            && [[d1 objectForKey:@"word"] compare:@"not" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            hasNot = YES;
        }
    }
    
    if (hasNot == NO)
    {
        return [self convertAndQuoteToTree:array context:ctx];
    }
    else
    {
        NSMutableArray * andArray = [[NSMutableArray alloc] init];
        NSMutableArray * notArray = [[NSMutableArray alloc] init];
        
        BOOL moveToNot = NO;
        for (NSDictionary * d in array)
        {
            if ([[d objectForKey:@"type"] isEqualToString:@"word"] &&
                [[d objectForKey:@"word"] compare:@"not" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                moveToNot = YES;
            }
            else if (moveToNot == YES)
            {
                [notArray addObject:d];
                moveToNot = NO;
            }
            else {
                [andArray addObject:d];
            }
        }
        
        if ([notArray count] > 0)
        {
            VBFolioQueryOperatorNot * vno = [[VBFolioQueryOperatorNot alloc] init];
            vno.partOr = [self convertOrQuoteToTree:notArray context:ctx];
            vno.partAnd = [self convertAndQuoteToTree:andArray context:ctx];
            //[andArray release];
            //[notArray release];
            return vno;
        }
        else
        {
            VBFolioQueryOperator * van = [self convertAndQuoteToTree:andArray context:ctx];
            //[andArray release];
            //[notArray release];
            return van;
        }
    }
    
}

-(VBFolioQueryOperator *)convertArrayToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx
{
    if (array == nil)
        return nil;
    
    BOOL hasOr = NO;
    for (NSDictionary * d1 in array)
    {
        if ([[d1 objectForKey:@"type"] isEqualToString:@"word"])
        {
            if ([[d1 objectForKey:@"word"] compare:@"or" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                hasOr = YES;
                break;
            }
        }
    }
    
    if (hasOr == NO)
    {
        return [self convertAndNotArrayToTree:array context:ctx];
    }
    else
    {
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        NSMutableArray * arr2 = [[NSMutableArray alloc] init];
        [arr1 addObject:arr2];
        //[arr2 release];
        
        for (NSDictionary * d1 in array)
        {
            if ([[d1 objectForKey:@"type"] isEqualToString:@"word"] &&
                [[d1 objectForKey:@"word"] compare:@"or" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                arr2 = [[NSMutableArray alloc] init];
                [arr1 addObject:arr2];
                //[arr2 release];
            }
            else {
                [arr2 addObject:d1];
            }
        }
        
        VBFolioQueryOperatorOr * vor = [[VBFolioQueryOperatorOr alloc] init];
        
        for (NSArray * arr3 in arr1)
        {
            if ([arr3 count] > 0)
            {
                id itemNew = [self convertAndNotArrayToTree:arr3 context:ctx];
                if (itemNew != nil)
                    [vor.items addObject:itemNew];
            }
        }
        
        //[arr1 release];
        
        return vor;
    }
}



+(VDTreeItem *)dumpQueryTree:(VBFolioQueryOperator *)oper
{
    if (oper == nil)
        return nil;
    
    
    VDTreeItem * item = [VDTreeItem new];
    
    NSArray * children = nil;
    
    item.title = [oper description];
    item.count = [NSString stringWithFormat:@"%ld", (long)oper.hitCount];
    
    if ([oper class] == [VBFolioQueryOperatorAnd class])
    {
        VBFolioQueryOperatorAnd * o2 = (VBFolioQueryOperatorAnd *)oper;
        children = o2.items;
    } else if ([oper class] == [VBFolioQueryOperatorContentSubItems class])
    {
        VBFolioQueryOperatorContentSubItems * o2 = (VBFolioQueryOperatorContentSubItems *)oper;
        children = [NSArray arrayWithObject:o2.source];
    }
    else if ([oper class] == [VBFolioQueryOperatorGetSubRanges class])
    {
        VBFolioQueryOperatorGetSubRanges * o2 = (VBFolioQueryOperatorGetSubRanges *)oper;
        children = [NSArray arrayWithObject:o2.source];
    }
    else if ([oper class] == [VBFolioQueryOperatorOr class])
    {
        VBFolioQueryOperatorOr * o2 = (VBFolioQueryOperatorOr *)oper;
        children = o2.items;
    }
    else if ([oper class] == [VBFolioQueryOperatorNot class])
    {
        VBFolioQueryOperatorNot * o2 = (VBFolioQueryOperatorNot *)oper;
        children = [NSArray arrayWithObjects:o2.partAnd, o2.partOr, nil];
    }
    else if ([oper class] == [VBFolioQueryOperatorQuote class])
    {
        VBFolioQueryOperatorQuote * o2 = (VBFolioQueryOperatorQuote *)oper;
        children = o2.items;
    }
    
    if (children != nil)
    {
        for (VBFolioQueryOperator * oper in children)
        {
            if (oper != nil)
            {
                VDTreeItem * sub = [self dumpQueryTree:oper];
                if (sub) {
                    [item.children addObject:sub];
                }
            }
        }
    }
    
    return item;
}

+(UIImage *)createImageFromQuery:(VBFolioQueryOperator *)oper
{
    VDTreeItem * item = [VBFolioQuery dumpQueryTree:oper];
    
    UIImage * image;
    UIFont * font = [UIFont systemFontOfSize:20];
    CGRect currentRect = CGRectZero;
    NSDictionary * fontAttr = @{NSFontAttributeName: font};
    [item getEndpointWithFont:fontAttr lastEndpoint:&currentRect];
    
    NSDictionary * titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    NSDictionary * countAttr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
    NSDictionary * styles = [NSDictionary dictionaryWithObjectsAndKeys:titleAttr, @"title", countAttr, @"count", nil];
    
    currentRect.size.width += 10;
    currentRect.size.height += 10;
    
    UIGraphicsBeginImageContext(currentRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [item draw:context styles:styles];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

