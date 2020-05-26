//
//  VBFolio.h
//  VedabaseA
//
//  Created by Peter Kollath on 12/26/10.
//  Copyright 2010 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBFolioDelegate.h"
#import "VBFolioStorage.h"
#import "VBBookmark.h"
@class FDTextFormat;

@interface VBFolio : NSObject {

	NSDictionary * info;
	NSString * title;

	NSUInteger storageTextCount;
    
    NSInteger loadedRangeStart, loadedRangeEnd, loadedRangeHit;
    NSArray * p_bookmarks;

    NSMutableArray * queryHistory;

}

@property VBFolioStorage * firstStorage;
@property (nonatomic,retain) NSString * documentsDirectory;
@property (nonatomic,retain) NSDictionary * info;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,readonly) NSData * stylesDataCSS;
@property (assign, readwrite) NSInteger loadedRangeStart;
@property (assign, readwrite) NSInteger loadedRangeEnd;
@property (assign, readwrite) NSInteger loadedRangeHit;
@property (copy, nonatomic) NSString * bodyFontFamily;
@property (copy, nonatomic) NSString * bodyBackgroundImage;
@property (assign) NSUInteger bodyFontSize;
@property (assign) NSUInteger bodyLineSpacing;
@property (strong, nonatomic) NSData * stylesCache;
@property (assign) NSUInteger bodyPaddingLeft;
@property (assign) NSUInteger bodyPaddingRight;
@property (strong) NSMutableDictionary * mapContentRecordToObjectName;
@property (strong) NSMutableDictionary * mapContentRecordToImage;

+(NSString *)URL_STYLE_SHEETS;
+(NSDictionary *)infoDictionaryFromFile:(NSString *)filePath;
+(NSString *)stringToSafe:(NSString *)str;

-(void)close;
-(id)initWithFileName:(NSString *)fileName;
-(NSString *)plainText:(NSUInteger)textID;
-(NSString *)text:(NSUInteger)textID;
-(void)textsFromStart:(NSUInteger)startTextID toEnd:(NSUInteger)endTextID target:(NSMutableString *)target;
-(NSString *)text:(NSUInteger)textID forPopupNumber:(NSInteger)pwCount;
-(NSData *)dataForRecordRange:(NSUInteger)textID;
-(NSString *)htmlTextForPopup:(NSString *)noteID;
-(NSString *)htmlTextForPopup:(NSString *)noteID forPopupNumber:(NSInteger)pwCount;
-(NSString *)htmlTextForNoteRecord:(int)recId;
-(BOOL)textWithinLoadedRange:(NSUInteger)textID;
-(NSUInteger)lastRequestedText;
-(NSData *)highlightSearchWords:(NSData *)srcFile words:(NSArray *)arrWords;
-(NSString *)findDocumentPath:(uint32_t)recID;
-(id)findObject:(NSString *)strName;
-(NSInteger)searchFirstRecord:(NSString *)queryText;
-(int32_t)findJumpDestination:(NSString *)targetJump;
-(void)search:(NSString *)queryText resultArray:(NSMutableArray *)results quotesArray:(VBHighlightedPhraseSet *)quotes ignoreSelection:(BOOL)ignoreSel queryArray:(NSMutableArray *)queries;
-(void)clearStylesCache;
-(NSString *)htmlTextForRecordText:(NSString *)text recordId:(int)recId;
-(void)loadShadow;
-(BOOL)saveShadow;
-(void)loadShadowFromFile:(NSString *)fileName;
-(BOOL)saveShadowToFile:(NSString *)fileName;
-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;
-(NSMutableArray *)queryHistory;
-(UIImage *)imageForContentRecord:(NSInteger)recordId;

-(VBFolioContentItem *)findContentItemWithId:(int)recordId;
-(NSArray *)findContentItemsWithParentId:(int)parentId;
-(VBFolioContentItem *)findContentRangeForRecordId:(int)parentId nodeType:(int)nodeType;

#pragma mark -
#pragma mark Bookmarks

-(NSInteger)getNextBookmarkId;
-(BOOL)bookmarkExists:(NSString *)bkmkName;
-(void)addBookmark:(VBBookmark *)bk toFolder:(NSInteger)folder;
-(void)saveBookmark:(NSString *)bkmkName recordId:(uint32_t)recId;
-(NSArray *)bookmarksForParent:(NSInteger)parentId;
-(VBBookmark *)bookmarkWithName:(NSString *)name;
-(void)removeBookmarkWithId:(NSInteger)index;
-(VBBookmark *)bookmarkWithId:(NSInteger)bid;
-(NSInteger)bookmarksCountForParent:(NSInteger)bid;
-(void)getAllBookmarkChildren:(NSInteger)bid array:(NSMutableArray *)arr;

#pragma mark -
#pragma mark Record Notes & Highlighted Texts

-(VBRecordNotes *)createNoteForRecord:(uint32_t)recId;
-(void)setHighlighter:(int)highlighterId forRecord:(uint32_t)recId startChar:(int)startIndex endChar:(int)endIndex;
-(void)removeNote:(VBRecordNotes *)note;
-(NSArray *)notesList;
-(NSArray *)highlightersList;
-(NSInteger)getNextNoteId;
-(void)addRecordNote:(VBRecordNotes *)rn toFolder:(NSInteger)folder;
-(void)getAllHightextChildren:(NSInteger)bid array:(NSMutableArray *)arr;
-(VBRecordNotes *)hightextForId:(NSInteger)bid;
-(NSArray *)highlightersListForParent:(NSInteger)bid;
-(NSArray *)notesListForParent:(NSInteger)bid;
-(void)getAllNotesChildren:(NSInteger)bid array:(NSMutableArray *)arr;
-(void)removeUnusedRecordNotes;

@end








