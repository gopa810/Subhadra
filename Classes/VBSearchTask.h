//
//  VBSearchTask.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBSearchOperator.h"

@class VBFolio;

@interface VBSearchTask : NSObject {

	VBFolio * folio;
	VBSearchOperator * search;
	BOOL queryStarted;
}

@property (nonatomic,retain) VBFolio * folio;
@property (nonatomic,retain) VBSearchOperator * search;

-(id)initWithFolio:(VBFolio *)folio query:(NSString *)query;
-(void)setQuery:(NSString *)str;
-(void)findMatches:(uint32_t *)pDocIDs desiredCount:(int)dc actualCount:(int *)pfoundCount;
-(void)extractWords:(NSMutableArray *)array;

@end
