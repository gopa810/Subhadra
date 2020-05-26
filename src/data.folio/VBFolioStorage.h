//
//  VBFolioStorage.h
//  Builder_iPad
//
//  Created by Peter Kollath on 4/14/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VBFolioBase.h"
#import "VBPhraseHighlighting.h"
#import "VBFolioQueryObjects.h"
#import "VBFolioStorageObjects.h"
#import "SQLiteWrapper.h"
#import "FlatFileUtils.h"
#import "VBRecordNotes.h"
#import "VBBookmark.h"
#import "FDRecordBase.h"

@class FDTextFormat;

@interface VBFolioStorage : VBFolioBase 
{
    NSMutableArray * bulks;
    NSLock * bulkLock;
    NSMutableArray * pagesToLoad;
    NSLock * pagesLock;

}

@property NSMutableArray * p_recordNotes;
@property NSMutableArray * p_bookmarks;

@property (assign) BOOL bookmarksChanged;
@property NSLock * loadPageLock;

-(NSInteger)searchFirstRecord:(NSString *)queryText;
-(NSInteger)searchFirstRecordLike:(NSString *)queryText;

-(void)search:(NSString *)queryText 
   resultArray:(NSMutableArray *)results 
   quotesArray:(VBHighlightedPhraseSet *)quotes 
   ignoreSelection:(BOOL)ignoreSel
   queryArray:(NSMutableArray *)queries;

- (NSMutableDictionary *)readObjectNamesForContentRecords;


#pragma mark -
#pragma mark notes & highlighters management

-(VBRecordNotes *)createNoteForRecord:(uint32_t)recId;
-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId;
-(VBRecordNotes *)setHighlighter:(int)highlighterId forRecord:(uint32_t)recId startChar:(int)startIndex endChar:(int)endIndex;
-(BOOL)bookmarkExists:(NSString *)bkmkName;
-(void)saveBookmark:(NSString *)bkmkName recordId:(uint32_t)recId;
-(NSArray *)bookmarks;
-(void)removeBookmarkWithName:(NSString *)name;
-(VBBookmark *)bookmarkWithName:(NSString *)name;
-(NSArray *)notesList;
-(NSArray *)highlightersList;
-(void)removeNote:(VBRecordNotes *)note;

-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;

-(int)correctionForRecord:(int)recId;

#pragma mark -
#pragma mark Bulks


-(BOOL)recordIsLoaded:(unsigned int)recid;
-(FDRecordBase *)getRawRecord:(unsigned int)recid;
-(FDTextFormat *)getRawStyle:(NSString *)levelName;
-(void)refreshRecordData:(int)recid;
-(void)setNeedsUpdateHighlightPhrases;
-(void)invalidateRecordWidths;

#pragma mark -
#pragma mark Styles

+(void)setAlternateStylesMap:(NSDictionary *)dict;
+(void)setValue:(NSString *)strValue forHtmlProperty:(NSString *)strProp forStyle:(NSString *)strStyle dictionary:(NSMutableDictionary *)dict;

@end


