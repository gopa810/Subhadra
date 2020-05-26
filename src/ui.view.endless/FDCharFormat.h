//
//  FDCharFormat.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#define PM_TEXTSIZE        0x0001
#define PM_FONTNAME        0x0002
#define PM_BACKGROUNDCOLOR 0x0004
#define PM_BOLD            0x0008
#define PM_HIDDEN          0x0010
#define PM_UNDERLINE       0x0020
#define PM_STRIKEOUT       0x0040
#define PM_FOREGROUNDCOLOR 0x0080
#define PM_ITALIC          0x0100
#define PM_SUPER           0x0200
#define PM_SUB             0x0400


#import <Foundation/Foundation.h>
#import "FDTypeface.h"

@interface FDCharFormat : NSObject

@property NSMutableDictionary * dictionary;

@property (nonatomic) int changed;
@property (nonatomic) BOOL forcedFontName;
@property (nonatomic) float textSize;
@property (nonatomic,copy) NSString * fontName;
@property (nonatomic) int backgroundColor;
@property (nonatomic) BOOL bold;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL underline;
@property (nonatomic) BOOL strikeOut;
@property (nonatomic) BOOL italic;
@property (nonatomic) BOOL superScript;
@property (nonatomic) BOOL subScript;
@property (nonatomic) int foregroundColor;


+(float)multiplyFontSize;
+(void)setMultiplyFontSize:(float)value;
+(float)multiplySpaces;
+(void)setMultiplySpaces:(float)value;
+(int)fontSizeIndex;
+(void)setFontSizeIndex:(int)fsi;
+(float)multiplyFontSizeMin;
+(float)multiplyFontSizeMax;
+(float)multiplySpacesMin;
+(float)multiplySpacesMax;

-(FDCharFormat *)copyFrom:(FDCharFormat *)fce;
-(NSMutableDictionary *)getDictionary;
-(FDTypeface *)getTypeface;
-(NSString *)getHash;
-(NSString *)getTypefaceHash;
-(void)overloadFrom:(FDCharFormat *)cf;
-(FDCharFormat *)clone;
-(void)initDefaults;

@end
