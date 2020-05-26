//
//  FDCharFormatStack.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/01/15.
//
//

#import "FDCharFormatStack.h"
#import "FDTypeface.h"
#import "FDColor.h"
#import "FDCharFormat.h"

@implementation FDCharFormatStackItem

-(id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

@end

@implementation FDCharFormatStack

//
// initialization of object
//

-(id)init
{
    self = [super init];
    if (self)
    {
        self.stack = [NSMutableArray new];
    }
    return self;
}

//
// remove all instances of key in main array
//

-(void)removeKey:(NSString *)tag
{
    if (self.stack.count > 0)
    {
        NSInteger i = (NSInteger)self.stack.count - 1;
        for (;i >= 0; i--) {
            FDCharFormatStackItem * item = [self.stack objectAtIndex:i];
            if ([item.tag isEqualToString:tag])
            {
                [self.stack removeObjectAtIndex:i];
            }
        }
    }
}

//
// keys have priority
// highest priority has LEVEL, then PARAGRAPH STYLE, then all other styles
//
-(int)keyPriority:(NSString *)key
{
    if ([key isEqualToString:@"LV"])
        return 0;
    if ([key isEqualToString:@"PS"])
        return 1;
    return 2;
}

-(void)setValue:(id)value forKey:(NSString *)tag
{
    [self removeKey:tag];
    
    FDCharFormatStackItem * item = [FDCharFormatStackItem new];
    item.tag = tag;
    item.value = value;
    item.valueType = ([value isKindOfClass:[NSDictionary class]] ? 2 : 1);
    if ([self keyPriority:tag] == 2)
    {
        [self.stack addObject:item];
    }
    else
    {
        BOOL done = NO;
        for (NSUInteger i = 0; i < self.stack.count; i++) {
            NSString * ct = [(FDCharFormatStackItem *)[self.stack objectAtIndex:i] tag];
            if ([self keyPriority:ct] > [self keyPriority:tag])
            {
                [self.stack insertObject:item atIndex:i];
                done = YES;
                break;
            }
        }
        if (!done)
        {
            [self.stack addObject:item];
        }
    }
}

-(id)valueForKey:(NSString *)tag
{
    for(int i = (int)self.stack.count-1; i >= 0; i--)
    {
        FDCharFormatStackItem * si = [self.stack objectAtIndex:i];
        if ([si.tag isEqualToString:tag])
        {
            return si.value;
        }
        else if (si.valueType == 2)
        {
            NSDictionary * d = si.value;
            if ([d valueForKey:tag] != nil)
                return [d valueForKey:tag];
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark character formatting

-(float)textSize
{
    NSNumber * n = [self valueForKey:@"PT"];
    if (n == nil)
        return [FDTypeface defaultFontSize];
    return [n floatValue];
}

-(NSString *)fontName
{
    NSString * str = [self valueForKey:@"FT"];
    if (str != nil)
        return str;
    return [FDTypeface defaultFontName];
}

-(int)backgroundColor
{
    NSNumber * n;
    n = [self valueForKey:@"HL"];
    if (n != nil)
        return [n intValue];
    n = [self valueForKey:@"BC"];
    if (n == nil)
        return 0;
    return [n intValue];
}

-(void)setBackgroundColor:(int)value
{
    [self setValue:[NSNumber numberWithInt:value] forKey:@"BC"];
}

-(BOOL)bold
{
    NSNumber * n = [self valueForKey:@"BD"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setBold:(BOOL)value
{
    [self setValue:[NSNumber numberWithBool:value] forKey:@"BD"];
}

-(BOOL)hidden
{
    NSNumber * n = [self valueForKey:@"HD"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setHidden:(BOOL)value
{
    [self setValue:[NSNumber numberWithBool:value] forKey:@"HD"];
}

-(BOOL)underline
{
    NSNumber * n = [self valueForKey:@"UN"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setUnderline:(BOOL)value
{
    [self setValue:[NSNumber numberWithBool:value] forKey:@"UN"];
}

-(BOOL)strikeOut
{
    NSNumber * n = [self valueForKey:@"SO"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setStrikeOut:(BOOL)value
{
    [self setValue:[NSNumber numberWithBool:value] forKey:@"SO"];
}

-(BOOL)italic
{
    NSNumber * n = [self valueForKey:@"IT"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(void)setItalic:(BOOL)value
{
    [self setValue:[NSNumber numberWithBool:value] forKey:@"IT"];
}

-(BOOL)superScript
{
    NSNumber * n = [self valueForKey:@"SP"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(BOOL)subScript
{
    NSNumber * n = [self valueForKey:@"SB"];
    if (n == nil)
        return NO;
    return [n boolValue];
}

-(int)foregroundColor
{
    NSNumber * n = [self valueForKey:@"FC"];
    if (n == nil)
        return 0;
    return [n intValue];
}

-(void)setForegroundColor:(int)value
{
    [self setValue:[NSNumber numberWithInt:value] forKey:@"FC"];
}

#pragma mark -
#pragma mark Formatting Management

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
    
    if ([FDTypeface isGeneralFontName:self.fontName]) {
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


@end
