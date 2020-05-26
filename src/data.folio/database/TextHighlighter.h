//
//  TextHighlighter.h
//  VedabaseA
//
//  Created by Gopal on 16.10.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBFolioStorage.h"

#define FRONTA_LENGTH 32

@interface TextHighlighter : NSObject {
	VBHighlightedPhraseSet     * arrWords;
}

@property (nonatomic,retain) VBHighlightedPhraseSet * arrWords;


-(id)initWithPhraseSet:(VBHighlightedPhraseSet *)phraseSet;

+(NSString *)htmlTextToPlainText:(NSString *)htmlText;
+(NSString *)htmlTextToAsciiHtmlText:(NSString *)htmlText;
+(NSString *)htmlTextToOEMHtmlText:(NSString *)origHtmlText;


-(void)clearHighlightWords;
-(NSData *)highlightSearchWords:(NSData *)srcFile;
-(void)sortFindArray:(NSMutableArray *)farr;

@end
