//
//  FDParagraph.h
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDRecordPart.h"

@class FDPartBase;

@interface FDParagraph : FDRecordPart


@property float layoutWidth;
@property float layoutHeight;
@property NSMutableArray * lines;

@property float borderTop;
@property float borderBottom;
@property float borderLeft;
@property float borderRight;
@property float clientTop;

@property UIImage * imageBefore;
@property CGSize imageBeforeSize;
@property UIImage * imageAfter;
@property CGSize imageAfterSize;


-(void)getSelectedText:(NSMutableString *)sb;
-(void)testHitInitWithPart:(FDRecordLocation *)hr part:(FDPartBase *)part;



@end
