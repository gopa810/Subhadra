//
//  VBFolioQueryOperator.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import "VBFolioQueryOperator.h"

@implementation VBFolioQueryOperator

-(id)init
{
    self = [super init];
    if (self)
    {
        _valid = NO;
        _eof = NO;
    }
    
    return self;
}

-(uint32_t)currentRecord
{
    return 0;
}


-(BOOL)gotoNextRecord
{
    return _eof;
}

-(void)validate
{
    if (_eof)
        return;
}

-(BOOL)endOfStream
{
    return _eof;
}

-(void)setEndOfStream:(BOOL)val
{
    _eof = val;
}


-(BOOL)valid
{
    return _valid;
}

-(BOOL)moveToRecord:(uint32_t)rec
{
    int32_t curr = 0;
    
    
    if (_eof)
        return NO;
    
    curr = [self currentRecord];
    while (curr < rec)
    {
        if ([self gotoNextRecord] == NO)
        {
            _eof = YES;
            return NO;
        }
        curr = [self currentRecord];
    }
    
    return YES;
}

-(uint16_t)currentProximity
{
    return 0;
}

-(BOOL)gotoNextProximity
{
    return YES;
}

-(void)printSpaces:(int)level toString:(NSMutableString *)target
{
    for(int i = 0; i < level; i++)
    {
        [target appendString:@"  "];
    }
}

-(void)printAtLevel:(int)level toString:(NSMutableString *)target
{
    [self printSpaces:level toString:target];
    [target appendString:@"Query\n"];
}

-(void)gotoLastRecord
{
}


@end

