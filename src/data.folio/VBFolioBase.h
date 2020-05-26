//
//  VBFolioBase.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/01/15.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteWrapper.h"
#import "VBFolioStorageObjects.h"
#import "FlatFileUtils.h"

@interface VBFolioBase : NSObject <FolioObjectValidator>
{
    int statCounter;
    int tableCounter;
    NSUInteger textCount;
    BOOL textCountValid;
}

@property SQLiteDatabase * database;
@property NSMutableArray * inclusionPath;
@property (assign,readonly) NSUInteger textCount;
@property (nonatomic, copy) NSString * fileName;
@property NSMutableDictionary * commands;
@property VBFolioContentItem * content;


/*******************************************************
 * Connection to database
 *******************************************************/


-(BOOL)openStorage:(NSString *)filePath;
-(void)commit;
-(void)startTransaction;
-(void)endTransaction;
-(int)executeScript:(NSString *)script;
-(void)close;
+(NSDictionary *)infoDictionaryFromFile:(NSString *)filePath;
-(SQLiteDatabase *)getDatabase;

//
// accessing preloaded commands
+(NSInteger)resultsInPage;
-(NSString *)commandTextForKey:(NSString *)key;
-(SQLiteCommand *)commandForKey:(NSString *)key;
-(SQLiteCommand *)commandForKey:(NSString *)key query:(NSString *)text;
-(SQLiteCommand *)createSqlCommand:(NSString *)query;


/*******************************************************
 * Writing content
 *******************************************************/

-(void)insertObject:(NSData *)objData name:(NSString *)objName type:(NSString *)objType;
-(void)insertFolioProperty:(NSString *)propName value:(NSString *)propValue;
-(void)insertFolioProperty:(NSString *)propName value:(NSString *)propValue index:(NSInteger)idx;
-(void)insertContentItem:(NSDictionary *)contItem;
-(void)insertStyleRef:(NSString *)styleName index:(int)idx;
-(void)insertStyleDetail:(NSString *)detailName value:(NSString *)detailValue index:(int)idx;

//
// insertLevelDefinition
// expects entries: original, safe, index in the dictionary
//
-(void)insertLevelDefinition:(NSDictionary *)levelDict;
-(void)insertWordRef:(NSString *)inword wordID:(uint32_t)wid data:(NSData *)dataRefs
               index:(NSString *)idxTag recordIndexBase:(int)rib;
-(void)insertGroup:(NSString *)group record:(uint32_t)recID;
-(void)insertJumpLink:(NSString *)jump record:(uint32_t)recID;
-(void)writeRecord:(uint32_t)recid plainText:(NSString *)plain levelName:(NSString *)levelName styleName:(NSString *)styleName;
-(void)writeNote:(NSDictionary *)dict;


/*******************************************************
 * Reading content
 *******************************************************/

-(NSString *)getObjectType:(NSString *)objName;
-(NSString *)getRecordPath:(int)record;

//-(VBFolioContentItem *)findRecordPath:(NSInteger)recID;
//-(NSString *)getDocumentPath:(VBFolioContentItem *)item;
-(NSString *)findDocumentPath:(uint32_t)recID;
-(NSString *)stylesObject;
-(id)findObject:(NSString *)strName;
-(BOOL)objectExists:(NSString *)strName;
-(int)findOriginalLevelIndex:(NSString *)levelName;
-(uint32_t)findLinkReference:(uint32_t)linkRef;
-(void)initContentObject;
-(void)findGroupRefs:(NSString *)groupStr resultArray:(NSMutableArray *)arr;
-(int32_t)findJumpDestination:(NSString *)targetJump;
-(NSArray *)contentItemsForPage:(uint32_t)pageID;
-(NSDictionary *)findPopupText:(NSString *)popupID;
+(NSData *)readObject:(NSString *)objectName fromDatabase:(sqlite3 *)db;
-(NSDictionary *)readText:(uint32_t)recid forKey:(NSString *)strKey;
-(int)findTextCount;
// searches words like word
-(NSArray *)searchWords:(NSString *)word forIndex:(NSString *)idxTag;
// retrieves word's index blob
-(NSArray *)getWordIndexBlob:(NSString *)word forIndex:(NSString *)idxTag;
-(NSArray *)enumerateLevelRecords:(NSInteger)level;
-(NSArray *)enumerateLevelRecords:(NSInteger)level withSimpleTitle:(NSString *)simple;
-(NSArray *)enumerateLevelRecords:(NSInteger)level likeSimpleTitle:(NSString *)simple;
-(uint32_t)getSubRangeEndForRecord:(NSInteger)record;
-(NSArray *)enumerateContentItemsForParent:(uint32_t)recId;
-(NSArray *)enumerateContentItemsWithSimpleText:(NSString *)simpleText;
-(NSArray *)enumerateGroupRecords:(NSString *)groupName;
-(NSArray *)enumerateContentItemsLikeSimpleText:(NSString *)simpleText;
-(NSString *)simpleContentTextForRecord:(NSInteger)recordId;


@end
