//
//  FDParagraphLine.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>

@class FDParagraph;

@interface FDParagraphLine : NSObject

// relative offset X to the left of para
@property float startOffsetX;
// relative offset Y to the top of paragraph
@property float startOffsetY;
// total height of line
@property float height;
// total width of line
@property float width;
// distance from base line to top of line
@property float topOffsetText;
@property float topOffsetImage;
// distance from base line to bottom of line
@property float bottomOffset;

@property int orderNo;

@property (weak) FDParagraph * parent;

@property NSMutableArray * parts;



-(id)initWithParagraph:(FDParagraph *)par;
-(float)topOffset;

-(void)mergeTopText:(float)top;
-(void)mergeTopImage:(float)top;
-(void)mergeBottom:(float)bottom;

@end
