//
//  VBHighlighterAnchor.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "VBHighlighterAnchor.h"

static int binColors[] = {
    0xffffff00,
    0xff00ff00,
    0xff00ffff,
    0xffff0000,
    0xffff00ff,
    0xffff6600,
    0xffff6699,
    0xff6666ff,
    0xff7f7fff,
    0xffff7f7f
};

@implementation VBHighlighterAnchor
@synthesize highlighterId;
@synthesize startChar;


-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSNumber numberWithInt:self.startChar] forKey:@"startChar"];
    [dict setValue:[NSNumber numberWithInt:self.highlighterId] forKey:@"highlighterId"];
    
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    self.startChar = [[obj valueForKey:@"startChar"] intValue];
    self.highlighterId = [[obj valueForKey:@"highlighterId"] intValue];
}

+(int)getColor:(int)highlighterId
{
    return binColors[highlighterId];
}



@end
