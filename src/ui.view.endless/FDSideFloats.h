//
//  FDSideFloats.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@interface FDSideFloats : NSObject {
	float items[7];
}

-(float)getSideValue:(int)side;
-(void)setSide:(int)side value:(float)val;
-(void)copyFrom:(FDSideFloats *)obj;

@end
