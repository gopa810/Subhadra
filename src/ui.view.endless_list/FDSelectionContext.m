//
//  FDSelectionContext.m
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import "FDSelectionContext.h"
#import "FDRecordBase.h"
#import "FDRecordPart.h"
#import "FDPartBase.h"
#import "FDSelection.h"

@implementation FDSelectionContext

-(id)init
{
    self = [super init];
    if (self) {
        self.currentRecordLeftHighlighter = -1;
        self.currentRecordRightHighlighter = -1;
        self.currentSelectionPoint = -1;
        self.selectionPoints = [FDRecordLocationPair new];
        self.orderedPoints = [FDRecordLocationPair new];
        self.selectionPoints.A = [FDRecordLocation new];
        self.selectionPoints.B = [FDRecordLocation new];
        self.selectionPoints.A.recNum = -1;
        self.selectionPoints.B.recNum = -1;
        self.orderedPoints.A = self.selectionPoints.A;
        self.orderedPoints.B = self.selectionPoints.B;
    }
    return self;
}


-(BOOL)getSelectedRangeOfTextStartRec:(int *)pFromGlobRecId
                           startIndex:(int *)pStartIndex
                               endRec:(int *)pToGlobRecId
                             endIndex:(int *)pEndIndex
{
    if (self.orderedPoints.A != nil && self.orderedPoints.B != nil) {
        
        
        if (self.orderedPoints.A.record.recordId == self.orderedPoints.B.record.recordId)
        {
            FDRecordBase * rd = self.orderedPoints.A.record;
            *pFromGlobRecId = self.orderedPoints.A.record.recordId;
            *pToGlobRecId = rd.recordId;
            
            int charIndex = 0;
            BOOL startFound = NO;
            
            for(FDRecordPart * part in rd.parts) {
                
                if ([part hasSelection])
                {
                    *pEndIndex = charIndex + [part selectionEndIndex];
                    if (!startFound)
                    {
                        *pStartIndex = charIndex + [part selectionStartIndex];
                        startFound = YES;
                    }
                }
                charIndex += [part characterLength];
            }
            
        }
        else
        {
            FDRecordBase * rd = self.orderedPoints.A.record;
            *pFromGlobRecId = rd.recordId;
            int charIndex = 0;
            for(FDRecordPart * part in rd.parts)
            {
                if ([part hasSelection])
                {
                    *pStartIndex = charIndex + [part selectionStartIndex];
                    break;
                }
                charIndex += [part characterLength];
            }
            
            rd = self.orderedPoints.B.record;
            *pToGlobRecId = rd.recordId;
            charIndex = 0;
            for(FDRecordPart * part in rd.parts)
            {
                if ([part hasSelection])
                {
                    *pEndIndex = charIndex + [part selectionEndIndex];
                }
                charIndex += [part characterLength];
            }
        }
        
        return YES;
    }
    
    return NO;
}

#define MAXDIST 30

-(int)testHitSelectionPoint:(CGPoint)pt
{
    float dist1 = 1000;
    float dist2 = 1000;
    
    self.currentSelectionPoint = -1;
    
    if (self.selectionPoints.A != nil) {
        dist1 = fabs(pt.x - self.selectionPoints.A.hotSpot.x) + fabs(pt.y - self.selectionPoints.A.hotSpot.y);
        //NSLog(@"ClickEvent dist 1 = %f", dist1);
    }
    
    if (self.selectionPoints.B != nil && self.currentSelectionPoint < 0) {
        dist2 = fabs(pt.x - self.selectionPoints.B.hotSpot.x) + fabs(pt.y - self.selectionPoints.B.hotSpot.y);
        //NSLog(@"ClickEvent dist 2 = %f", dist2);
    }
    if (dist1 < MAXDIST) {
        if (dist2 < MAXDIST) {
            if (dist1 < dist2) {
                self.currentSelectionPoint = 0;
            } else {
                self.currentSelectionPoint = 1;
            }
            
        } else {
            self.currentSelectionPoint = 0;
        }
    } else if (dist2 < MAXDIST) {
        self.currentSelectionPoint = 1;
    }
    
    return self.currentSelectionPoint;
}

-(int)determineSelectionStatusFor:(FDRecordLocationBase *)curr start:(FDRecordLocationBase *)start end:(FDRecordLocationBase *)end
{
    int selA = FDSELECTION_NONE;
    int selB = FDSELECTION_NONE;
    
    if (start == nil || end == nil)
        return FDSELECTION_NONE;
    
    if (curr.recNum == start.recNum)
    {
        if (curr.partNum == start.partNum)
        {
            if (curr.cellNum == start.cellNum)
            {
                selA = FDSELECTION_FIRST;
            }
            else if (curr.cellNum > start.cellNum)
            {
                selA = FDSELECTION_MIDDLE;
            }
        }
        else if (curr.partNum > start.partNum)
        {
            selA = FDSELECTION_MIDDLE;
        }
    }
    else if (curr.recNum > start.recNum)
    {
        selA = FDSELECTION_MIDDLE;
    }
    
    if (curr.recNum < end.recNum)
    {
        selB = FDSELECTION_MIDDLE;
    }
    else if (curr.recNum == end.recNum)
    {
        if (curr.partNum < end.partNum)
        {
            selB = FDSELECTION_MIDDLE;
        }
        else if (curr.partNum == end.partNum)
        {
            if (curr.cellNum < end.cellNum)
            {
                selB = FDSELECTION_MIDDLE;
            }
            else if (curr.cellNum == end.cellNum)
            {
                selB = FDSELECTION_LAST;
            }
        }
    }
    
    if (selA == FDSELECTION_NONE || selB == FDSELECTION_NONE)
        return FDSELECTION_NONE;
    
    if (selA == FDSELECTION_MIDDLE && selB == FDSELECTION_MIDDLE)
        return FDSELECTION_MIDDLE;
    
    if (selA == FDSELECTION_FIRST)
    {
        if (selB == FDSELECTION_LAST)
        {
            return FDSELECTION_FIRST | FDSELECTION_LAST;
        }
        else
        {
            return FDSELECTION_FIRST;
        }
    }
    else if (selB == FDSELECTION_LAST)
    {
        return FDSELECTION_LAST;
    }
    
    return FDSELECTION_NONE;
}

-(BOOL)sortSelectionPoints
{
    BOOL oneParaSel;
    if (self.selectionPoints.A.record.recordId == self.selectionPoints.B.record.recordId) {
        // we are in 1 record and both are paragraphs
        if (self.selectionPoints.A.partNum == self.selectionPoints.B.partNum) {
            oneParaSel = YES;
            // sorting within 1 para
            if (self.selectionPoints.A.cellNum > self.selectionPoints.B.cellNum) {
                [self sortSelectionReverseOrder];
            } else {
                [self sortSelectionNormalOrder];
            }
        } else {
            // different parts, we have to select whole parts
            oneParaSel = false;
            if (self.selectionPoints.A.partNum > self.selectionPoints.B.partNum) {
                [self sortSelectionReverseOrder];
            } else {
                [self sortSelectionNormalOrder];
            }
        }
    } else {
        oneParaSel = false;
        if (self.selectionPoints.A.record.recordId > self.selectionPoints.B.record.recordId)
        {
            [self sortSelectionReverseOrder];
        } else {
            [self sortSelectionNormalOrder];
        }
    }
    
    return oneParaSel;
}

-(void)sortSelectionNormalOrder
{
    self.orderedPoints.A = self.selectionPoints.A;
    self.orderedPoints.B = self.selectionPoints.B;
}

-(void)sortSelectionReverseOrder
{
    self.orderedPoints.A = self.selectionPoints.B;
    self.orderedPoints.B = self.selectionPoints.A;
}

-(void)applySelectionToRecord:(FDRecordBase *)record
{
    FDRecordLocationBase * currPos = [FDRecordLocationBase new];
    
    currPos.recNum = record.recordId;
    currPos.partNum = 0;
    currPos.cellNum = 0;
    for(FDRecordPart * part in record.parts) {
        part.selected = FDSELECTION_NONE;
        for(FDPartBase * pbase in part.parts)
        {
            pbase.selected = [self determineSelectionStatusFor:currPos start:self.orderedPoints.A end:self.orderedPoints.B];
            currPos.cellNum = currPos.cellNum + 1;
        }
        
        currPos.partNum = currPos.partNum + 1;
    }
    [record.recordView setNeedsDisplay];
}

@end
