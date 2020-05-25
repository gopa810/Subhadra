//
//  FDParaFormat.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDParaFormat.h"
#import "FDSelection.h"
#import "FDSideFloats.h"
#import "FDSideIntegers.h"

NSMutableDictionary * g_sharedLines;
NSMutableDictionary * g_sharedBackgrounds;


@implementation FDParaFormat

-(id)init
{
	self = [super init];
	if (self) {
		// 0 - justified, 1 - left, 2 - center, 3 - right
		_align = 0;
		// multiply of default line height 1 1.5 1.25 etc
		_lineHeight = 1;
		_firstIndent = 0;
		_backgroundColor = 0;
		self.borderColor = [[FDSideIntegers alloc] init];
		self.borderWidth = [[FDSideFloats alloc] init];
		self.padding = [[FDSideFloats alloc] init];
		self.margins = [[FDSideFloats alloc] init];
        self.imageAfterHide = NO;
        self.imageBeforeHide = NO;
	}
	
	return self;
}

-(void)copyFrom:(FDParaFormat *)paraFormat {
    
    self.levelName = paraFormat.levelName;
    self.styleName = paraFormat.styleName;
	self.align = paraFormat.align;
	self.lineHeight= paraFormat.lineHeight;
	self.firstIndent = paraFormat.firstIndent;
	self.backgroundColor = paraFormat.backgroundColor;
	[self.borderColor copyFrom:paraFormat.borderColor];
	[self.borderWidth copyFrom:paraFormat.borderWidth];
	[self.padding copyFrom:paraFormat.padding];
	[self.margins copyFrom:paraFormat.margins];
    self.imageAfter = paraFormat.imageAfter;
    self.imageAfterWidth = paraFormat.imageAfterWidth;
    self.imageBefore = paraFormat.imageBefore;
    self.imageBeforeWidth = paraFormat.imageBeforeWidth;
    self.imageBeforeHide = paraFormat.imageBeforeHide;
    self.imageAfterHide = paraFormat.imageAfterHide;
}

-(float)getMargin:(int)side {
	return [self.margins getSideValue:side];
}

-(float)getBorderWidth:(int)side {
    
	return [self.borderWidth getSideValue:side];
}

-(int)getBorderColor:(int)side {
    
	return [self.borderColor getSideValue:side];
}

-(float)getPadding:(int)side {
    
	return [self.padding getSideValue:side];
}


+(void)initialize
{
	g_sharedLines = [[NSMutableDictionary alloc] init];
	g_sharedBackgrounds = [[NSMutableDictionary alloc] init];
}

+(NSMutableDictionary *)sharedLines
{
	return g_sharedLines;
}

+(NSMutableDictionary *)sharedBackgrounds
{
	return g_sharedBackgrounds;
}




@end
