//
//  FDTable.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDRecordPart.h"

@class FDTableCell, FDTableRow, FDTableLayout;

@interface FDTable : FDRecordPart


@property BOOL closed;
@property NSMutableArray * rows;
@property NSMutableArray * columnWidths;
@property NSArray * calculatedMinColumnWidths;
@property NSArray * calculatedMaxColumnWidths;
@property NSArray * finalColumnWidths;
@property NSArray * finalRowHeights;


-(void)addRow:(FDTableRow *)row;
-(FDTableRow *)getLastRow;
-(FDTableRow *)getSafeLastRow;
-(void)addCell:(FDTableCell *)cell;
-(FDTableCell *)getLastCell;
-(FDTableCell *)getSafeLastCell;


@end
