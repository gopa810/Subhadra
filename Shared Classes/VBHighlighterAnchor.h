//
//  VBHighlighterAnchor.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import <Foundation/Foundation.h>

@interface VBHighlighterAnchor : NSObject
{
    int p_char;
    int p_id;
}

@property (assign) int startChar;
@property (assign) int highlighterId;


-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;
+(int)getColor:(int)highlighterId;

@end
