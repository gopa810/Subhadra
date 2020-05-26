//
//  FDSideIntegers.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@interface FDSideIntegers : NSObject {
	int items[7];
}

-(int)getSideValue:(int)side;
-(void)setSide:(int)side value:(int)val;
-(void)copyFrom:(FDSideIntegers *)obj;

@end
