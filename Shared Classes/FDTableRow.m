//
//  FDTableRow.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDTableRow.h"
#import "FDTable.h"
#import "FDTableCell.h"

@implementation FDTableRow


-(id)init
{
	self = [super init];
	if (self) {
		self.cells = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)addCell:(FDTableCell *)cell
{
	[self.cells addObject:cell];
}


-(FDTableCell *)cellAtIndex:(int)i
{
	return (FDTableCell *)[self.cells objectAtIndex:i];
}

-(int)count
{
	return (int)[self.cells count];
}

-(void)validateWidthMax:(NSArray *)array
{
    int i = 0;
    CGFloat width = 2000;
    self.calculatedHeight = 0;
    for (FDTableCell * cell in self.cells) {
        // get width restricted
        if (array != nil && array.count > i)
        {
            width = [(NSNumber *)[array objectAtIndex:i] doubleValue];
        }
        else
        {
            width = 2000;
        }
        [cell calculateWidthMax:width];
        //NSLog(@"cell maxw %f,   height %f", cell.calculatedMaxWidth, cell.calculatedHeight);
        if (self.calculatedHeight < cell.calculatedHeight)
            self.calculatedHeight = cell.calculatedHeight;
        i++;
    }
    
}



@end
