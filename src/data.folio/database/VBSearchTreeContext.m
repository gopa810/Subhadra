//
//  VBSearchTreeContext.m
//  VedabaseB
//
//  Created by Peter Kollath on 26/07/14.
//
//

#import "VBSearchTreeContext.h"

@implementation VBSearchTreeContext

-(id)initWithContext:(VBSearchTreeContext *)context
{
    if ((self = [super init]) != nil)
    {
        self.quotes = context.quotes;
        self.wordsDomain = context.wordsDomain;
        self.exactWords = context.exactWords;
    }

    return self;
}



@end
