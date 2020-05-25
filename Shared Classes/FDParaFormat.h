//
//  FDParaFormat.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "sides_const.h"

@class FDSideFloats;
@class FDSideIntegers;

@interface FDParaFormat : NSObject

@property NSString * levelName;
@property NSString * styleName;
@property int align;
@property float lineHeight;
@property float firstIndent;
@property int backgroundColor;
@property FDSideFloats * margins;
@property FDSideFloats * borderWidth;
@property FDSideFloats * padding;
@property FDSideIntegers * borderColor;
@property NSString * imageBefore;
@property NSString * imageAfter;
@property float imageBeforeWidth;
@property float imageAfterWidth;
@property BOOL imageAfterHide;
@property BOOL imageBeforeHide;

// global properties
+(NSMutableDictionary *)sharedLines;
+(NSMutableDictionary *)sharedBackgrounds;

// instance properties
-(float)getMargin:(int)side;
-(float)getBorderWidth:(int)side;
-(int)getBorderColor:(int)side;
-(float)getPadding:(int)side;
-(void)copyFrom:(FDParaFormat *)paraFormat;

@end
