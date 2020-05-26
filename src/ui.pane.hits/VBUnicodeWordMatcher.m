//
//  VBUnicodeWordMatcher.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import "VBUnicodeWordMatcher.h"

@implementation VBUnicodeWordMatchThread

-(id)initWithWord:(NSString *)str
{
    self = [super init];
    if (self)
    {
        self.compareMode = CompareModeNormal;
        self.partIndex = 0;
        self.word = str;
        self.activeThread = YES;
    }
    return self;
}


-(unichar)currentChar
{
    if (self.currIndex >= self.word.length)
        return 32;
    return [self.word characterAtIndex:self.currIndex];
}

-(int)checkWildCard
{
    if ([self matchingIsOver])
        return CompareModeRequiredEnd;
    
    unichar uc = [self currentChar];
    
    if (uc != '*' && uc != '%')
    {
        if (self.currIndex == 0)
            return CompareModeWaitStartWord;
        return CompareModeNormal;
    }
    
    while(![self matchingIsOver] && (uc == '*' || uc == '%'))
    {
        self.currIndex = self.currIndex + 1;
        uc = [self currentChar];
    }
    self.partIndex = self.currIndex;
    
    if ([self matchingIsOver])
        return CompareModeWaitForEnd;
    
    return CompareModeWild;
}

-(BOOL)matchingIsOver
{
    return self.currIndex >= self.word.length;
}

@end


@implementation VBUnicodeWordMatcher

-(id)init
{
    self = [super init];
    if (self)
    {
        self.startIndex = NSNotFound;
        _threads = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)sendChar:(unichar)chr atIndex:(int)index
{
    BOOL retValue = NO;
    self.lastIndex = index;

    if (self.startIndex == NSNotFound && chr != 32)
    {
        self.startIndex = index;
    }
    
    if (self.threads.count == 0)
    {
        VBUnicodeWordMatchThread * thread = [[VBUnicodeWordMatchThread alloc] initWithWord:self.word];
        [self.threads addObject:thread];
        thread.compareMode = [thread checkWildCard];
        //[thread release];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    BOOL breakLoop = NO;
    BOOL clearStart = NO;
    for (VBUnicodeWordMatchThread * thread in self.threads)
    {
        if (thread.activeThread == NO)
            continue;
        unichar cc = [thread currentChar];
        switch (thread.compareMode)
        {
            case CompareModeRequiredStart:
                if (chr == 32)
                {
                    thread.compareMode = CompareModeWaitStartWord;
                    clearStart = YES;
                }
                break;
            case CompareModeWaitStartWord:
                if (chr == 32)
                {
                }
                else if (chr == cc || cc=='?')
                {
                    thread.currIndex = thread.currIndex + 1;
                    thread.compareMode = [thread checkWildCard];
                    thread.compareMode = CompareModeNormal;
                }
                else
                {
                    thread.compareMode = CompareModeRequiredStart;
                }
                break;
            case CompareModeNormal:
            case CompareModeWild:
                if (chr == 32)
                {
                    if ([thread matchingIsOver])
                    {
                        self.startFindRange = self.startIndex;
                        self.lastFindIndex = self.lastIndex;
                        retValue = YES;
                        breakLoop = YES;
                        break;
                    }
                    else
                    {
                        if (thread.compareMode == CompareModeWild)
                        {
                            thread.activeThread = NO;
                        }
                        else
                        {
                            thread.currIndex = 0;
                            thread.compareMode = [thread checkWildCard];
                        }
                    }
                    clearStart = YES;
                }
                else if (chr == cc || cc=='?')
                {
                    if (thread.compareMode == CompareModeWild)
                    {
                        VBUnicodeWordMatchThread * nt = [[VBUnicodeWordMatchThread alloc] initWithWord:thread.word];
                        [arr addObject:nt];
                        nt.currIndex = thread.currIndex;
                        nt.partIndex = thread.partIndex;
                        nt.compareMode = thread.compareMode;
                        //[nt release];
                    }
                    thread.currIndex = thread.currIndex + 1;
                    thread.compareMode = [thread checkWildCard];
                }
                else
                {
                    thread.currIndex = thread.partIndex;
                }
                break;
            case CompareModeWaitForEnd:
                if (chr == 32)
                {
                    self.startFindRange = self.startIndex;
                    self.lastFindIndex = self.lastIndex;
                    retValue = YES;
                    breakLoop = YES;
                    break;
                }
                break;
            case CompareModeRequiredEnd:
                if (chr == 32)
                {
                    self.startFindRange = self.startIndex;
                    self.lastFindIndex = self.lastIndex;
                    retValue = YES;
                    breakLoop = YES;
                    break;
                }
                else
                {
                    thread.currIndex = thread.partIndex;
                    thread.compareMode = CompareModeRequiredStart;
                }
                break;
        }
        if (breakLoop)
            break;
    }
    
    if (clearStart)
        self.startIndex = NSNotFound;

    [self.threads addObjectsFromArray:arr];
    [arr removeAllObjects];


    for(VBUnicodeWordMatchThread * thr in self.threads)
    {
        if (thr.activeThread)
        {
            [arr addObject:thr];
        }
    }
    [self.threads removeAllObjects];
    [self.threads addObjectsFromArray:arr];
    [arr removeAllObjects];

    //[arr release];
    return retValue;
}




-(NSRange)range
{
    return NSMakeRange(self.startIndex, self.lastIndex - self.startIndex);
}

@end
