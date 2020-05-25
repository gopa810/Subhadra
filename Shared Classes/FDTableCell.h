//
//  FDTableCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@class FDParagraph, FDRecordPart, FDTable, FDTableRow, Canvas;

@interface FDTableCell : NSObject


@property BOOL closed;
@property NSMutableArray * parts;
@property CGFloat calculatedHeight;
@property CGFloat calculatedMaxWidth;
@property CGFloat calculatedMinWidth;

-(FDParagraph *)getLastSafeParagraph;
-(FDRecordPart *)getLastSafePart;
-(void)calculateWidthMax:(CGFloat)maxWidth;
-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart;

@end
