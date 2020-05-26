//
//  FDTextFormat.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
@class FDParaFormat, FDCharFormat;

@interface FDTextFormat : NSObject

@property (copy) NSString * name;
@property FDParaFormat * paraFormat;
@property FDCharFormat * textFormat;
@property int styleId;

-(void)setHtmlProperty:(NSString *)namex value:(NSString *)value;

@end
