//
//  FFFUtils.h
//  Builder_iPad
//
//  Created by Peter Kollath on 11/9/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBRecordNotes.h"

@protocol FolioObjectValidator <NSObject>

-(BOOL)jumpExists:(NSString *)jumpDest;
-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId;

@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface FlatFileUtils : NSObject

+(NSString *)encodeLinkSafeString:(NSString *)string;
+(NSString *)decodeLinkSafeString:(NSString *)string;
+(NSString *)removeTags:(NSString *)str;
+(NSString *)removeTagsAndNotes:(NSString *)str;
+(NSString *)makeIndexableString:(NSString *)aString;
+(BOOL)isImageFileExtension:(NSString *)ext;
+(NSString *)getMimeType:(NSString *)fileExt;
+(NSString *)normalizeFileType:(NSString *)fileType;
+(BOOL)isImageMimeType:(NSString *)type;
@end


//////////////////////////////////////////////////////////////////////////////////
//
//

@interface FlatFileTagString : NSObject

@property NSMutableString * extractedTag;
@property NSMutableString * mutableBuffer;

-(void)clear;
-(void)appendChar:(char)c;
-(void)appendString:(NSString *)str;
-(NSString *)buffer;
-(NSArray *)createArray;
-(NSString *)tag;

@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface HtmlStyle : NSObject

@property (copy,nonatomic) NSString * styleName;
@property NSMutableDictionary * format;
@property BOOL styleNameChanged;

-(NSString *)valueForKey:(NSString *)str;
-(void)setValue:(NSString *)strValue forKey:(NSString *)strKey;
-(void)clearFormat;
-(NSString *)styleCssText;
-(NSString *)htmlTextForTag:(NSString *)tag;
-(void)clear;
@end

//////////////////////////////////////////////////////////////////////////////////
//
//


@interface HtmlStyleTracker : HtmlStyle

@property NSMutableDictionary * formatOld;
@property NSMutableSet * formatChanges;

-(void)clearChanges;
-(BOOL)hasChanges;

@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface HtmlStylesCollection : NSObject

@property NSMutableArray * styles;

-(void)addStyle:(HtmlStyle *)style;
-(NSString *)substitutionFontName:(NSString *)fname;
-(NSString *)getMIMEType:(NSString *)str;
@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface HtmlString : NSObject

@property NSMutableString * buffer;
@property (assign) BOOL acceptText;

-(NSString *)string;
-(BOOL)setString:(NSString *)str;
-(void)clear;
-(BOOL)addCharacter:(unichar)chr;
-(BOOL)appendString:(NSString *)str;
-(NSInteger)indexfOfFirstOccurenceOfTag:(NSString *)strTag;
-(void)insertString:(NSString *)str atIndex:(NSInteger)pos;
@end


//////////////////////////////////////////////////////////////////////////////////
//
//

@interface FlatFileString : NSObject
    
@property     BOOL hcParaStarted;
@property     BOOL hcSpanStarted;
@property     BOOL hcSup;
@property     BOOL hcSupChanged;
@property     BOOL hcSub;
@property     BOOL hcSubChanged;
@property     BOOL linkStarted;
@property     BOOL buttonStarted;
@property     int hcPwCounter;
@property     int hcNtCounter;
@property     int hcTableRows;
@property     int hcTableColumns;
@property     int catchPwLevel;
@property     int catchPwCounter;
@property     int catchNtCounter;

@property NSMutableString * buffer;
@property (copy) NSString * dataObjectName;
@property (copy) NSString * ethListImage;
@property (copy) NSString * ethStyle;

@property HtmlStyle * paraStyleRead;
@property id<FolioObjectValidator> validator;
@property NSMutableArray * ethStack;
@property NSMutableDictionary * ethDict;
@property BOOL ethDefaultExpanded;

+(NSString *)stringToSafe:(NSString *)str tag:(NSString *)tag;
+(BOOL)dataLinkAsButton;
+(void)setDataLinkAsButton:(BOOL)bValue;
-(NSString *)string;
-(void)reset;
-(void)setString:(NSString *)string;
-(HtmlString *)htmlStringWithStyles:(HtmlStylesCollection *)styles forRecord:(NSDictionary *)recDict;
-(HtmlString *)htmlStringWithStyles:(HtmlStylesCollection *)styles forRecord:(NSDictionary *)recDict htmlString:(HtmlString *)target;
-(void)setCatchPwCounter:(int)val;
-(void)setCatchPwLevel:(int)val;
-(void)setCatchNtCounter:(int)val;
+(NSString *)removeTags:(NSString *)str;

@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@class FlatFileStringIndexer;

@protocol FlatFileStringIndexerDelegate <NSObject>

-(void)pushWord:(NSString *)word fromIndexer:(FlatFileStringIndexer *)indexer;
-(void)pushTag:(FlatFileTagString *)tag fromIndexer:(FlatFileStringIndexer *)indexer;
-(void)pushEndfromIndexer:(FlatFileStringIndexer *)indexer;
@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface GPMutableInteger : NSObject

@property NSInteger value;

-(NSInteger)intValue;
-(void)increment;
-(void)decrement;

@end

//////////////////////////////////////////////////////////////////////////////////
//
//

@interface FlatFileStringIndexer : NSObject

@property (copy) NSString * text;
@property NSMutableDictionary * properties;
@property id <FlatFileStringIndexerDelegate> delegate;

-(void)parse;
-(id)objectForKey:(NSString *)key;
-(void)setObject:(id)property forKey:(NSString *)key;

@end






