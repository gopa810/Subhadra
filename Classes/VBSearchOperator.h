//
//  VBSearchOperator.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBFolio.h"

// oper:
// 0 - and
// 1 - or
// 2 - sentence (proximity)


@interface VBSearchOperator : NSObject {

	NSMutableArray * pipes;
	int oper;
	int proximity;
	NSString * word;
	VBFolio * folio;
	
	uint64_t  scopeOffset;
	uint32_t scopeLength;
	
	uint32_t maxIndex;
	uint32_t currPageIndexOffset;
	uint32_t currIndexInPage;
	uint8_t * buffer;
	BOOL endOfStream;
	
}

@property (nonatomic,retain) NSMutableArray * pipes;
@property (assign) int oper;
@property (assign) int proximity;
@property (nonatomic,retain) NSString * word;


-(id)initWithWord:(NSString *)str;
-(id)initWithArray:(NSArray *)arr;
-(id)initWithArray:(NSArray *)array type:(int)intype;

-(void)log:(int)level operat:(int)op;
-(void)loadArray:(NSArray *)array;
-(int)indexOfClosingBracket:(NSArray *)array fromIndex:(int)idx;
-(void)startQuery:(VBFolio *)inf;
-(BOOL)isPipe;
-(BOOL)alive;
-(uint32_t)moveToRecordID:(uint32_t)recID;
-(BOOL)moveNext;
-(uint32_t)synchronizedRecordID;
-(uint16_t)minProximitySubpipes;
-(uint32_t)currentRecordID;
-(uint32_t)gotoNextRecord;
-(void)extractWords:(NSMutableArray *)array;

@end
