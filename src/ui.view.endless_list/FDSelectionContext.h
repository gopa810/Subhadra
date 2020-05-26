//
//  FDSelectionContext.h
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import <Foundation/Foundation.h>
#import "FDRecordLocation.h"

@interface FDSelectionContext : NSObject

@property FDRecordLocationPair * selectionPoints;
@property FDRecordLocationPair * orderedPoints;
@property int currentRecordLeftHighlighter;
@property int currentRecordRightHighlighter;
@property int currentSelectionPoint;

@property CGPoint hotSpotA;
@property CGPoint hotSpotB;


-(BOOL)getSelectedRangeOfTextStartRec:(int *)pFromGlobRecId
                           startIndex:(int *)pStartIndex
                               endRec:(int *)pToGlobRecId
                             endIndex:(int *)pEndIndex;
-(int)testHitSelectionPoint:(CGPoint)pt;
-(int)determineSelectionStatusFor:(FDRecordLocationBase *)curr start:(FDRecordLocationBase *)start end:(FDRecordLocationBase *)end;
-(BOOL)sortSelectionPoints;
-(void)applySelectionToRecord:(FDRecordBase *)record;

@end
