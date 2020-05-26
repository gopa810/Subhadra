//
//  VBFindRangeArray.h
//  VedabaseA
//
//  Created by Peter Kollath on 1/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBFindRange.h"

@interface VBFindRangeArray : NSObject {

	NSMutableArray * array;
}

-(VBFindRange *)findRange:(int)rangeLocation length:(int)rangeLength;
-(void)addRange:(int)rangeLocation length:(int)rangeLength effective:(NSRange)eRange;
-(NSInteger)count;
-(NSRange)rangeAtIndex:(int)i;
-(void)insertRange:(int)rangeLocation length:(int)rangeLength effective:(NSRange)eRange;
-(void)sortArray;
-(void)applyRange:(int)nIndex fromText:(NSString *)src toHtmlText:(NSMutableString *)dest;
-(void)applyRange:(int)nIndex fromText:(NSString *)src toFlatText:(NSMutableString *)dest;

@end
