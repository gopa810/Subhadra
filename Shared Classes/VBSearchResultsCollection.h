//
//  VBSearchResultsCollection.h
//  VedabaseB
//
//  Created by Peter Kollath on 14/09/14.
//
//

#import <Foundation/Foundation.h>
#import "FDRecordBase.h"

#define SEARCH_RESULTS_COLLECTION_SIZE  (32)
#define SEARCH_RESULTS_RAWS_SIZE        (SEARCH_RESULTS_COLLECTION_SIZE*2)

@interface VBSearchResultsCollection : NSObject

@property NSMutableData * recordsData;
@property NSMutableArray * raws;
@property int count;
@property NSString * htmlText;

-(BOOL)hasSpace;
-(void)add:(int)recordId;
-(void)clear;
-(int)recordIdAtIndex:(int)index;
-(BOOL)hasRawTexts;
-(FDRecordBase *)rawTextAtIndex:(int)index;

@end
