//
//  EndlessParagraphView.m
//  VedabaseB
//
//  Created by Peter Kollath on 17/01/15.
//
//

#import "EndlessParagraphView.h"
#import "Canvas.h"
#import "FDRecordBase.h"
#import "FDRecordPart.h"
#import "FDColor.h"
#import "EndlessScrollView.h"
#import "FDPartSized.h"
#import "FDLink.h"
#import "EndlessScrollConstants.h"

@implementation EndlessParagraphView


#pragma mark -
#pragma mark User Interaction Methods

-(void)handleTap:(int)recognizerState point:(CGPoint)current
{
    if (recognizerState == UIGestureRecognizerStateEnded)
    {
        FDRecordLocation * hr = [self getHitLocation:current];
        CGRect hitArea = CGRectMake(current.x - 20, current.y - 20, 40, 40);
        CGRect parentHitArea = [self convertRect:hitArea toView:self.manager];

        if (hr == nil)
        {
            if ([self.manager hasSelection])
            {
                [self.manager clearSelection];
            }
            else
            {
                [self.manager.delegate endlessTextViewTapWithoutSelection:self.manager];
            }
        }
        else if (hr.areaType == [FDRecordLocation AREA_PARA])
        {
            if (hr.cell != nil && [hr.cell isKindOfClass:[FDPartSized class]])
            {
                FDPartSized * part = (FDPartSized *)hr.cell;
                if (part.link)
                {
                    CGPoint parentPoint = [self convertPoint:current toView:self.manager];
                    NSDictionary * dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                                               part.link.link, @"LINK",
                                               part.link.type, @"TYPE",
                                               [NSNumber numberWithInt:hr.record.recordId], @"RECORDID",
                                               [NSValue valueWithCGPoint:parentPoint], @"POINT",
                                               part.link.completeTag, @"TAG", nil];
                    [self.manager.delegate endlessTextView:self.manager
                                      navigateLink:dictData];
                }
                else
                {
                    if ([self.manager hasSelection])
                    {
                        [self.manager clearSelection];
                    }
                    else
                    {
                        [self.manager.delegate endlessTextViewTapWithoutSelection:self.manager];
                    }
                }
            }
            if ([self.manager.delegate respondsToSelector:@selector(endlessTextView:paraAreaClicked:withRect:)])
            {
                [self.manager.delegate endlessTextView:self.manager
                               paraAreaClicked:hr.record.recordId
                                      withRect:parentHitArea];
            }
        }
        else if (hr.areaType == [FDRecordLocation AREA_LEFT_SIDE])
        {
            [self.manager.delegate endlessTextView:self.manager
                           leftAreaClicked:hr.record.recordId
                                  withRect:parentHitArea];
        }
        else if (hr.areaType == [FDRecordLocation AREA_RIGHT_SIDE])
        {
            [self.manager.delegate endlessTextView:self.manager
                          rightAreaClicked:hr.record.recordId
                                  withRect:parentHitArea];
        }
        else
        {
            if ([self.manager hasSelection])
            {
                [self.manager clearSelection];
            }
            else
            {
                [self.manager.delegate endlessTextViewTapWithoutSelection:self.manager];
            }
        }
    }
}


-(void)handleLong:(int)state point:(CGPoint)current
{
    CGRect parentHitRect = CGRectMake(current.x - 16, current.y - 16, 32, 32);
    parentHitRect = [self convertRect:parentHitRect toView:self.manager];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            //NSLog(@"long START");
        {
            if ([self.manager.selection testHitSelectionPoint:current] >= 0)
            {
                self.manager.trackingMode = TRACK_DRAG_SELECTION;
                self.manager.needsDisplayRecordA = self.manager.selection.orderedPoints.A.record.recordId;
                self.manager.needsDisplayRecordB = self.manager.selection.orderedPoints.B.record.recordId;
            }
            else
            {
                self.manager.selMarkViewA.hidden = YES;
                self.manager.selMarkViewB.hidden = YES;
                self.manager.prevHitLocation = nil;
                FDRecordLocation * hr = [self getHitLocation:current];
                if (hr == nil)
                {
                    self.manager.trackingMode = TRACK_NONE;
                }
                else if (hr.cell && hr.areaType == [FDRecordLocation AREA_PARA])
                {
                    // if we have some selection
                    // we should clean it
                    if (self.manager.selection.selectionPoints.A != nil) {
                        [self.manager processSelectionPoints:YES];
                    }
                    
                    // initial setting
                    FDSelectionContext * selection = self.manager.selection;
                    selection.selectionPoints.A = hr;
                    selection.selectionPoints.B = [hr clone];
                    selection.currentSelectionPoint = 1;
                    //self.manager.selMarkViewB.handlePoint = [self convertPoint:current toView:self.manager.selMarkViewB];
                    
                    
                    [self.manager processSelectionPoints:NO];
                    self.manager.needsDisplayRecordA = hr.record.recordId;
                    self.manager.needsDisplayRecordB = hr.record.recordId;
                    
                    [self.manager startSelectionContext];
                    
                    self.manager.trackingMode = TRACK_DRAG_SELECTION;
                }
                else if (hr.areaType == [FDRecordLocation AREA_LEFT_SIDE])
                {
                    [self.manager.delegate endlessTextView:self.manager
                               leftAreaLongClicked:hr.record.recordId
                                          withRect:parentHitRect];
                }
                else if (hr.areaType == [FDRecordLocation AREA_RIGHT_SIDE])
                {
                    [self.manager.delegate endlessTextView:self.manager
                              rightAreaLongClicked:hr.record.recordId
                                          withRect:parentHitRect];
                }
                else
                {
                    self.manager.trackingMode = TRACK_NONE;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            if (self.manager.trackingMode == TRACK_DRAG_SELECTION)
            {
                //self.manager.selection.selectionPoints.B = [self getHitLocationOrPrevious:current];
                [self.manager onDragSelection:[self convertPoint:current toView:self.manager]];
            }
            //NSLog(@"long CHANGED");
            break;
        case UIGestureRecognizerStateEnded:
            if (self.manager.trackingMode == TRACK_DRAG_SELECTION)
            {
                [self.manager onDragSelectionEnd];
            }
            self.manager.trackingMode = TRACK_NONE;
            self.manager.selection.currentSelectionPoint = -1;
            //NSLog(@"long END");
            break;
        case UIGestureRecognizerStateCancelled:
            self.manager.trackingMode = TRACK_NONE;
            self.manager.selection.currentSelectionPoint = -1;
            //NSLog(@"long CANCEL");
            break;
        case UIGestureRecognizerStateFailed:
            self.manager.trackingMode = TRACK_NONE;
            self.manager.selection.currentSelectionPoint = -1;
            //NSLog(@"long FAILED");
            break;
        default:
            break;
    }
}


-(FDRecordLocation *)getHitLocation:(CGPoint)curr
{
    FDRecordLocation * hr = [[FDRecordLocation alloc] init];
    hr.x = curr.x;
    hr.y = curr.y;
    hr.recNum = self.recordId;
    
    if ([self.record testHit:hr paddingLeft:self.drawer.paddingLeft paddingRight:self.drawer.paddingRight])
    {
        [hr.path insertObject:self.record atIndex:0];
        self.manager.prevHitLocation = hr;
        return hr;
    }
    
    
    return nil;
}

-(FDRecordLocation *)getHitLocationOrPrevious:(CGPoint)curr
{
    FDRecordLocation * hr = [[FDRecordLocation alloc] init];
    hr.x = curr.x;
    hr.y = curr.y;
    hr.recNum = self.recordId;
    
    if ([self.record testHit:hr paddingLeft:self.drawer.paddingLeft paddingRight:self.drawer.paddingRight])
    {
        [hr.path insertObject:self.record atIndex:0];
        self.manager.prevHitLocation = hr;
        return hr;
    }
    
    return self.manager.prevHitLocation;
}

#pragma mark -
#pragma mark Drawing Methods

-(void)drawRect:(CGRect)rect
{
    //[super drawRect:rect];
    
    BOOL savedState = NO;
    CGFloat yCurr = 0;
    Canvas * canvas = [[Canvas alloc] init];
    CGFloat width = rect.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    
    if (self.record.recordMark != nil) {
        if (!savedState)
            CGContextSaveGState(canvas.context);
        UIColor * bkgColor = (self.record.recordMarkColor != nil ? self.record.recordMarkColor : self.drawer.recordMarkBackground);
        CGSize markSize = [self.record.recordMark sizeWithAttributes:self.drawer.recordMarkAttributes];
        [canvas setStrokeColor:bkgColor];
        [canvas setStrokeWidth:1.0];
        [canvas lineFrom:CGPointMake(0, markSize.height/2) to:CGPointMake(20, markSize.height/2)];
        [canvas lineFrom:CGPointMake(markSize.width + 38, markSize.height/2) to:CGPointMake(rect.size.width, markSize.height/2)];
        [canvas setFillColor:bkgColor];
        CGMutablePathRef mpath = CGPathCreateMutable();
        CGPathAddRoundedRect(mpath, NULL, CGRectMake(24, 0, markSize.width + 10, markSize.height + 4), 5, 5);
        CGContextAddPath(canvas.context, mpath);
        CGContextFillPath(canvas.context);
        [self.record.recordMark drawAtPoint:CGPointMake(29, 2) withAttributes:self.drawer.recordMarkAttributes];
        savedState = YES;
        yCurr += markSize.height + 8;
    }
    if (savedState) {
        CGContextRestoreGState(canvas.context);
        savedState = NO;
    }
    
    self.record.recordPaintOffset = yCurr;
    self.notes = [self.dataSource recordNotesForRecord:self.recordId];
    
    if ([self.record.parts count] > 0) {
        float x = self.drawer.paddingLeft;
        float y = yCurr;
        int order = 0;
        
        // draw note icon only if not interferring with history buttons
        if (self.notes.noteText && ([self.notes.noteText length] > 0)) {
            UIImage * noteImage = [self.drawer.skinManager endlessTextViewRecordNoteImage];
            [canvas drawImage:noteImage rect:CGRectMake(10, y+4, 32, 32)];
            self.record.noteIcon = true;
        }
        
        /*if ([self.dataSource recordHasBookmark:record.recordId])
         {
         [canvas drawImage:[self.skinDelegate endlessTextViewBookmarkImage]
         rect:CGRectMake(width + self.paddingLeft + 10, yCurr + 4, 32, 32)];
         }*/
        
        FDHighlightTracker * tracker = nil;
        
        if (self.notes && self.notes.anchorsCount > 0)
        {
            tracker = [[FDHighlightTracker alloc] init];
            tracker.charCounter = 0;
            tracker.notes = self.notes;
            tracker.highlighterIndex = 0;
            tracker.anchor = [self.notes anchorAtIndex:0];
        }
        
        //NSLog(@"DRAW PARA: NOTES");
        //[tracker.notes logDumpAnchors];
        canvas.orderedPoints = self.manager.selection.orderedPoints;
        canvas.anchor = tracker;
        canvas.phrases = self.drawer.highlightPhrases;
        
        for (FDRecordPart * rp in self.record.parts) {
            if (rp.delegate == nil)
                rp.delegate = self.drawer.skinManager;
            rp.orderNo = order;
            rp.absoluteTop = y;
            rp.absoluteRight = rect.size.width;
            
            //CGSize imageSize = CGSizeMake(width, rp.calculatedHeight);
            //NSLog(@"Making imageSHot from record part %d.%d %f", record.recordId, rp.orderNo, rp.calculatedHeight);
            //UIGraphicsBeginImageContext(imageSize);
            //Canvas * privCanvas = [[Canvas alloc] init];
            //[rp drawWithCanvas:privCanvas
            //            xstart:0
            //            ystart:0
            //            points:self.orderedPoints
            //            anchor:tracker
            //           phrases:self.highlightPhrases];
            //UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            //rp.imageShot = image;
            //UIGraphicsEndImageContext();
            
            y += [rp drawWithCanvas:canvas xstart:x ystart:y];
            
            //rp.draw(canvas, x, y, orderedPoints, anch);
            rp.absoluteBottom = y;
            order++;
        }
        
        if (self.manager.selection.currentRecordLeftHighlighter == self.record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(0, yCurr, self.drawer.paddingLeft, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
        else if (self.manager.selection.currentRecordRightHighlighter == self.record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(width + self.drawer.paddingLeft, yCurr, self.drawer.paddingRight, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
    }
    
    if (canvas.startSelectionValid)
    {
        self.manager.selection.hotSpotA = [self convertPoint:canvas.startSelectionPointA toView:self.manager];
        if (self.manager.selMarkViewA.hidden == YES)
        {
            self.manager.selMarkViewA.hotSpotLocation = self.manager.selection.hotSpotA;
            self.manager.selMarkViewA.hidden = NO;
        }
    }
    
    if (canvas.endSelectionValid)
    {
        self.manager.selection.hotSpotB = [self convertPoint:canvas.endSelectionPointB toView:self.manager];
        if (self.manager.selMarkViewB.hidden == YES)
        {
            self.manager.selMarkViewB.hotSpotLocation = self.manager.selection.hotSpotB;
            self.manager.selMarkViewB.hidden = NO;
        }
    }
    
    [self.manager performSelectorOnMainThread:@selector(endlessViewDidShow:)
                                   withObject:self
                                waitUntilDone:NO];
    
}

-(void)showRecord:(int)recId align:(int)align
{
    NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:recId], @"record", [NSNumber numberWithInt:align], @"align", nil];
 
    //[self performSelectorInBackground:@selector(showRecordAsync:) withObject:d];
    [self showRecordAsync:d];
}

-(void)showRecordAsync:(NSDictionary *)d
{
    NSNumber * recNum = [d objectForKey:@"record"];
    NSNumber * align = [d objectForKey:@"align"];
    
    //NSLog(@"Going to show record %@", recNum);
    self.recordId = [recNum intValue];
    self.headRecord = ([self.dataSource minimumRecord] == self.recordId);
    self.tailRecord = ([self.dataSource maximumRecord] == self.recordId);
    self.record = [self.dataSource getRawRecord:[recNum intValue]];
    
    CGSize superSize = [self.manager frame].size;
    CGFloat mywidth = superSize.width - self.drawer.paddingLeft - self.drawer.paddingRight;
    CGFloat height = [self.record validateForWidth:mywidth];
    
    if (height < 1)
        height = 1;
    else if (height > 5000)
        height = 5000;
    height = ceil(height);
    CGRect newFrame = self.frame;
    
    if ([align intValue] == 0)
    {
        newFrame = CGRectMake(0, newFrame.origin.y, superSize.width, height);
    }
    else
    {
        newFrame = CGRectMake(0, newFrame.origin.y + newFrame.size.height - height, superSize.width, height);
    }
    //NSLog(@"Height for rec %d, %f    %f %f %f %f", self.recordId, height, newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);

    self.frame = newFrame;
    self.record.recordView = self;
    [self.manager.selection applySelectionToRecord:self.record];
    
    [self setNeedsDisplay];
}

-(CGFloat)topY
{
    return self.frame.origin.y;
}

-(CGFloat)bottomY
{
    return self.frame.origin.y + self.frame.size.height;
}


-(CGRect)rearrangeByPosition:(CGFloat)pos
{
    CGSize superSize = [self.manager frame].size;
    CGFloat mywidth = superSize.width - self.drawer.paddingLeft - self.drawer.paddingRight;
    CGFloat height = [self.record validateForWidth:mywidth];
    if (height < 1)
        height = 1;
    height = ceil(height);
    

    CGRect oldFrame = self.frame;
    CGRect newFrame = CGRectMake(0, oldFrame.origin.y + oldFrame.size.height*pos - pos*height, superSize.width, height);
    
    [self setFrame:newFrame];
    
    return newFrame;
}

-(CGRect)rearrangeByTop:(CGFloat)top
{
    CGSize superSize = [self.manager frame].size;
    CGFloat mywidth = superSize.width - self.drawer.paddingLeft - self.drawer.paddingRight;
    CGFloat height = [self.record validateForWidth:mywidth];
    if (height < 1)
        height = 1;
    height = ceil(height);
    
    CGRect newFrame = CGRectMake(0, top, superSize.width, height);
    
    [self setFrame:newFrame];
    
    return newFrame;
}

-(CGRect)rearrangeByBottom:(CGFloat)bottom
{
    CGSize superSize = [self.manager frame].size;
    CGFloat mywidth = superSize.width - self.drawer.paddingLeft - self.drawer.paddingRight;
    CGFloat height = [self.record validateForWidth:mywidth];
    if (height < 1)
        height = 1;
    height = ceil(height);
    
    CGRect newFrame = CGRectMake(0, bottom - height, superSize.width, height);
    
    [self setFrame:newFrame];
    
    return newFrame;
}


@end
