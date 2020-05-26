//
//  FDPartBase.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@class FDParagraphLine;

@interface FDPartBase : NSObject


@property BOOL hidden;
@property int orderNo;
@property int selected;
@property (weak) FDParagraphLine * parentLine;
@property CGFloat calculatedHeight;
@property BOOL highlighted;


-(float)getWidth;
-(int)length;

@end
