//
//  FDPartSpace.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDPartSized.h"
#import "FDTypeface.h"


@interface FDPartSpace : FDPartSized

@property NSMutableDictionary * format;
@property BOOL breakLine;
@property BOOL tab;
@property int backgroundColor;
@property FDTypeface * typeface;

-(void)applyFont;
-(float)getBaseWidth;


@end
