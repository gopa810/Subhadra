//
//  FDCharFormat.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDCharFormat.h"
#import "FDColor.h"
#import "FDTypeface.h"

float g_multiplyFontSize = 1.61f;
float g_multiplySpaces = 1.2f;
int g_fontSizeIndex = 9;

float g_fontSizes[] = {
    0.385f, 0.452f, 0.529f, 0.621f,
    0.727f, 0.853f, 1.000f, 1.172f,
    1.373f, 1.610f, 1.886f, 2.211f,
    2.592f, 3.030f, 3.560f, 4.170f,
    4.891f, 5.730f, 6.718f, 7.874f
};

@implementation FDCharFormat

-(id)init
{
	self = [super init];
	if (self) {
        
        self.dictionary = [NSMutableDictionary new];
		self.changed = 0;
	}
	return self;
}

-(void)initDefaults
{
    self.fontName = [FDTypeface defaultFontName];
    self.textSize = [FDTypeface defaultFontSize];
    self.hidden = NO;
    self.bold = NO;
    self.italic = NO;
    self.strikeOut = NO;
    self.subScript = NO;
    self.superScript = NO;
    self.underline = NO;
    self.changed = 0;
}

+(float)multiplyFontSizeMin
{
    return 0.8f;
}

+(float)multiplyFontSizeMax
{
    return 4.0f;
}

+(float)multiplySpacesMin
{
    return 0.8f;
}

+(float)multiplySpacesMax
{
    return 2.5f;
}

+(int)fontSizeIndex
{
    return g_fontSizeIndex;
}

+(void)setFontSizeIndex:(int)fsi
{
    g_fontSizeIndex = fsi;
    g_multiplyFontSize = g_fontSizes[fsi];
}

+(float)multiplyFontSize
{
	return g_multiplyFontSize;
}

+(void)setMultiplyFontSize:(float)value
{
	g_multiplyFontSize = value;
}

+(float)multiplySpaces
{
	return g_multiplySpaces;
}

+(void)setMultiplySpaces:(float)value
{
	g_multiplySpaces = value;
}

-(float)textSize
{
    NSNumber * n = [self.dictionary valueForKey:@"PT"];
    if (n == nil)
        return [FDTypeface defaultFontSize];
    return [n floatValue];
}

-(void)setTextSize:(float)value
{
    [self.dictionary setObject:[NSNumber numberWithFloat:value] forKey:@"PT"];
	_changed |= PM_TEXTSIZE;
}

-(NSString *)fontName
{
    NSString * str = [self.dictionary valueForKey:@"FT"];
    if (str != nil)
        return str;
    return [FDTypeface defaultFontName];
}

-(void)setFontName:(NSString *)value
{
    [self.dictionary setObject:value forKey:@"FT"];
	_changed |= PM_FONTNAME;
}

-(int)backgroundColor
{
    NSNumber * n = [self.dictionary valueForKey:@"BC"];
    if (n == nil)
        return 0;
    return [n intValue];
}

-(void)setBackgroundColor:(int)value
{
    [self.dictionary setValue:[NSNumber numberWithInt:value] forKey:@"BC"];
	_changed |= PM_BACKGROUNDCOLOR;
}

-(BOOL)bold
{
    NSNumber * n = [self.dictionary valueForKey:@"BD"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setBold:(BOOL)bold
{
    [self.dictionary setValue:[NSNumber numberWithBool:bold] forKey:@"BD"];
	_changed |= PM_BOLD;
}

-(BOOL)hidden
{
    NSNumber * n = [self.dictionary valueForKey:@"HD"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setHidden:(BOOL)hidden
{
	_changed |= PM_HIDDEN;
    [self.dictionary setValue:[NSNumber numberWithBool:hidden] forKey:@"HD"];
}

-(BOOL)underline
{
    NSNumber * n = [self.dictionary valueForKey:@"UN"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setUnderline:(BOOL)underline
{
	_changed |= PM_UNDERLINE;
    [self.dictionary setValue:[NSNumber numberWithBool:underline] forKey:@"UN"];
}

-(BOOL)strikeOut
{
    NSNumber * n = [self.dictionary valueForKey:@"SO"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setStrikeOut:(BOOL)strikeOut
{
	_changed |= PM_STRIKEOUT;
    [self.dictionary setValue:[NSNumber numberWithBool:strikeOut] forKey:@"SO"];
}

-(BOOL)italic
{
    NSNumber * n = [self.dictionary valueForKey:@"IT"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setItalic:(BOOL)italic
{
	_changed |= PM_ITALIC;
    [self.dictionary setValue:[NSNumber numberWithBool:italic] forKey:@"IT"];
}

-(BOOL)superScript
{
    NSNumber * n = [self.dictionary valueForKey:@"SP"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setSuperScript:(BOOL)superScript
{
	_changed |= PM_SUPER;
    [self.dictionary setValue:[NSNumber numberWithBool:superScript] forKey:@"SP"];
}

-(BOOL)subScript
{
    NSNumber * n = [self.dictionary valueForKey:@"SB"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setSubScript:(BOOL)subScript
{
	_changed |= PM_SUB;
    [self.dictionary setValue:[NSNumber numberWithBool:subScript] forKey:@"SB"];
}

-(int)foregroundColor
{
    NSNumber * n = [self.dictionary valueForKey:@"FC"];
    if (n == nil)
        return 0;
    return [n intValue];
}

-(void)setForegroundColor:(int)foregroundColor
{
    [self.dictionary setValue:[NSNumber numberWithInt:foregroundColor] forKey:@"FC"];
	_changed |= PM_FOREGROUNDCOLOR;
}

-(NSString *)getHash
{
	return [NSString stringWithFormat:@"%@_%f_%d_%c%c%c%c%c%c%c",  self.fontName, self.textSize,self.foregroundColor,
            self.bold ? 'Y' : 'N', self.italic ? 'Y' : 'N', self.hidden ? 'Y' : 'N', self.strikeOut ? 'Y' : 'N',
            self.underline ? 'Y' : 'N', self.subScript ? 'Y' : 'N', self.superScript ? 'Y' : 'N'];
}

-(NSString *)getTypefaceHash
{
	return [NSString stringWithFormat:@"%@_%f_%c%c", self.fontName, self.textSize,
            self.bold ? 'Y' : 'N', self.italic ? 'Y' : 'N'];
}

-(FDTypeface *)getTypeface
{
    FDTypeface * typeface = [[FDTypeface alloc] init];
    typeface.familyName = self.fontName;
    typeface.pointSize = self.textSize;
    typeface.bold = self.bold;
    typeface.italic = self.italic;
    typeface.isGeneralFont = [FDTypeface isGeneralFontName:self.fontName];
    
    return typeface;
}

-(NSMutableDictionary *)getDictionary
{
    NSString            * fontName = self.fontName;
    NSMutableDictionary * dict     = [[NSMutableDictionary alloc] init];
    
    if (self.foregroundColor != 0) {
        [dict setObject:[FDColor getColor:self.foregroundColor] forKey:NSForegroundColorAttributeName];
    }
    if (self.strikeOut) {
        [dict setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
    }
    if (self.underline) {
        [dict setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    }
	if (!self.forcedFontName && [FDTypeface isGeneralFontName:self.fontName]) {
        fontName = [FDTypeface defaultFontName];
        [dict setObject:@"YES" forKey:@"FDTypefaceGeneralFont"];
    }

    UIFont * font = [FDTypeface getFont:fontName
                          size:FDCharFormat.multiplyFontSize*self.textSize
                          bold:self.bold
                        italic:self.italic];
    [dict setObject:font forKey:NSFontAttributeName];

	return dict;
}

-(FDCharFormat *)copyFrom:(FDCharFormat *)fce
{
	self.textSize = fce.textSize;
	self.fontName = fce.fontName;
	self.backgroundColor = fce.backgroundColor;
	self.bold = fce.bold;
	self.hidden = fce.hidden;
	self.underline = fce.underline;
	self.strikeOut = fce.strikeOut;
	self.foregroundColor = fce.foregroundColor;
	self.italic = fce.italic;
	self.superScript = fce.superScript;
	self.subScript = fce.subScript;
	self.forcedFontName = fce.forcedFontName;
	
	return self;
}

-(BOOL)checkChange:(int)property
{
	return (self.changed & property) > 0;
}

-(void)overloadFrom:(FDCharFormat *)cf
{
	if ([cf checkChange:PM_TEXTSIZE]) {
		self.textSize = cf.textSize;
	}
	if ([cf checkChange:PM_BACKGROUNDCOLOR]) {
		self.backgroundColor = cf.backgroundColor;
	}
	if ([cf checkChange:PM_BOLD]) {
		self.bold = cf.bold;
	}
	if ([cf checkChange:PM_FONTNAME]) {
		self.fontName = cf.fontName;
	}
	if ([cf checkChange:PM_FOREGROUNDCOLOR]) {
		self.foregroundColor = cf.foregroundColor;
	}
	if ([cf checkChange:PM_HIDDEN]) {
		self.hidden = cf.hidden;
	}
	if ([cf checkChange:PM_ITALIC]) {
		self.italic = cf.italic;
	}
	if ([cf checkChange:PM_STRIKEOUT]) {
		self.strikeOut = cf.strikeOut;
	}
	if ([cf checkChange:PM_SUB]) {
		self.subScript = cf.subScript;
	}
	if ([cf checkChange:PM_SUPER]) {
		self.superScript = cf.superScript;
	}
	if ([cf checkChange:PM_TEXTSIZE]) {
		self.textSize = cf.textSize;
	}
	if ([cf checkChange:PM_UNDERLINE]) {
		self.underline = cf.underline;
	}
}

-(FDCharFormat *)clone
{
	FDCharFormat * fce = [[FDCharFormat alloc] init];
	return [fce copyFrom:self];
}

-(void)setFontName:(NSString *)string forced:(BOOL)b
{
	self.fontName = string;
	_forcedFontName = b;
}



@end
