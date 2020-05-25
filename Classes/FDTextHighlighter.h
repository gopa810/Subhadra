//
//  FDTextHighlighter.h
//  VedabaseB
//
//  Created by Peter Kollath on 18/09/14.
//
//

#import <Foundation/Foundation.h>
@class VBHighlightedPhraseSet;
@class FDPartBase, FDPartString;

@interface FDTextHighlighter : NSObject

@property NSMutableArray * phrases;


-(id)initWithPhraseSet:(VBHighlightedPhraseSet *)phraseSet;
-(void)reset;

@end


@interface FDTextHighlightPhrase : NSObject

@property NSMutableArray * words;
@property int currentIndex;

-(BOOL)testPart:(FDPartString *)ps;
-(BOOL)isCompleteMatch;
-(void)highlightParts;
-(void)reset;
@end


@interface FDTextHighlightWord : NSObject

@property NSPredicate * predicate;
@property FDPartBase * part;


@end


