//
//  FDTableRow.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@class FDTable, FDTableCell, FDTableLayout;

@interface FDTableRow : NSObject

@property NSMutableArray * cells;
@property CGFloat calculatedHeight;


-(void)addCell:(FDTableCell *)cell;
-(FDTableCell *)cellAtIndex:(int)i;
-(int)count;
-(void)validateWidthMax:(NSArray *)arr;

@end
