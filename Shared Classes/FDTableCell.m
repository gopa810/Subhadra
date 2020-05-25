//
//  FDTableCell.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDTableCell.h"
#import "FDRecordPart.h"
#import "FDParagraph.h"
#import "FDTable.h"

@implementation FDTableCell


-(id)init
{
	self = [super init];
	if (self) {
		self.parts = [[NSMutableArray alloc] init];
	}
	return self;
}


-(FDParagraph *)getLastSafeParagraph
{
	FDRecordPart * part = [self getLastSafePart];
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

-(FDRecordPart *)getLastSafePart {
	if ([self.parts count] == 0) {
		FDRecordPart * part = [[FDParagraph alloc] init];
		[self.parts addObject:part];
		return part;
	}
	return [self.parts objectAtIndex:([self.parts count] - 1)];
}


-(void)calculateWidthMax:(CGFloat)maxWidth
{
    CGFloat sum = 0;
    CGFloat maxw = 0;
    CGFloat minw = 0;
    for (FDRecordPart * part in self.parts) {
        CGFloat height = [part validateForWidth:maxWidth];
        sum += height;
        maxw = MAX(maxw, part.calculatedMaxWidth);
        minw = MAX(minw, part.calculatedMinWidth);
    }
    
    self.calculatedHeight = sum;
    self.calculatedMaxWidth = maxw;
    self.calculatedMinWidth = minw;
    
}

-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart
{
    CGFloat p = yStart;
//    [@"AAA" drawAtPoint:CGPointMake(xStart, yStart) withFont:[UIFont systemFontOfSize:20]];
    for (FDRecordPart * part in self.parts) {
        p += [part drawWithCanvas:canvas xstart:xStart ystart:p];
        
    }
    return p;
}

@end
