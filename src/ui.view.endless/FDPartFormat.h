//
//  FDPartFormat.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDPartBase.h"

@interface FDPartFormat : FDPartBase

@property int property;
@property float floatValue;
@property (copy) NSString * stringValue;
@property int intValue;

+(int)FONT_SIZE;

@end
