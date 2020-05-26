//
//  VBFolioQuery.h
//  Builder_iPad
//
//  Created by Peter Kollath on 4/24/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteWrapper.h"
#import "VBPhraseHighlighting.h"
#import "VBFolioQueryOperator.h"

@class VBFolioStorage;

// ********************************************************************
//
// ********************************************************************



// ********************************************************************
//
// ********************************************************************

#define BUFFER_ITEM_SIZE    6
#define BUFFER_ITEMS_MAX   16384
#define BUFFER_SIZE_MAX    (BUFFER_ITEM_SIZE*BUFFER_ITEMS_MAX)

@interface VBFolioQueryOperatorStream : VBFolioQueryOperator
{
    const unsigned char * buffer;
}

@property (weak) SQLiteDatabase * database;
@property (copy) NSString * word;
@property (nonatomic) NSArray * blobsArray;
@property NSMutableData * blobData;
@property NSInteger blobSize;
@property int indexBase;
@property NSInteger currentBufferPosition;
@property NSInteger currentBlobIndex;

-(uint32_t)currentRecord;
-(uint16_t)currentProximity;
-(BOOL)gotoNextRecord;
-(BOOL)gotoNextProximity;
-(void)setBlobs:(NSArray *)blobArray;

@end


// ********************************************************************
//
// ********************************************************************


@interface VBFolioQueryOperatorContentItems : VBFolioQueryOperator
{
    int readIndex;
}

@property NSArray * array;
@property NSString * simpleText;
@property VBFolioStorage * storage;
@property BOOL exactWords;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;

@end

// ********************************************************************
//
// ********************************************************************


@interface VBFolioQueryOperatorContentSubItems : VBFolioQueryOperator
{
    int readIndex;
}

@property NSArray * array;
@property VBFolioStorage * storage;
@property VBFolioQueryOperator * source;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;

@end

// ********************************************************************
//
// ********************************************************************


@interface VBFolioQueryOperatorRecords : VBFolioQueryOperator
{
    int readIndex;
    NSMutableArray * array;
}

-(void)add:(int)recid;
-(void)addArray:(NSArray *)arr;
-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;

@end

// ********************************************************************
//
// ********************************************************************


@interface VBFolioQueryOperatorGetSubRanges : VBFolioQueryOperator
{
    int rangeStart;
    int rangeEnd;
    int position;
}

@property VBFolioQueryOperator * source;
@property VBFolioStorage * storage;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;

@end


// ********************************************************************
//
// ********************************************************************


@interface VBFolioQueryOperatorGetLevelRecords : VBFolioQueryOperator
{
    int readIndex;
}

@property NSInteger levelIndex;
@property VBFolioStorage * storage;
@property NSArray * levelRecords;
@property NSString * simpleTitle;
@property BOOL exactWords;

-(id)initWithFolioStorage:(VBFolioStorage *)aStorage;
-(id)initWithFolioStorage:(VBFolioStorage *)aStorage level:(NSInteger)aLevel;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;

@end

// ********************************************************************
//
// ********************************************************************

@interface VBFolioQueryOperatorAnd : VBFolioQueryOperator

@property NSMutableArray * items;


-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;


@end

// ********************************************************************
//
// ********************************************************************

@interface VBFolioQueryOperatorOr : VBFolioQueryOperator

@property NSMutableArray * items;


-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;
-(uint16_t)currentProximity;
-(BOOL)gotoNextProximity;

@end

// ********************************************************************
//
// ********************************************************************

@interface VBFolioQueryOperatorQuote : VBFolioQueryOperator

@property NSMutableArray * items;

-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;

@end

// ********************************************************************
//
// ********************************************************************

@interface VBFolioQueryOperatorNot : VBFolioQueryOperator

@property VBFolioQueryOperator * partAnd;
@property VBFolioQueryOperator * partOr;


-(uint32_t)currentRecord;
-(BOOL)gotoNextRecord;
-(void)validate;


@end



// ********************************************************************
//
// ********************************************************************
