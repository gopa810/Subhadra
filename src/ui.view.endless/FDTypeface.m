//
//  FDTypeface.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDTypeface.h"
#import "FDCharFormat.h"

NSMutableDictionary * g_publicTypefaces;
NSString * g_defaultFontName;
float g_defaultFontSize;
NSString * g_TimesFontName = @"Times";
NSString * g_HelveticaFontName = @"Helvetica";
NSMutableSet * g_nonGeneralFonts = nil;
FDTypeface * g_defaultTypeface = nil;

@implementation FDTypeface



+(void)initialize
{
	g_publicTypefaces = [[NSMutableDictionary alloc] init];
	g_defaultFontName = [FDTypeface TIMES_FONT];
    g_defaultFontSize = 14;
    g_nonGeneralFonts = [[NSMutableSet alloc] initWithObjects:@"RM Devanagari", @"Inbenb", @"Inbeni", @"Inbenr", @"Indevr", @"Inbenb", @"Inbeni11", @"Sanskrit 2003", nil];
}


+(NSString *)TIMES_FONT
{
    return g_TimesFontName;
}

+(NSString *)ARIAL_FONT
{
    return g_HelveticaFontName;
}

+(NSString *)defaultFontName
{
    return g_defaultFontName;
}

+(void)setDefaultFontName:(NSString *)fontName
{
    g_defaultFontName = fontName;
    if (g_defaultTypeface) {
        g_defaultTypeface.familyName = fontName;
    }
}

+(float)defaultFontSize
{
    return g_defaultFontSize;
}

+(void)setDefaultFontSize:(float)fontSize
{
    g_defaultFontSize = fontSize;
    if (g_defaultTypeface) {
        g_defaultTypeface.pointSize = fontSize;
    }
}

+(UIFont *)getFont:(NSString *)fontName size:(CGFloat)pointSize bold:(BOOL)b italic:(BOOL)i
{
    // making hash key
    fontName = [FDTypeface correctFontName:fontName];
    NSString * key = [NSString stringWithFormat:@"%@_%f_%c%c", fontName, pointSize, (b ? 'Y' : 'N'), (i ? 'Y' : 'N')];

    // searching for existing font
	UIFont * font = [g_publicTypefaces objectForKey:key];
	if (font == nil) {
        //NSLog(@"*** TYPEFACE: %@", key);
        // creating font from description
        NSMutableDictionary * fontAttributes = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * traits = [[NSMutableDictionary alloc] init];
        
        UIFontDescriptorSymbolicTraits traitsValue = ((i ? UIFontDescriptorTraitItalic : 0) | (b ? UIFontDescriptorTraitBold : 0));
        
        [traits setObject:[NSNumber numberWithUnsignedInt:traitsValue] forKey:UIFontSymbolicTrait];
        
        [fontAttributes setObject:fontName forKey:UIFontDescriptorFamilyAttribute];
        [fontAttributes setObject:[NSNumber numberWithFloat:pointSize] forKey:UIFontDescriptorSizeAttribute];
        [fontAttributes setObject:traits forKey:UIFontDescriptorTraitsAttribute];
        
        UIFontDescriptor * fontDesc = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
//        if (b || i) {
//            fontDesc = [fontDesc fontDescriptorWithSymbolicTraits:];
//        }
        font = [UIFont fontWithDescriptor:fontDesc size:pointSize];
        [g_publicTypefaces setObject:font forKey:key];
	}

	return font;
}

+(NSString *)correctFontName:(NSString *)fontName {
    if (fontName == nil) {
        return g_defaultFontName;
    }
    if ([g_nonGeneralFonts containsObject:fontName]) {
        return fontName;
    }

    if ([fontName isEqualToString:@"Helv"]) {
        return g_HelveticaFontName;
    } else if ([fontName isEqualToString:g_HelveticaFontName]) {
        return g_HelveticaFontName;
    } else if ([fontName isEqualToString:g_TimesFontName]) {
        return g_TimesFontName;
    } else {
        return g_defaultFontName;
    }
}

+(BOOL)isGeneralFontName:(NSString *)fontName {
    return ! [g_nonGeneralFonts containsObject:fontName];
}

+(FDTypeface *)defaultTypeface
{
    if (g_defaultTypeface != nil)
        return g_defaultTypeface;
    
    FDTypeface * typeface = [[FDTypeface alloc] init];
    typeface.familyName = g_defaultFontName;
    typeface.pointSize = g_defaultFontSize;
    typeface.bold = NO;
    typeface.italic = NO;
    
    g_defaultTypeface = typeface;
    
    return typeface;
}

-(UIFont *)getUIFont
{
    return [FDTypeface getFont:self.familyName size:self.pointSize*[FDCharFormat multiplyFontSize] bold:self.bold italic:self.italic];
}


@end
