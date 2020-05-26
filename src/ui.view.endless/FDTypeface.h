//
//  FDTypeface.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@interface FDTypeface : NSObject


@property (copy) NSString * familyName;
@property CGFloat pointSize;
@property BOOL italic;
@property BOOL bold;
@property BOOL isGeneralFont;

+(NSString *)TIMES_FONT;
+(NSString *)ARIAL_FONT;
+(NSString *)defaultFontName;
+(void)setDefaultFontName:(NSString *)fontName;
+(float)defaultFontSize;
+(void)setDefaultFontSize:(float)fontSize;
+(FDTypeface *)defaultTypeface;
+(UIFont *)getFont:(NSString *)fontName size:(CGFloat)pointSize bold:(BOOL)b italic:(BOOL)i;
+(NSString *)correctFontName:(NSString *)fontName;
+(BOOL)isGeneralFontName:(NSString *)fontName;

-(UIFont *)getUIFont;

@end
