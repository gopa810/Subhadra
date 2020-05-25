//
//  VBFolioQuery.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import <Foundation/Foundation.h>
#import "VBFolioStorage.h"
#import "VBSearchTreeContext.h"
#import "VDTreeItem.h"

// ********************************************************************
//
// ********************************************************************




// ********************************************************************
//
// ********************************************************************

@interface VBFolioQuery : NSObject
{
    int tableCounter;
    //VBFolioStorage * storage;
}

@property VBFolioStorage * storage;

-(id)initWithStorage:(VBFolioStorage *)store;
-(NSArray *)sourceToArray:(NSString *)str;
-(BOOL)stringContainsWildcards:(NSString *)word;

// converting to SQL query
-(NSString *)convertQuoteToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes;
-(NSString *)convertAndToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes;
-(NSString *)convertAndNotArrayToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes;
-(NSString *)convertArrayToQuery:(NSArray *)array quotesArray:(VBHighlightedPhraseSet *)quotes;

//converting to VBFolio query tree
-(VBFolioQueryOperator *)convertWordWithDashesToTree:(NSString *)wordx context:(VBSearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertWordToTree:(NSString *)word context:(VBSearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertAndQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertOrQuoteToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx;
//-(VBFolioQueryOperator *)convertAndToTree:(NSArray *)array context:(SearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertAndNotArrayToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx;
-(VBFolioQueryOperator *)convertArrayToTree:(NSArray *)array context:(VBSearchTreeContext *)ctx;

+(VDTreeItem *)dumpQueryTree:(VBFolioQueryOperator *)oper;
+(UIImage *)createImageFromQuery:(VBFolioQueryOperator *)oper;



@end
