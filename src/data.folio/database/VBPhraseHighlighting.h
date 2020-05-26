//
//  VBHighlightedPhraseSet.h
//  VedabaseA2
//
//  Created by Peter Kollath on 8/13/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>

/************************************************************
 *
 ************************************************************/


@interface VBRecordRange : NSObject

    @property uint32_t start;
    @property uint32_t end;

    -(id)initWithStart:(uint32_t)theStart stop:(uint32_t)theEnd;
    -(BOOL)isMember:(uint32_t)rec;

@end

/************************************************************
 *
 ************************************************************/


@interface VBFindRangeAd : NSObject {
    
        NSInteger location;
        NSInteger length;
        //NSPredicate * predicate;
        BOOL partial;
        //NSString * word;
    }


    @property NSInteger location;
    @property NSInteger length;
    @property NSPredicate * predicate;
    @property BOOL partial;
    @property NSString * word;

    +(id)findRange;
    -(BOOL)intersectsWithRange:(int)rangeLocation length:(int)rangeLength;
    -(void)mergeRange:(int)rangeLocation length:(int)rangeLength;
    -(NSRange)range;

@end

/************************************************************
 *
 ************************************************************/


@class VBFindRangeAd;

@interface VBHighlightedPhrase : NSObject {
    
	BOOL resetParaFlag;
	NSInteger currentItem;
	NSInteger currentProximity;
	NSInteger proximity;
}

@property NSMutableArray * items;
@property (assign) BOOL resetParaFlag;
@property (assign) NSInteger proximity;

-(void)addWord:(NSString *)str;
-(BOOL)testWord:(NSString *)str withRange:(NSRange)range;
-(BOOL)isLastWord;
-(void)reset;
-(NSArray *)ranges;
-(NSInteger)count;
-(VBFindRangeAd *)rangeAtIndex:(NSInteger)pos;

@end


/************************************************************
 *
 ************************************************************/

/************************************************************
 *
 ************************************************************/



@interface VBHighlightedPhraseSet : NSObject

@property(nonatomic,strong) NSMutableArray * highRanges;
@property(nonatomic,strong) NSMutableArray * items;

-(void)addObject:(id)obj;
-(void)removeAllObjects;
-(NSMutableArray *)itemsArray;
-(NSInteger)count;
-(void)OnNewParagraphTag;
-(BOOL)testWord:(NSString *)str withRange:(NSRange)range;
-(NSArray *)highlightedRanges;
-(void)clearHighlightedRanges;
@end





