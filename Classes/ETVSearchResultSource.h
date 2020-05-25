//
//  ETVSearchResultSource.h
//  VedabaseB
//
//  Created by Peter Kollath on 13/09/14.
//
//

#import <Foundation/Foundation.h>

@class VBFolio;

@interface ETVSearchResultSource : NSObject

@property VBFolio * folio;
// this array contains numbers of found records and loaded texts
// needs to be created new class VBHitsPage
// where is array of ints and array of FDRecordBase
// and where translation from recordId to FDRecordBase is done
// also we have to change functions:
//      -(void)loadResultsPage:(int)nPage
//      -(void)search:(NSString *)queryText
//        resultArray:(NSMutableArray *)results
//        quotesArray:(VBHighlightedPhraseSet *)quotes
//       ignoreSelection:(BOOL)ignoreSel
//         queryArray:(NSMutableArray *)queries
@property NSMutableArray * searchResults;
@property int searchResultsCount;


@end
