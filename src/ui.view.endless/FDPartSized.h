//
//  FDPartSized.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDPartBase.h"
@class FDLink;

@interface FDPartSized : FDPartBase

@property FDLink * link;
@property float desiredWidth;
@property float desiredHeight;
@property float desiredTop;
@property float desiredBottom;

-(float)getWidth;
-(float)getHeight;

@end
