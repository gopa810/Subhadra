//
//  FDRecordBase.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDRecordBase.h"
#import "FDCharFormat.h"
#import "FDRecordPart.h"
#import "FDParagraph.h"
#import "FDParaFormat.h"
#import "FDTableCell.h"
#import "FDTable.h"
#import "FDRecordLocation.h"
#import "FDPartBase.h"
#import "FDPartString.h"
#import "FDPartSpace.h"
#import "VBMainServant.h"

@implementation FDRecordBase

-(id)init
{
    self = [super init];
    if (self) {
        _noteIcon = NO;
        _recordId = 0;
        self.parts = [[NSMutableArray alloc] init];
        _calculatedHeight = 1;
        _calculatedWidth = -1;
        _calculatedMultiplyFontSize = -1;
        _calculatedMultiplyLineSize = -1;
        _requestedAlign = 1;
        _linkedRecordId = -1;
    }
    return self;
}


+(CGFloat)loadingRecordHeight
{
    return 240;
}

//
// if arrayRecordId is set to > 0,
// then this value is returned
// if set to <0, then value of recordId is returned
//
-(int)linkedRecordId
{
    if (_linkedRecordId < 0)
        return _recordId;
    return _linkedRecordId;
}

-(FDRecordBase *)lightCopy
{
    FDRecordBase * cop = [FDRecordBase new];
    
    cop.recordId = self.recordId;
    cop.noteIcon = self.noteIcon;
    cop.calculatedWidth = self.calculatedWidth;
    cop.linkedRecordId = self.linkedRecordId;
    cop.calculatedHeight = self.calculatedHeight;
    cop.calculatedMultiplyFontSize = self.calculatedMultiplyFontSize;
    cop.calculatedMultiplyLineSize = self.calculatedMultiplyLineSize;
    cop.levelName = self.levelName;
    cop.namedPopup = self.namedPopup;
    cop.parts = self.parts;
    cop.plainText = self.plainText;
    cop.recordId = self.recordId;
    cop.recordMark = self.recordMark;
    cop.requestedAlign = self.requestedAlign;
    
    return cop;
}

/*
 * returns height of this record
 * makes new calculation only if width changed
 */
-(CGFloat)validateForWidth:(CGFloat)width {
    
    if (self.loading)
        return [FDRecordBase loadingRecordHeight];
    
    if (self.calculatedWidth != width || self.calculatedMultiplyFontSize != [FDCharFormat multiplyFontSize]
        || self.calculatedMultiplyLineSize != [FDCharFormat multiplySpaces]) {
        self.calculatedHeight = 1;

        if (self.recordMark != nil) {
            
            CGSize markSize = [self.recordMark sizeWithAttributes:[VBMainServant instance].drawer.recordMarkAttributes];
            self.calculatedHeight += markSize.height + 8;
        }
        
        for(FDRecordPart * part in self.parts) {
            part.calculatedHeight = [part validateForWidth:width];
            self.calculatedHeight += part.calculatedHeight;
            //NSLog(@"drawy   sub height = %f", self.calculatedHeight);
        }
        
        self.calculatedWidth = width;
        self.calculatedMultiplyFontSize = [FDCharFormat multiplyFontSize];
        self.calculatedMultiplyLineSize = [FDCharFormat multiplySpaces];
    }
    return self.calculatedHeight;
}

-(void)setNeedsRecalculate
{
    self.calculatedWidth = 0;
    [self.recordView setNeedsDisplay];
}

-(void)addElement:(FDPartBase *)sp {
    
    FDParagraph * para = [self getLastSafeParagraph];
    
    if (para != nil) {
        [para.parts addObject:sp];
        para.layoutWidth = 0;
    }
}

-(void)setParaFormatting:(FDParaFormat *)aFormat {
    FDParagraph * para = [self getLastSafeParagraph];
    
    if (para != nil) {
        [para.paraFormat copyFrom:aFormat];
    }
}

-(FDParagraph *)getLastSafeParagraph {
    
    FDRecordPart * part = [self getCurrentPart];
    FDParagraph * para = nil;
    
    if ([part isKindOfClass:[FDParagraph class]]) {
        para = (FDParagraph *)part;
        
    } else if ([part isKindOfClass:[FDTable class]]) {
        FDTableCell * cell = [(FDTable *)part getSafeLastCell];
        if (cell != nil) {
            para = [cell getLastSafeParagraph];
        }
    }
    
    return para;
}

/*
 * returns last paragraph part in the list.
 * If not existing, it creates new one.
 */
-(FDRecordPart *)getCurrentPart {
    if ([self.parts count] == 0) {
        FDRecordPart * part = [[FDParagraph alloc] init];
        [self.parts addObject:part];
        return part;
    }
    return [self.parts lastObject];
}

-(id)getLastPart {
    return [self.parts lastObject];
}

-(BOOL)testHit:(FDRecordLocation *)hr paddingLeft:(CGFloat)paddingLeft
  paddingRight:(CGFloat)paddingRight
{
    
    for(FDRecordPart * part in self.parts) {
        //Log.i("ClickEvent", "hr(x,y): " + hr.x + "," + hr.y);
        //Log.i("ClickEvent", "part(top,bottom): " + part.absoluteTop + "," + part.absoluteBottom);
        if (part.absoluteTop <= hr.y && part.absoluteBottom > hr.y) {
            hr.record = self;
            hr.partNum = part.orderNo;
            
            [part testHit:hr padding:paddingLeft];
            if (hr.x < paddingLeft) {
                hr.areaType = [FDRecordLocation AREA_LEFT_SIDE];
                hr.selectedRect = CGRectMake(0, part.absoluteTop, paddingLeft, part.absoluteBottom - part.absoluteTop);
            } else if (hr.x > part.absoluteRight) {
                hr.areaType = FDRecordLocation.AREA_RIGHT_SIDE;
                hr.selectedRect = CGRectMake(part.absoluteRight, part.absoluteTop, paddingRight, part.absoluteBottom - part.absoluteTop);
            }
            [hr.path insertObject:part atIndex:0];
            return YES;
        }
    }
    return NO;
}

-(void)clearSelection
{
    for(FDRecordPart * part in self.parts)
    {
        [part clearSelection];
    }
}

-(void)selectPartsAroundHighlighting
{
    //NSLog(@"== shinked record: %d (%ld parts)", self.recordId, (unsigned long)self.parts.count);
    FDPartBase * pb;
    NSInteger around = 18;
    for (FDRecordPart * part in self.parts)
    {
        NSInteger partsCount = (NSInteger)[part.parts count];
        NSInteger level = 0;
        NSInteger count12 = partsCount - around;
        for (NSInteger i = -around; i < count12; i++)
        {
            pb = [part.parts objectAtIndex:(i + around)];
            if (pb.highlighted)
                level = around*2 + 1;
            if (i >= 0) {
                pb = [part.parts objectAtIndex:i];
                if ([pb isKindOfClass:[FDPartString class]])
                {
                    //NSLog(@"      levelA %ld, part %@", level, [(FDPartString *)pb text]);
                }
                pb.selected = NO;
                if (level > 0)
                {
                    pb.selected = YES;
                    level --;
                }
            } else if (level > 0) {
                //NSLog(@"      levelA %ld", level);
                level --;
            }
        }
        for (NSInteger i = count12; i < partsCount; i++)
        {
            if (i >= 0) {
                pb = [part.parts objectAtIndex:i];
                pb.selected = NO;
                if (level > 0)
                {
                    pb.selected = YES;
                    level --;
                }
                if ([pb isKindOfClass:[FDPartString class]])
                {
                    //NSLog(@"      levelB %ld, part %@", level, [(FDPartString *)pb text]);
                }
            } else if (level > 0) {
                //NSLog(@"      levelB %ld", level);
                level --;
            }
        }
        
    }
}

-(void)shrinkSelectedParts
{
    for (FDRecordPart * part in self.parts)
    {
        int mode = 0;
        NSInteger i = 0;
        while (i < part.parts.count) {
            FDPartBase * pb = [part.parts objectAtIndex:i];
            if (pb.selected == NO)
            {
                if (mode == 0)
                {
                    FDPartString * ps = [[FDPartString alloc] init];
                    ps.text = @" ... ";
                    if ([pb isKindOfClass:[FDPartString class]]) {
                        FDPartString * ppa = (FDPartString *)pb;
                        ps.format = ppa.format;
                        ps.typeface = ppa.typeface;
                    } else if ([pb isKindOfClass:[FDPartSpace class]]) {
                        FDPartSpace * ppc = (FDPartSpace *)pb;
                        ps.format = ppc.format;
                        ps.typeface = ppc.typeface;
                    }
                    [part.parts insertObject:ps atIndex:i];
                    i++;
                    mode = 1;
                }
                else if (mode == 1)
                {
                    [part.parts removeObjectAtIndex:i];
                }
            }
            else {
                i++;
                mode = 0;
                pb.selected = NO;
            }
        }
    }
}


@end
