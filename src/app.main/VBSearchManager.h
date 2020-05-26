//
//  VBSearchManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 15/09/14.
//
//

#import <Foundation/Foundation.h>
#import "EndlessTextViewDataSource.h"

@class VBFolio;
@class VBUserQuery;
@class VBHighlightedPhraseSet;
@class VBFolioQuery;

@interface VBSearchManager : NSObject <EndlessTextViewDataSource>

@property VBFolio * folio;
@property NSMutableArray * results;
//@property int resultsCount;
@property NSMutableArray * queries;
@property VBUserQuery * lastQuery;
@property VBHighlightedPhraseSet * phrases;
//@property NSMutableDictionary * assocTexts;

-(void)clear;
-(void)performSearch:(VBUserQuery *)query selectedContent:(NSString *)strSel currentRecord:(int)currentRecordId;
-(void)releaseAllRaws;
-(int)setRecordVisited:(int)recId;
+(NSString *)scopeText:(int)scopeIndex;

@end

#define SEARCHRESULTITEMTYPE_PLAINTEXT     1
#define SEARCHRESULTITEMTYPE_RECORDHEADER  2
#define SEARCHRESULTITEMTYPE_RECORDPART    3


@interface VBSearchResultItem : NSObject

@property NSString * plainText;
@property int type;
@property int recordId;
@property BOOL visited;
@property FDRecordBase * rawRecord;


@end

