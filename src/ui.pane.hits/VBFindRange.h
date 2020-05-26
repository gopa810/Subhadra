//
//  VBFindRange.h
//  VedabaseA
//
//  Created by Peter Kollath on 1/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VBFindRange : NSObject {

	NSMutableArray * subArr;
}


@property NSInteger location;
@property NSInteger length;

+(id)findRange;
-(BOOL)intersectsWithRange:(NSInteger)rangeLocation length:(NSInteger)rangeLength;
-(void)mergeRange:(NSInteger)rangeLocation length:(NSInteger)rangeLength;
-(NSRange)range;
-(void)addEffectiveRange:(NSRange)eRange;
-(NSArray *)subranges;

@end
