//
//  FDPartString.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDPartSized.h"
#import "FDTypeface.h"

@interface FDPartString : FDPartSized

@property NSMutableDictionary * format;
@property (copy) NSString * text;
@property int backgroundColor;
@property FDTypeface * typeface;

-(void)applyFont;

@end
