//
//  FDSelection.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

#define FDSELECTION_NONE   0x0
#define FDSELECTION_MIDDLE 0x1
#define FDSELECTION_FIRST  0x10
#define FDSELECTION_LAST   0x20

@interface FDSelection : NSObject

+(int)None;
+(int)Middle;
+(int)First;
+(int)Last;

@end
