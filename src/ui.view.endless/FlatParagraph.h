//
//  FlatParagraph.h
//  VedabaseB
//
//  Created by Peter Kollath on 03/08/14.
//
//

#import <Foundation/Foundation.h>

@class FDParaFormat,FDCharFormat,FDRecordBase,FDLink, VBFolioStorage,FolioTextRecord;
@class FDCharFormatStack;

@interface FlatParagraph : NSObject


@property BOOL hcParaStarted;
@property BOOL acceptText;
@property FDParaFormat * paraStyleRead;
@property NSString * dataObjectName;
@property id validator;
@property int catchPwLevel;
@property int catchPwCounter;
@property int catchNtCounter;
@property int hcPwCounter;
@property int hcNtCounter;
@property int hcTableRows;
@property int hcTableColumns;

@property FDRecordBase * target;
@property FDCharFormatStack * cfStack;
//@property FDCharFormat * charFormatting;
@property FDParaFormat * paraStyle;
@property FDLink * currLink;
@property NSMutableArray * pwLevel;// = new Stack<Integer>();
@property NSMutableArray * pwParaStart;// = new Stack<Boolean>();
@property NSMutableArray * pwLinkStyle;// = new Stack<String>();
//@property NSMutableArray * charStyleStack;// = new Stack<FDCharFormat>();
//@property NSMutableArray * origCharStyleStack;// = new Stack<FDCharFormat>();
@property int startIndex;
@property NSMutableString * wordBuilder;
@property NSMutableDictionary * alternativeFormats;
@property VBFolioStorage * folio;

+(int)ACTION_NONE;
+(int)ACTION_CR;
+(int)ACTION_HR;
+(int)ACTION_HS;
+(int)ACTION_IGNOREREC;

-(id)initWithFolio:(VBFolioStorage *)source;
-(UIImage *)getPredefinedBitmap:(int)imageId;
-(float)inchToPoints:(NSString *)inches;
-(int)alignFromString:(NSString *)str;
-(void)readBorders:(NSArray *)arr style:(FDParaFormat *)style;
-(void)readIndentFormating:(NSArray *)arr style:(FDParaFormat *)style;
-(int)readColor:(NSArray *)arr;
-(FDRecordBase *)convertToRaw:(FolioTextRecord *)recDict;
-(void)refresh:(FDRecordBase *)recDict;
+(void)setDefaultFont:(NSString *)fontName;

@end
