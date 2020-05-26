//
//  FDParagraph.m
//  VedabaseB
//
//  Created by Peter Kollath on 02/08/14.
//
//

#import "FDParagraph.h"
#import "sides_const.h"
#import "FDRecordPart.h"
#import "FDParaFormat.h"
#import "FDCharFormat.h"
#import "FDParagraphLine.h"
#import "FDPartBase.h"
#import "FDPartString.h"
#import "FDPartSpace.h"
#import "FDPartImage.h"
#import "FDColor.h"
#import "FDRecordLocation.h"
#import "FDSelection.h"
#import "Canvas.h"
#import "FDRecordLocation.h"
#import "FDSideIntegers.h"
#import "FDSideFloats.h"
#import "VBHighlighterAnchor.h"
#import "FDHighlightTracker.h"
#import "FDTextHighlighter.h"
#import "EndlessTextViewSkinDelegate.h"
#import "VBMainServant.h"

UIColor * g_selectionBackgroundColor;

@implementation FDParagraph

+(void)initialize
{
    g_selectionBackgroundColor = [FDColor getColor:0xffaaaaff];
}

-(id)init
{
    if ((self = [super init]) != nil) {
        self.borderBottom = -1;
        self.borderLeft = -1;
        self.borderRight = -1;
        self.borderTop = -1;
        self.clientTop = -1;
        self.evaluateHighlightedWords = YES;
        self.lines = [[NSMutableArray alloc] init];
        self.layoutHeight = 0;
        self.layoutWidth = -1;
    }
    return self;
}

- (void)initiateParagraphImages
{
    if (self.paraFormat.imageAfter != nil && self.imageAfter == nil)
    {
        self.imageAfter = [VBMainServant imageForName:self.paraFormat.imageAfter];
        CGSize size = self.imageAfter.size;
        if (self.paraFormat.imageAfterWidth > 10)
        {
            self.imageAfterSize = CGSizeMake(self.paraFormat.imageAfterWidth, size.height * self.paraFormat.imageAfterWidth / size.width);
        }
        else
        {
            self.imageAfterSize = size;
        }
    }
    
    if (self.paraFormat.imageBefore != nil && self.imageBefore == nil)
    {
        self.imageBefore = [VBMainServant imageForName:self.paraFormat.imageBefore];
        CGSize size = self.imageBefore.size;
        if (self.paraFormat.imageBeforeWidth > 10)
        {
            self.imageBeforeSize = CGSizeMake(self.paraFormat.imageBeforeWidth, size.height * self.paraFormat.imageBeforeWidth / size.width);
        }
        else
        {
            self.imageBeforeSize = size;
        }
    }
}

-(CGFloat)validateForWidth:(CGFloat)width
{
    // if drawing images before and after para is allowed
    if (YES)
    {
        [self initiateParagraphImages];
    }
    
    self.borderLeft = [self.paraFormat getMargin:SIDE_LEFT]
                 + [self.paraFormat getBorderWidth:SIDE_LEFT] / 2;
    float left = self.borderLeft
                 + [self.paraFormat getBorderWidth:SIDE_LEFT]/2
                 + [self.paraFormat getPadding:SIDE_LEFT];
    self.borderRight = width - [self.paraFormat getMargin:SIDE_RIGHT]
                 - [self.paraFormat getBorderWidth:SIDE_RIGHT]/2;
    float right = self.borderRight
                 - [self.paraFormat getBorderWidth:SIDE_RIGHT]/2
                 - [self.paraFormat getPadding:SIDE_RIGHT];

    self.borderTop = 0;
    if (self.imageBefore) {
        self.borderTop = self.imageBeforeSize.height;
    }
    self.borderTop += [self.paraFormat getMargin:SIDE_TOP]
                 + [self.paraFormat getBorderWidth:SIDE_TOP]/2
                    * [FDCharFormat multiplySpaces];
    float top = self.borderTop
                 + [self.paraFormat getBorderWidth:SIDE_TOP]/2
                 + [self.paraFormat getPadding:SIDE_TOP];
    self.clientTop = top;
    
    float borderBottomAdd = [self.paraFormat getPadding:SIDE_BOTTOM]
                 + [self.paraFormat getBorderWidth:SIDE_BOTTOM] / 2;
    float bottomAdd = [self.paraFormat getBorderWidth:SIDE_BOTTOM] / 2
                 + [self.paraFormat getMargin:SIDE_BOTTOM]
                    * [FDCharFormat multiplySpaces];
    

    
    //Log.i("drawe", String.format("[Para] top %f, bottom %f", top, borderBottomAdd + bottomAdd));
    // width is total width of paragraph
    // we have to subtract left border width, padding and margin
    // the same for right border width, padding and margin
    [self.lines removeAllObjects];
    FDParagraphLine * currentLine = [[FDParagraphLine alloc] initWithParagraph:self];
                      [self.lines addObject:currentLine];
    float currentWidth = left + [self.paraFormat firstIndent] * [FDCharFormat multiplyFontSize];
    self.layoutWidth = width;
    //CGRect bounds;
    
    NSDictionary * lastPaint = nil;
    self.calculatedMaxWidth = 0;
    self.calculatedMinWidth = 0;
    //
    // first step: distribute elements to lines
    //
    int order = 0;
    for(FDPartBase * part in self.parts) {
        part.orderNo = order;
        CGSize bounds = CGSizeZero;
        if ([part isKindOfClass:[FDPartString class]]) {
            // string element
            FDPartString * strp = (FDPartString *)part;
            if (strp.hidden) {
                strp.desiredWidth = 0;
            } else {
                [strp applyFont];
                lastPaint = strp.format;
                //fm = lastPaint.typeface;
                //Log.i("drawe", String.format("[Format] top:%f, bottom:%f, ascent:%f", fm.top, fm.bottom, fm.ascent));
                bounds = [strp.text sizeWithAttributes:strp.format];
                //Log.i("drawe", String.format("[Height] %f", strp.format.getTextSize()));
                strp.desiredWidth = bounds.width;
                strp.desiredHeight = bounds.height;
            }
            if (strp.desiredWidth + currentWidth > right) {
                currentLine = [[FDParagraphLine alloc] initWithParagraph:self];
                [self.lines addObject:currentLine];
                currentWidth = left;
            }
            [currentLine.parts addObject:strp];
            [currentLine mergeTopText:bounds.height];//(-fm.ascender + fm.leading)];
            [currentLine mergeBottom:0];//(-fm.descender)];
            
            currentWidth += strp.desiredWidth;
            currentLine.width = currentWidth;
            if (strp.desiredWidth > self.calculatedMinWidth)
            {
                self.calculatedMinWidth = strp.desiredWidth;
            }
            if (self.calculatedMaxWidth < currentWidth)
            {
                self.calculatedMaxWidth = currentWidth;
            }
            
        } else if ([part isKindOfClass:[FDPartSpace class]]) {
            // space element
            FDPartSpace * spc = (FDPartSpace *)part;
            if (spc.breakLine) {
                [currentLine.parts addObject:spc];
                currentLine = [[FDParagraphLine alloc] initWithParagraph:self];
                [self.lines addObject:currentLine];
                currentWidth = left;
                spc.desiredWidth = 0;
            } else {
                if (lastPaint != nil) {
                    spc.desiredWidth = [spc getBaseWidth];
                } else {
                    spc.desiredWidth = 14;
                }
                spc.desiredHeight = 0;
                [currentLine.parts addObject:spc];
            }
            currentWidth += spc.desiredWidth;
            currentLine.width = currentWidth;
        } else if ([part isKindOfClass:[FDPartImage class]]) {
            // image element
            FDPartImage * img = (FDPartImage *)part;
            if (img.desiredWidth + currentWidth > right) {
                currentLine = [[FDParagraphLine alloc] initWithParagraph:self];
                [self.lines addObject:currentLine];
                currentWidth = left;
                if (img.bitmap != nil) {
                    if (img.desiredWidth > width && width > 1)
                    {
                        CGFloat ratio = width / img.desiredWidth;
                        img.desiredWidth = width;
                        img.desiredHeight = img.desiredHeight * ratio;
                    }
                }

            }
            [currentLine.parts addObject:img];
            //Log.i("drawq", "topOffset: " + currentLine.topOffset + " img.height");
            [currentLine mergeTopImage:img.desiredHeight];
            //Log.i("drawq", "topOffset after: " + currentLine.topOffset);
            
            currentWidth += img.desiredWidth;
            currentLine.width = currentWidth;
            if (img.desiredWidth > self.calculatedMinWidth)
            {
                self.calculatedMinWidth = img.desiredWidth;
            }
            if (self.calculatedMaxWidth < currentWidth)
            {
                self.calculatedMaxWidth = currentWidth;
            }
        }
        part.parentLine = currentLine;
        order++;
    }
    
    // currentLine contains last line

    //
    // second step: determine line heights
    //
    float start = top;
    //float prevLineBottom = top;
    float startX = left + self.paraFormat.firstIndent * [FDCharFormat multiplyFontSize];
    for(FDParagraphLine * line in self.lines) {
        // each line has topOffset and bottomOffset
        // when painting the paragraph, we start at offsetY = 0
        // we add line's height and draws text there
        // then we add line's subheight so next line will start with adding its height
        
        // line's height is calculated as topOffset * lineHeight (from para formatting)
        // line's subheight is bottomOffset
        
        // therefore we just multiply topOffset with lineHeight
        //Log.i("drawe", String.format("line.topOffset: %f, paraFormat.lineHeight: %f", line.topOffset, paraFormat.lineHeight));
        if (self.paraFormat.lineHeight > 0.3) {
            line.topOffsetText *= self.paraFormat.lineHeight * FDCharFormat.multiplySpaces;
        }
        line.startOffsetY = start;// + line.topOffset;
        line.startOffsetX = startX;
        startX = left;
        //Log.i("drawe", "line.startOffsetY:" + line.startOffsetY);
        line.height = line.topOffset;//(line.topOffset - line.bottomOffset * FDCharFormat.multiplySpaces);
        //line.height = start - prevLineBottom;
        start += line.height;
        //NSLog(@"drawy       line height: %f, start: %f", line.height, start);
    }
    
    float workWidth = right /*- left*/ - self.paraFormat.firstIndent * FDCharFormat.multiplyFontSize;
    if (self.paraFormat.align == ALIGN_CENTER) {
        for(FDParagraphLine * line in self.lines) {
            line.startOffsetX += (workWidth - line.width) / 2;
            workWidth = right;
        }
    } else if (self.paraFormat.align == ALIGN_RIGHT) {
        for(FDParagraphLine * line in self.lines) {
            line.startOffsetX += (workWidth - line.width);
            workWidth = right;
        }
    } else if (self.paraFormat.align == ALIGN_JUST) {
        for(FDParagraphLine * line in self.lines) {
            // currentLine contains last line added to the para
            // and when alignment is JUSTIFY, then we dont align
            // last line
            if (line == currentLine)
                break;
            
            // we need to add some width to each space in the line
            float addWidth = (workWidth - line.width);
            if (addWidth < 0) {
//                Log.i("drawe", "addWidth = " + addWidth + "  record: ");
                addWidth = 0;
            }
            int spaces = 0;
            BOOL lastIsSpace = NO;
            for(FDPartBase * part in line.parts) {
                lastIsSpace = NO;
                if ([part isKindOfClass:[FDPartSpace class]]) {
                    FDPartSpace * spc = (FDPartSpace *)part;
                    if (!spc.breakLine) {
                        spaces++;
                        lastIsSpace = true;
                    } else {
                        // if last is <CR>
                        // then we dont need adjust space widths
                        // we can accomplish this by setting 0 spaces count
                        lastIsSpace = NO;
                        spaces = 0;
                        break;
                    }
                }
            }
            
            if (lastIsSpace)
                spaces--;
            
            if (spaces > 0) {
                for(FDPartBase * part in line.parts) {
                    if ([part isKindOfClass:[FDPartSpace class]]) {
                        FDPartSpace * spc = (FDPartSpace *)part;
                        if (!spc.breakLine) {
                            spc.desiredWidth += (addWidth / spaces);
                        }
                    }
                }
            }
            workWidth = right;
        }			
    }
    
    // we adjust bottom dimensions
    self.borderBottom = start + borderBottomAdd;
    self.layoutHeight = self.borderBottom + bottomAdd;
    if (self.imageAfter)
    {
        self.layoutHeight += self.imageAfterSize.height;
    }

    
//    NSLog(@"drawy      returned part subheight: %f, %f", self.layoutHeight, start);

    
    return self.layoutHeight;

}


- (void)fillSelectedParaBackground:(Canvas *)canvas yStart:(CGFloat)yStart xStart:(CGFloat)xStart
{
    CGContextSaveGState(canvas.context);
    [canvas setFillColor:g_selectionBackgroundColor];
    [canvas setStrokeWidth:2.0];
    [canvas setStrokeColor:[UIColor blueColor]];

    [canvas fillRect:CGRectMake(xStart, yStart, self.layoutWidth, self.layoutHeight)];

    if ((self.selected & FDSelection.First) != 0) {
        
        canvas.startSelectionPointA = CGPointMake(xStart, yStart);
        canvas.startSelectionPointB = CGPointMake(xStart + self.layoutWidth, yStart);
        canvas.startSelectionRect = CGRectMake(xStart + self.layoutWidth/2 - 2, yStart - 2, 4, 4);
        canvas.startSelectionValid = YES;
        
        if (canvas.orderedPoints.A != nil) {
            canvas.orderedPoints.A.hotSpot = CGPointMake(xStart + self.layoutWidth/2, yStart);
        }
    }
    if ((self.selected & FDSelection.Last) != 0) {
        
        canvas.endSelectionPointA = CGPointMake(xStart, yStart + self.layoutHeight);
        canvas.endSelectionPointB = CGPointMake(xStart + self.layoutWidth, yStart + self.layoutHeight);
        canvas.endSelectionRect = CGRectMake(xStart + self.layoutWidth/2 - 2, yStart + self.layoutHeight - 2, 4, 4);
        canvas.endSelectionValid = YES;

        if (canvas.orderedPoints.B != nil) {
            canvas.orderedPoints.B.hotSpot = CGPointMake(xStart + self.layoutWidth/2, yStart + self.layoutHeight);
        }
    }
    CGContextRestoreGState(canvas.context);
}

-(void)evaluateHighlighting:(FDTextHighlighter *)phrases
{
    [super evaluateHighlighting:phrases];

    if (phrases)
    {
        for (FDPartBase * part in self.parts)
        {
            if ([part isKindOfClass:[FDPartString class]])
            {
                FDPartString * ps = (FDPartString *)part;
                
                for (FDTextHighlightPhrase * phrase in phrases.phrases)
                {
                    if ([phrase testPart:ps])
                    {
                        if ([phrase isCompleteMatch])
                        {
                            [phrase highlightParts];
                            [phrase reset];
                        }
                    }
                }
            }
        }
    }
}

-(CGFloat)drawWithCanvas:(Canvas *)canvas xstart:(CGFloat)xStart ystart:(CGFloat)yStart
{
     
     float x = xStart, y = yStart;
    CGFloat xStart2 = xStart;
    CGFloat yStart2 = yStart;
     //FDPaint * p;

    UIColor * color;
    float stroke;
    
    if (self.evaluateHighlightedWords)
    {
        [self evaluateHighlighting:canvas.phrases];
        self.evaluateHighlightedWords = NO;
    }
    
    if (self.imageBefore)
    {
        yStart += self.imageBeforeSize.height;
    }
    
     if (canvas.anchor != nil) {
//         Log.i("high", "not null anch");
     }
     // painting border
     if (self.selected != FDSelection.None) {
         [self fillSelectedParaBackground:canvas yStart:yStart2 xStart:xStart];
     } else {
         color = [FDColor getColor:self.paraFormat.backgroundColor];
         if (color) {
             [canvas setFillColor:color];
             [canvas fillRect:CGRectMake(xStart + self.borderLeft, yStart2 + self.borderTop, self.borderRight - self.borderLeft, self.borderBottom - self.borderTop)];
         }
     }

    if (self.imageBefore)
    {
        xStart2 = xStart + (self.layoutWidth - self.imageBeforeSize.width) / 2;
        [canvas drawImage:self.imageBefore rect:CGRectMake(xStart2, yStart2 + self.borderTop - self.imageBeforeSize.height, self.imageBeforeSize.width, self.imageBeforeSize.height)];
    }
    
    color = [FDColor getColor:[self.paraFormat.borderColor getSideValue:SIDE_LEFT]];
    stroke = [self.paraFormat.borderWidth getSideValue:SIDE_LEFT];
    if (color != nil && stroke > 0) {
        [canvas setStrokeColor:color];
        [canvas setStrokeWidth:stroke];
        [canvas lineFrom:CGPointMake(xStart + self.borderLeft, yStart + self.borderTop)
                      to:CGPointMake(xStart + self.borderLeft, yStart + self.borderBottom)];
//        [canvas moveToPoint:CGPointMake()];
//        [canvas lineTo:CGPointMake(xStart + self.borderLeft, yStart + self.borderBottom)];
    }

    color = [FDColor getColor:[self.paraFormat.borderColor getSideValue:SIDE_RIGHT]];
    stroke = [self.paraFormat.borderWidth getSideValue:SIDE_RIGHT];
    if (color != nil && stroke > 0) {
        [canvas setStrokeColor:color];
        [canvas setStrokeWidth:stroke];
        [canvas lineFrom:CGPointMake(xStart + self.borderRight, yStart + self.borderTop)
                      to:CGPointMake(xStart + self.borderRight, yStart + self.borderBottom)];
    }

    color = [FDColor getColor:[self.paraFormat.borderColor getSideValue:SIDE_TOP]];
    stroke = [self.paraFormat.borderWidth getSideValue:SIDE_TOP];
    if (color != nil && stroke > 0) {
        [canvas setStrokeColor:color];
        [canvas setStrokeWidth:stroke];
        [canvas lineFrom:CGPointMake(xStart + self.borderLeft, yStart + self.borderTop)
                      to:CGPointMake(xStart + self.borderRight, yStart + self.borderTop)];
    }

    color = [FDColor getColor:[self.paraFormat.borderColor getSideValue:SIDE_BOTTOM]];
    stroke = [self.paraFormat.borderWidth getSideValue:SIDE_BOTTOM];
    if (color != nil && stroke > 0) {
        [canvas setStrokeColor:color];
        [canvas setStrokeWidth:stroke];
        [canvas lineFrom:CGPointMake(xStart + self.borderLeft, yStart + self.borderBottom)
                      to:CGPointMake(xStart + self.borderRight, yStart + self.borderBottom)];
    }
    //NSDictionary * textAttr = [NSDictionary dictionary];
    int highlighterId = -1;

     for(FDParagraphLine * line in self.lines) {

         x = xStart + line.startOffsetX;
         y = yStart2 + line.startOffsetY;
         NSUInteger partsCount = line.parts.count;
         for(NSUInteger partIndex = 0; partIndex < partsCount; partIndex++) {
//         for (FDPartBase * part in line.parts) {
             FDPartBase * part = [line.parts objectAtIndex:partIndex];
             if (canvas.anchor != nil) {
                 canvas.anchor.charCounter += [part length];
                 if (canvas.anchor.anchor && canvas.anchor.anchor.startChar < canvas.anchor.charCounter)
                 {
                     highlighterId = canvas.anchor.anchor.highlighterId - 1;
                     [canvas.anchor nextAnchor];
                 }
             }
             
             if ([part isKindOfClass:[FDPartString class]]) {
                 // string element
                 FDPartString * strp = (FDPartString *)part;
                 if (strp.desiredWidth > 0) {

                     [self drawTextBackground:canvas points:canvas.orderedPoints x:x y:y backgroundColor:[FDColor getColor:strp.backgroundColor] kine:line part:strp];
                     [self drawHighlighter:canvas x:x y:y highlighter:highlighterId line:line part:strp];
                     [self drawSelectionBackground:canvas points:canvas.orderedPoints x:x y:y line:line part:strp];
                     [strp.text drawAtPoint:CGPointMake(x, y) withAttributes:strp.format];
                     x += strp.desiredWidth;

                 }

             } else if ([part isKindOfClass:[FDPartSpace class]]) {
                 // last space should not be drawed
                 if (partIndex == partsCount - 1)
                     break;
                 // space element
                 FDPartSpace * spc = (FDPartSpace *)part;
                 if (!spc.breakLine) {
                     [self drawTextBackground:canvas points:canvas.orderedPoints x:x y:y backgroundColor:[FDColor getColor:spc.backgroundColor] kine:line part:spc];
                     [self drawHighlighter:canvas x:x y:y highlighter:highlighterId line:line part:spc];
                     if (self.selected == FDSelection.None && spc.selected != FDSelection.None) {
                         [self drawSelectionBackground:canvas points:canvas.orderedPoints x:x y:y  line:line part:spc];
                     }
                     x += spc.desiredWidth;
                 }
             } else if ([part isKindOfClass:[FDPartImage class]]) {
                 // image element
                 FDPartImage * img = (FDPartImage *)part;
                 [canvas drawImage:img.bitmap rect:CGRectMake(x, y, img.desiredWidth, img.desiredHeight)];
                 x += img.desiredWidth;
             }
         }
         
     }
    
    if (self.imageAfter)
    {
        xStart2 = xStart + (self.layoutWidth - self.imageAfterSize.width) / 2;
        [canvas drawImage:self.imageAfter rect:CGRectMake(xStart2, yStart2 + self.borderBottom, self.imageAfterSize.width, self.imageAfterSize.height)];
    }
    
     return self.layoutHeight;
}
  
  
                      
-(void)drawTextBackground:(Canvas *)canvas
                 points:(FDRecordLocationPair *)orderedPoints x:(float)x y:(float)y backgroundColor:(UIColor *)bkgColor
                   kine:(FDParagraphLine *)line part:(FDPartSized *)strp
{
    if (bkgColor != 0) {
//        float x1 = x+1;
//        float x2 = x + strp.desiredWidth + 1;
//        float y1 = y;
//        float y2 = y + line.height;
        [canvas setFillColor:bkgColor];
        [canvas fillRect:CGRectMake(x + 1, y, strp.desiredWidth, line.height)];
    }
}

-(void)drawHighlighter:(Canvas *)canvas
                     x:(float)x
                     y:(float)y highlighter:(int)highlighterId line:(FDParagraphLine *)line part:(FDPartSized *)strp
{
    UIColor * p = nil;
    if (highlighterId < 0)
    {
        if (strp.highlighted)
        {
            p = [FDColor getColor:0xffffff00];
        }
    }
    else
    {
        p = [FDColor getColor:[VBHighlighterAnchor getColor:highlighterId]];
    }
    if (p != nil) {
        [canvas setFillColor:p];
        [canvas fillRect:CGRectMake(x+1, y, strp.desiredWidth, line.height)];
    }
}

-(void)drawSelectionBackground:(Canvas *)canvas
                        points:(FDRecordLocationPair *)orderedPoints
                             x:(float)x
                             y:(float)y
                          line:(FDParagraphLine *)line
                          part:(FDPartSized *)strp
{
  if (self.selected == FDSelection.None && strp.selected != FDSelection.None) {
      float x1 = x+1;
      float x2 = x + strp.desiredWidth + 1;
      float y1 = y;
      float y2 = y + line.height;

      [canvas saveState];
      
      [canvas setFillColor:g_selectionBackgroundColor];

      [canvas fillRect:CGRectMake(x1, y1, strp.desiredWidth, line.height)];

      [canvas setFillColor:[UIColor blueColor]];
      [canvas setStrokeColor:[UIColor blackColor]];
      [canvas setStrokeWidth:2.0];

      [canvas restoreState];

      if ((strp.selected & FDSelection.First) != 0) {

          canvas.startSelectionRect = CGRectMake(x1 - 3, y1 - 6, 6, 6);
          canvas.startSelectionPointA = CGPointMake(x1, y1);
          canvas.startSelectionPointB = CGPointMake(x1, y2);
          canvas.startSelectionValid = YES;

          if (orderedPoints.A != nil) {
              orderedPoints.A.hotSpot = CGPointMake(x1, y1 - 4);
          }
      }
      if ((strp.selected & FDSelection.Last) != 0) {
          //[canvas setPaint:selpline];
          canvas.endSelectionRect = CGRectMake(x2 - 3, y2, 6, 6);
          canvas.endSelectionPointA = CGPointMake(x2, y1);
          canvas.endSelectionPointB = CGPointMake(x2, y2);
          canvas.endSelectionValid = YES;

          if (orderedPoints.B != nil) {
              orderedPoints.B.hotSpot = CGPointMake(x2, y2 + 4);
          }
      }
      
  }
}
                      
                      
-(void)getSelectedText:(NSMutableString *)sb
{
  for(FDPartBase * part in self.parts) {
      if ((part.selected | self.selected) == FDSelection.None)
          continue;
      
      if ([part isKindOfClass:[FDPartString class]]) {
          FDPartString * ps = (FDPartString *)part;
          [sb appendString:ps.text];
      } else if ([part isKindOfClass:[FDPartSpace class]]) {
          FDPartSpace * sp = (FDPartSpace *)part;
          if (sp.breakLine) {
              [sb appendString:@"\n"];
          } else {
              [sb appendString:@" "];
          }
      } else {
          [sb appendString:@" "];
      }
  }
  [super getSelectedText:sb];
}


-(void)testHit:(FDRecordLocation *)hr padding:(CGFloat)paddingLeft
{
    float currY = self.absoluteTop + self.clientTop;
    float currX = 0;
    int orderLine = 0;
    //NSLog(@"HITTEST %f, %f", hr.x, hr.y);
    //int orderPart = 0;
    for(FDParagraphLine * line in self.lines) {
        currX = line.startOffsetX + paddingLeft;
        line.orderNo = orderLine;
        //Log.i("ClickEvent", "line.bottomOffset: " + line.bottomOffset + "  hr.y:" + hr.y);
        //Log.i("CickEvent", "curr:" + currY + "  line.height:" + line.height);
        if (currY <= hr.y && (currY + line.height) > hr.y) {
            //Log.i("ClickEvent", "hitLine");
            for(FDPartBase * part in line.parts) {
                if ([part isKindOfClass:[FDPartString class]])
                {
                    FDPartString * strp = (FDPartString *)part;
                    //NSLog(@"  hitTest text %@(currX,width,hr.x):%f,%f,%f", strp.text, currX, strp.desiredWidth, hr.x);
                    if (hr.x >= currX && hr.x < currX + strp.desiredWidth)
                    {
                        [self testHitInitWithPart:hr part:part];
                        return;
                    }
                    else
                    {
                        currX += strp.desiredWidth;
                    }
                }
                else if ([part isKindOfClass:[FDPartSpace class]])
                {
                    FDPartSpace * spc = (FDPartSpace *)part;
                    //NSLog(@"   hitTest space part(currX,width,hr.x):%f,%f,%f", currX, spc.desiredWidth, hr.x);
                    if (hr.x >= currX && hr.x < currX + spc.desiredWidth)
                    {
                        [self testHitInitWithPart:hr part:part];
                        return;
                    }
                    else
                    {
                        currX += spc.desiredWidth;
                    }
                }
                else if ([part isKindOfClass:[FDPartImage class]])
                {
                    FDPartImage * spi = (FDPartImage *)part;
                    //NSLog(@"   hitTest image part(currX,width,hr.x):%f,%f,%f", currX, spi.desiredWidth, hr.x);
                    if (hr.x >= currX && hr.x < currX + spi.desiredWidth)
                    {
                        [self testHitInitWithPart:hr part:part];
                        return;
                    }
                    else
                    {
                        currX += spi.desiredWidth;
                    }
                }
                /*if (hr.x >= currX && hr.x < (currX + part.getWidth)) {
                    //Log.i("ClickEvent", "hit part");
                    [self testHitInitWithPart:hr part:part];
                    return;
                }
                currX += part.getWidth;*/
            }
            
            if (line.parts.count > 0) {
                [self testHitInitWithPart:hr part:line.parts.lastObject];
            }
            
            break;
        }
        currY += line.height;
        orderLine++;
    }
}

-(void)testHitInitWithPart:(FDRecordLocation *)hr part:(FDPartBase *)part
{
    [hr.path addObject:part];
    hr.cell = part;
    hr.cellNum = part.orderNo;
    hr.partNum = self.orderNo;
    hr.areaType = FDRecordLocation.AREA_PARA;
    hr.para = self;
}

-(int)characterLength
{
    int len = 0;
    for(FDPartBase * part in self.parts) {
        len += [part length];
    }
    
    return len;
}

-(int)selectionStartIndex
{
    int len = 0;
    for(FDPartBase * part in self.parts) {
        if ((part.selected | self.selected) != FDSelection.None)
        {
            return len;
        }
        
        len += [part length];
    }
    
    return len;
}

-(int)selectionEndIndex
{
    int len = 0;
    int endIndex = 0;
    for(FDPartBase * part in self.parts) {
        len += [part length];
        if ((part.selected | self.selected) != FDSelection.None)
        {
            endIndex = len;
        }
    }
    
    return endIndex;
}


@end
