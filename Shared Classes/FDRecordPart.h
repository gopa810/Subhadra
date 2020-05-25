//
//  FDRecordPart.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "EndlessTextViewSkinDelegate.h"

@class FDParaFormat;
@class VBHighlighterAnchor;
@class FDRecordLocation;
@class FDRecordLocationPair;
@class Canvas, FDTextHighlighter;
@class FDHighlightTracker,VBHighlightedPhraseSet;

@interface FDRecordPart : NSObject

@property FDParaFormat * paraFormat;
@property NSMutableArray * parts;
@property CGFloat absoluteTop;
@property CGFloat absoluteBottom;
@property CGFloat absoluteRight;
@property int orderNo;
@property int selected;
@property (strong) UIImage * imageShot;
@property BOOL imageCalculated;
@property CGFloat calculatedHeight;
@property CGFloat calculatedMaxWidth;
@property CGFloat calculatedMinWidth;
@property BOOL evaluateHighlightedWords;
@property id<EndlessTextViewSkinDelegate> delegate;

-(CGFloat)validateForWidth:(CGFloat)width;
-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart;
-(void)testHit:(FDRecordLocation *)hr padding:(CGFloat)paddingLeft;
-(void)getSelectedText:(NSMutableString *)sb;
-(BOOL)hasSelection;
-(int)characterLength;
-(int)selectionStartIndex;
-(int)selectionEndIndex;
-(void)clearSelection;
-(void)evaluateHighlighting:(FDTextHighlighter *)phrases;

@end
