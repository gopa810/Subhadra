//
//  FDTable.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDTable.h"
#import "FDTableCell.h"
#import "FDTableRow.h"

@implementation FDTable


-(id)init
{
	self = [super init];
	if (self) {
		self.rows = [[NSMutableArray alloc] init];
        self.columnWidths = [NSMutableArray new];
	}
	return self;
}

#pragma mark -
#pragma mark Constructing a Table

-(void)addRow:(FDTableRow *)row
{
	[self.rows addObject:row];
}

-(FDTableRow *)getLastRow
{
	return [self.rows lastObject];
}

-(FDTableRow *)getSafeLastRow
{
	FDTableRow * row = [self getLastRow];
	
	if (!row) {
		row = [[FDTableRow alloc] init];
		[self addRow:row];
	}
	
	return row;
}

-(void)addCell:(FDTableCell *)cell
{
	FDTableRow * row = [self getSafeLastRow];
	
	if (row) {
		[row addCell:cell];
	}
}

-(FDTableCell *)getLastCell
{
	FDTableRow * row = [self getLastRow];
	FDTableCell * cell = nil;
	if (row != nil) {
		if ([row.cells count] > 0)
			cell = [row.cells lastObject];
	}
	return cell;
}

-(FDTableCell *)getSafeLastCell
{
    FDTableCell * cell = [self getLastCell];
    if (!cell) {
        cell = [FDTableCell new];
        [self addCell:cell];
    }
	return cell;
}


#pragma mark -
#pragma mark Drawing a Table


- (void)calculateMinMaxColumnWidths
{
    int i;
    NSMutableArray * minWidths = [NSMutableArray new];
    NSMutableArray * maxWidths = [NSMutableArray new];
    NSLog(@"validateFor Width table");
    for (FDTableRow * row in self.rows) {
        [row validateWidthMax:nil];
        i = 0;
        for (FDTableCell * cell in row.cells) {
            if (minWidths.count <= i)
                [minWidths addObject:[NSNumber numberWithDouble:cell.calculatedMinWidth]];
            else
            {
                NSNumber * n = [minWidths objectAtIndex:i];
                if ([n doubleValue] < cell.calculatedMinWidth)
                    [minWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:cell.calculatedMinWidth]];
            }
            if (maxWidths.count <= i)
                [maxWidths addObject:[NSNumber numberWithDouble:cell.calculatedMaxWidth]];
            else
            {
                NSNumber * n = [maxWidths objectAtIndex:i];
                if ([n doubleValue] < cell.calculatedMaxWidth)
                    [maxWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:cell.calculatedMaxWidth]];
            }
            i++;
        }
    }
    NSLog(@"widths:");
    self.calculatedMinColumnWidths = minWidths;
    self.calculatedMaxColumnWidths = maxWidths;
}

- (CGFloat)calculateMaxWidthSum
{
    CGFloat sum = 0;
    
    for (int ia = 0; ia < self.calculatedMinColumnWidths.count; ia++)
    {
        NSNumber * n2 = [self.calculatedMaxColumnWidths objectAtIndex:ia];
        sum += [n2 doubleValue];
    }
    
    return sum;
}

- (NSMutableArray *)determineFinalColumnWidths:(CGFloat)width sumWidth:(CGFloat)sumWidth
{
    NSMutableArray * finalWidth = [NSMutableArray new];
    if (sumWidth > width)
    {
        CGFloat ratio = width / sumWidth;
        for (int ia = 0; ia < self.calculatedMaxColumnWidths.count; ia++)
        {
            NSNumber * n1 = [self.calculatedMinColumnWidths objectAtIndex:ia];
            NSNumber * n2 = [self.calculatedMaxColumnWidths objectAtIndex:ia];
            CGFloat newWidth = [n2 doubleValue] * ratio;
            if (newWidth < [n1 doubleValue])
                newWidth = [n1 doubleValue];
            [finalWidth addObject:[NSNumber numberWithDouble:newWidth]];
            //NSLog(@" - final width %f", newWidth);
        }
        sumWidth = width;
    }
    else
    {
        [finalWidth addObjectsFromArray:self.calculatedMaxColumnWidths];
    }
    
    self.finalColumnWidths = finalWidth;
    return finalWidth;
}

-(CGFloat)validateForWidth:(CGFloat)width
{
    CGFloat sumWidth = 0;
    CGFloat sumHeight = 0;

    @try {
        if (self.calculatedMaxColumnWidths == nil || self.calculatedMinColumnWidths == nil)
        {
            [self calculateMinMaxColumnWidths];
        }

        sumWidth = [self calculateMaxWidthSum];
        
        NSMutableArray * finalWidth = [self determineFinalColumnWidths:width sumWidth:sumWidth];
        
        // validate for final width
        NSMutableArray * finalHeights = [NSMutableArray new];
        for (FDTableRow * row in self.rows) {
            [row validateWidthMax:finalWidth];
            [finalHeights addObject:[NSNumber numberWithDouble:row.calculatedHeight]];
            sumHeight += row.calculatedHeight;
        }
        self.finalRowHeights = finalHeights;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    
    return sumHeight;
}

-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart
{
    @try {
        NSUInteger rownum = 0;
        NSUInteger colnum = 0;
        NSNumber * rowheight = nil;
        NSNumber * colwidth = nil;
        CGFloat sumHeight = 0;
        CGFloat sumWidth = 0;
        for (rownum = 0; rownum < self.rows.count; rownum++)
        {
            FDTableRow * row = [self.rows objectAtIndex:rownum];
            if (rownum < self.finalRowHeights.count)
                rowheight = [self.finalRowHeights objectAtIndex:rownum];
            else
                rowheight = @30.0;
            sumWidth = 0;
            for (colnum = 0; colnum < row.cells.count; colnum++) {
                FDTableCell * cell = [row.cells objectAtIndex:colnum];
                if (colnum < self.finalColumnWidths.count)
                    colwidth = [self.finalColumnWidths objectAtIndex:colnum];
                else
                    colwidth = @40.0;
                
                CGFloat x = xStart + sumWidth;
                CGFloat y = yStart + sumHeight;
                
                [cell drawWithCanvas:canvas xstart:x ystart:y];
                
                sumWidth += [colwidth doubleValue];
            }
            sumHeight += [rowheight doubleValue];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return yStart;
}



@end
