//
//  VBDimensions.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/18/13.
//
//

#import "VBDimensions.h"
#import "VBMainServant.h"

@implementation VBDimensions


+(float)headerHeight
{
    return [VBMainServant isIPAD] ? 100.0 : 40.0;
}

@end
