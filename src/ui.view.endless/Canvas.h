//
//  Canvas.h
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import <Foundation/Foundation.h>
#import "FDHighlightTracker.h"
#import "FDTextHighlighter.h"
#import "FDRecordLocation.h"

@interface Canvas : NSObject

@property CGContextRef context;
@property (weak) FDHighlightTracker * anchor;
@property (weak) FDTextHighlighter * phrases;
@property (weak) FDRecordLocationPair * orderedPoints;

@property BOOL startSelectionValid;
@property BOOL endSelectionValid;
@property CGPoint startSelectionPointA;
@property CGPoint startSelectionPointB;
@property CGRect startSelectionRect;
@property CGPoint endSelectionPointA;
@property CGPoint endSelectionPointB;
@property CGRect endSelectionRect;

-(void)setStrokeColor:(UIColor *)color;
-(void)setFillColor:(UIColor *)color;
-(void)setFillColorRef:(CGColorRef)color;
-(void)setStrokeWidth:(float)width;
-(void)moveToPoint:(CGPoint)point;
-(void)lineTo:(CGPoint)point;
-(void)fillCircleWithCornersLeft:(float)xLeft top:(float)yTop right:(float)xRight bottom:(float)yBottom;
-(void)strokeCircleWithCornersLeft:(float)xLeft top:(float)yTop right:(float)xRight bottom:(float)yBottom;
-(void)strokeRect:(CGRect)rect;
-(void)fillRect:(CGRect)rect;
-(void)strokeCircleWithRect:(CGRect)rect;
-(void)fillCircleWithRect:(CGRect)rect;
-(void)drawImage:(UIImage *)image rect:(CGRect)rect;
-(void)lineFrom:(CGPoint)fp to:(CGPoint)tp;


-(void)drawSelectionStart;
-(void)drawSelectionEnd;
-(void)saveState;
-(void)restoreState;

@end
