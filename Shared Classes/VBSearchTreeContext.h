//
//  VBSearchTreeContext.h
//  VedabaseB
//
//  Created by Peter Kollath on 26/07/14.
//
//

#import <Foundation/Foundation.h>

@class VBHighlightedPhraseSet;

@interface VBSearchTreeContext : NSObject

    @property VBHighlightedPhraseSet * quotes;
    @property NSString * wordsDomain;
    @property BOOL exactWords;

    -(id)initWithContext:(VBSearchTreeContext *)context;

@end

