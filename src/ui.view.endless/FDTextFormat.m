//
//  FDTextFormat.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDTextFormat.h"
#import "FDParaFormat.h"
#import "FDCharFormat.h"
#import "sides_const.h"
#import "FDSideFloats.h"
#import "FDSideIntegers.h"

@implementation FDTextFormat


-(id)init
{
	self = [super init];
	if (self) {
		self.paraFormat = [[FDParaFormat alloc] init];
		self.textFormat = [[FDCharFormat alloc] init];
        [self.textFormat initDefaults];
	}
	return self;
}

-(int)colorFromString:(NSString *)str
{
    unsigned int color = 0;
    if ([str hasPrefix:@"#"]) {
        NSScanner *scanner = [NSScanner scannerWithString:str];
        
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&color];
        
        color |= 0xff000000;
    }

    return color;
}

-(float)dimensionFromString:(NSString *)value
{
    BOOL isPt = false;
    BOOL isPerc = false;
    double d = 0.0;
    if ([value hasSuffix:@"pt"]) {
        value = [value substringToIndex:value.length - 2];
        isPt = true;
    } else if ([value hasSuffix:@"%"]) {
        value = [value substringToIndex:value.length - 1];
        isPerc = true;
    }
    d = [value doubleValue];
    if (isPt) {
        
    } else if (isPerc) {
        d = d * 14.0 / 100.0;
    } else {
        d = d * 72.0;
    }
    return (float)d;
}

-(void)setHtmlProperty:(NSString *)namex value:(NSString *)valuex
{
    if ([namex isEqualToString:@"text-indent"]) {
        _paraFormat.firstIndent = [self dimensionFromString:valuex];
    } else if ([namex isEqualToString:@"margin-left"]) {
        [_paraFormat.margins setSide:SIDE_LEFT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"margin-right"]) {
        [_paraFormat.margins setSide:SIDE_RIGHT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"margin-top"]) {
        [_paraFormat.margins setSide:SIDE_TOP value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"margin-bottom"]) {
        [_paraFormat.margins setSide:SIDE_BOTTOM value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"padding-left"]) {
        [_paraFormat.padding setSide:SIDE_LEFT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"padding-right"]) {
        [_paraFormat.padding setSide:SIDE_RIGHT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"padding-top"]) {
        [_paraFormat.padding setSide:SIDE_TOP value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"padding-bottom"]) {
        [_paraFormat.padding setSide:SIDE_BOTTOM value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"padding"]) {
        [_paraFormat.padding setSide:SIDE_ALL value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"background-color"]) {
        _paraFormat.backgroundColor = [self colorFromString:valuex];
        _textFormat.backgroundColor = [self colorFromString:valuex];
    } else if ([namex isEqualToString:@"border-left-color"]) {
        [_paraFormat.borderColor setSide:SIDE_LEFT value:[self colorFromString:valuex]];
    } else if ([namex isEqualToString:@"border-right-color"]) {
        [_paraFormat.borderColor setSide:SIDE_RIGHT value:[self colorFromString:valuex]];
    } else if ([namex isEqualToString:@"border-top-color"]) {
        [_paraFormat.borderColor setSide:SIDE_TOP value:[self colorFromString:valuex]];
    } else if ([namex isEqualToString:@"border-bottom-color"]) {
        [_paraFormat.borderColor setSide:SIDE_BOTTOM value:[self colorFromString:valuex]];
    } else if ([namex isEqualToString:@"border-left-width"]) {
        [_paraFormat.borderWidth setSide:SIDE_LEFT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"border-right-width"]) {
        [_paraFormat.borderWidth setSide:SIDE_RIGHT value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"border-top-width"]) {
        [_paraFormat.borderWidth setSide:SIDE_TOP value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"border-bottom-width"]) {
        [_paraFormat.borderWidth setSide:SIDE_BOTTOM value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"border-color"]) {
        [_paraFormat.borderColor setSide:SIDE_ALL value:[self colorFromString:valuex]];
    } else if ([namex isEqualToString:@"border-width"]) {
        [_paraFormat.borderWidth setSide:SIDE_ALL value:[self dimensionFromString:valuex]];
    } else if ([namex isEqualToString:@"color"]) {
        _textFormat.foregroundColor = [self colorFromString:valuex];
    } else if ([namex isEqualToString:@"font-family"]) {
        _textFormat.fontName = valuex;
    } else if ([namex isEqualToString:@"font-size"]) {
        _textFormat.textSize = [self dimensionFromString:valuex];
    } else if ([namex isEqualToString:@"font-style"]) {
        if ([valuex isEqualToString:@"italic"]) {
            _textFormat.italic = (true);
        } else if ([valuex isEqualToString:@"normal"]) {
            _textFormat.italic = (false);
        }
    } else if ([namex isEqualToString:@"font-weight"]) {
        if ([valuex isEqualToString:@"bold"]) {
            _textFormat.bold = (true);
        } else if ([valuex isEqualToString:@"normal"]) {
            _textFormat.bold = (false);
        }
    } else if ([namex isEqualToString:@"line-height"]) {
        _paraFormat.lineHeight = [self dimensionFromString:valuex] / 14;
    } else if ([namex isEqualToString:@"text-align"]) {
        if ([valuex isEqualToString:@"center"]) {
            _paraFormat.align = ALIGN_CENTER;
        } else if ([valuex isEqualToString:@"right"]) {
            _paraFormat.align = ALIGN_RIGHT;
        } else if ([valuex isEqualToString:@"left"]) {
            _paraFormat.align = ALIGN_LEFT;
        } else {
            _paraFormat.align = ALIGN_JUST;
        }
    } else if ([namex isEqualToString:@"text-decoration"]) {
        if ([valuex isEqualToString:@"line-through"]) {
            _textFormat.strikeOut = (true);
            _textFormat.underline = (false);
        } else if ([valuex isEqualToString:@"underline"]) {
            _textFormat.strikeOut = (false);
            _textFormat.underline = (true);
        } else if ([valuex isEqualToString:@"normal"]) {
            _textFormat.strikeOut = (false);
            _textFormat.underline = (false);
        }
    } else if ([namex isEqualToString:@"visibility"]) {
        if ([valuex isEqualToString:@"hidden"]) {
            _textFormat.hidden = (true);
        } else if ([valuex isEqualToString:@"visible"]) {
            _textFormat.hidden = (false);
        }
    } else if ([namex isEqualToString:@"image-before"]) {
        _paraFormat.imageBefore = valuex;
    } else if ([namex isEqualToString:@"image-before-size"]) {
        _paraFormat.imageBeforeWidth = [self dimensionFromString:valuex];
    } else if ([namex isEqualToString:@"image-after"]) {
        _paraFormat.imageAfter = valuex;
    } else if ([namex isEqualToString:@"image-after-size"]) {
        _paraFormat.imageAfterWidth = [self dimensionFromString:valuex];
    }
    
}


@end
