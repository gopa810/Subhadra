//
//  FDRecordPart.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDRecordPart.h"
#import "FDParaFormat.h"
#import "FDSelection.h"
#import "FDPartBase.h"
#import "FDRecordLocation.h"
#import "FDHighlightTracker.h"

@class VBHighlightedPhraseSet;

@implementation FDRecordPart


-(id)init
{
    self = [super init];
    if (self) {
        self.paraFormat = [[FDParaFormat alloc] init];
        self.parts = [[NSMutableArray alloc] init];
        _absoluteTop = 0;
        _absoluteBottom = 0;
        _orderNo = 0;
        _calculatedMaxWidth = 0;
        _calculatedMinWidth = 0;
        _selected = [FDSelection None];
    }
    return self;
}

-(CGFloat)validateForWidth:(CGFloat)width
{
    return 1.0;
}

-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart
{
    return yStart;
}

-(void)testHit:(FDRecordLocation *)hr padding:(CGFloat)paddingLeft
{
}

-(void)getSelectedText:(NSMutableString *)sb
{
}

-(void)evaluateHighlighting:(FDTextHighlighter *)phrases
{
    for(FDPartBase * pp in self.parts)
    {
        pp.highlighted = NO;
    }
}

-(BOOL)hasSelection
{
    if (_selected != [FDSelection None])
        return YES;
    
    for (FDPartBase * part in self.parts) {
        if (part.selected != [FDSelection None])
            return YES;
    }
    
    return NO;
}

-(int)characterLength
{
    return 1;
}

-(int)selectionStartIndex
{
    return 0;
}

-(int)selectionEndIndex
{
    return 0;
}

-(void)clearSelection
{
    self.selected = [FDSelection None];
    for (FDPartBase * part in self.parts) {
        part.selected = [FDSelection None];
    }
}

@end
