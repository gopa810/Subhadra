//
//  EndlessTextView.m
//  VedabaseB
//
//  Created by Peter Kollath on 28/07/14.
//
//

#import "EndlessTextView.h"
#import "sides_const.h"
#import "Canvas.h"
#import "FDRecordBase.h"
#import "FDRecordPart.h"
#import "FDParagraph.h"
#import "FDRecordLocation.h"
#import "FDPartBase.h"
#import "FDSelection.h"
#import "FDCharFormat.h"
#import "FDPartSized.h"
#import "FDLink.h"
#import "FDColor.h"
#import "FDHighlightTracker.h"

NSString * DEBUG_TAG = @"ClickEvent";

BOOL g_endlessTextView_DrawSpeed = NO;

#define TRACK_NONE           0
#define TRACK_WAIT_NEXT      1
#define TRACK_DRAG_CONTENT   2
#define TRACK_DRAG_SELECTION 3
#define TRACK_MULTITOUCH     4

@implementation EndlessTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initThis];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //NSLog(@"EndlessTextView init");
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initThis];
    }
    return self;
}

-(void)initThis
{
    // Initialization code
    self.trackingMode = 0;
    self.selection.selectionPoints = [[FDRecordLocationPair alloc] init];
    self.selection.orderedPoints = [[FDRecordLocationPair alloc] init];
    self.needsDisplayRecordsValid = NO;
    self.moveSensitivityX = 2;
    self.moveSensitivityY = 2;
    self.longClickTimeout = 750;
    self.paintedRecords = [[NSMutableArray alloc] init];
    self.selection = [FDSelectionContext new];
    
    self.drawLineBeforeRecord = NO;
    self.drawRecordNumber = NO;
    self.highlightBordersWhenRecordActive = NO;
    self.selection.currentRecordLeftHighlighter = -1;
    self.selection.currentRecordRightHighlighter = -1;
    
    self.currentPosition = [EndlessTextViewHistoryPosition new];
    self.currentPosition.offset = 0;
    self.currentPosition.recordId = 0;
    self.textHistory = [NSMutableArray new];
    self.textHistoryPos = 0;
    [self.textHistory addObject:self.currentPosition];
    
    self.emmbededInScroll = YES;

    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture)];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    
    [self addGestureRecognizer:self.tapRecognizer];
    [self addGestureRecognizer:self.longPressRecognizer];
    [self addGestureRecognizer:self.pinchRecognizer];
    
    self.swipeToLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToLeft)];
    self.swipeToLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:self.swipeToLeftRecognizer];
    
    self.swipeToRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRight)];
    self.swipeToRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:self.swipeToRightRecognizer];

    if (!self.emmbededInScroll)
    {
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture)];
        [self addGestureRecognizer:self.panRecognizer];
    }
    
    self.scrollOffsetValid = NO;
    self.lastScrollDirection = 0;
    self.lastScrollOffset = 0.0;
    self.preparedContentOffset = CGPointZero;
    self.preparedContentOffsetValid = NO;
    self.prevHitLocation = nil;

}

-(void)updateTextViewSize
{
    CGSize size = self.parentScrollView.frame.size;
    [self setFrame:CGRectMake(0, 0, size.width, size.height*5)];
    [self.parentScrollView setContentSize:CGSizeMake(size.width, size.height*5)];
}

- (void)recalculateSizeAndTextOffset
{
    if (self.parentScrollView != nil)
    {
        CGSize size = self.parentScrollView.frame.size;
        CGFloat offset = self.parentScrollView.contentOffset.y * size.height / size.width;
        [self updateTextViewSize];
        self.preparedContentOffset = CGPointMake(0, offset);
        self.preparedContentOffsetValid = YES;
    }
}


-(void)setScrollParent:(UIScrollView *)scrollView
{
    if (scrollView == nil)
    {
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture)];
        [self addGestureRecognizer:self.panRecognizer];
        self.emmbededInScroll = NO;
    }
    else
    {
        self.parentScrollView = scrollView;
        scrollView.delegate = self;
        self.panRecognizer = [scrollView panGestureRecognizer];
        [scrollView.panGestureRecognizer addTarget:self action:@selector(handlePanGesture)];
        self.emmbededInScroll = YES;
        [self updateTextViewSize];
        self.parentScrollView.contentOffset = CGPointMake(0, 0);
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    long touchCount = [touches count];
    if (touchCount == 1)
    {
        CGPoint current = [[touches anyObject] locationInView:self];
        self.prevHitLocation = nil;
        FDRecordLocation * hr = [self getHitLocation:current];
        if (hr == nil)
        {
        }
        else if (hr.areaType == [FDRecordLocation AREA_LEFT_SIDE])
        {
            self.selection.currentRecordLeftHighlighter = hr.record.recordId;
            [self setNeedsDisplay];
        }
        else if (hr.areaType == [FDRecordLocation AREA_RIGHT_SIDE])
        {
            self.selection.currentRecordRightHighlighter = hr.record.recordId;
            [self setNeedsDisplay];
        }
        else if (hr.areaType == [FDRecordLocation AREA_PARA])
        {
            if (self.highlightBordersWhenRecordActive)
            {
                self.selection.currentRecordLeftHighlighter = hr.record.recordId;
                self.selection.currentRecordRightHighlighter = hr.record.recordId;
                [self setNeedsDisplay];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selection.currentRecordLeftHighlighter = -1;
    self.selection.currentRecordRightHighlighter = -1;
    [self setNeedsDisplay];
    
    //NSLog(@"-- touches ended");
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selection.currentRecordLeftHighlighter = -1;
    self.selection.currentRecordRightHighlighter = -1;
    [self setNeedsDisplay];
}

-(void)setNeedsDisplayRecords
{
    FDRecordBase * ra = [self.dataSource getRawRecord:self.needsDisplayRecordA];
    FDRecordBase * rb = [self.dataSource getRawRecord:self.needsDisplayRecordB];
    //NSLog(@"ETV recs to update %d - %d", self.needsDisplayRecordA, self.needsDisplayRecordB);
    if (ra != nil && rb != nil)
    {
        CGFloat y = ra.recordPaintOffset;
        CGFloat height = rb.recordPaintOffset + rb.calculatedHeight - y;
        self.needsDisplayRecordsValid = YES;
        //NSLog(@"ETV rectToUpdate: %f,%f,%f,%f", 0.0, y, self.frame.size.width, height);
        [super setNeedsDisplayInRect:CGRectMake(0, y, self.frame.size.width, height)];
    }
    else
    {
        [super setNeedsDisplay];
    }
}

-(void)setNeedsDisplay
{
    self.needsDisplayRecordsValid = NO;
    [super setNeedsDisplay];
}

#pragma mark -
#pragma mark Scroll view delegate methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
//    NSLog(@"Position %f / %f", scrollView.contentOffset.y, scrollView.contentSize.height);
    if (self.scrollOffsetValid)
    {
        int direction = (offset > self.lastScrollOffset) ? 1 : -1;
        if (self.lastScrollDirection == 0)
        {
            [self scrollViewDidScroll:offset withDirection:direction];
            self.lastScrollDirection = direction;
        }
        else if (self.lastScrollDirection == direction)
        {
            [self scrollViewDidScroll:offset withDirection:direction];
        }
    }

    self.lastScrollOffset = offset;
    self.scrollOffsetValid = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        //NSLog(@"did end decelerating");
        self.lastScrollDirection = 0;
        self.scrollOffsetValid = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"did end decelerating");
    self.lastScrollDirection = 0;
    self.scrollOffsetValid = NO;
}

- (void)moveCurrentRecordWithOffset:(CGFloat)L0
{
    // try to go to previous records
    // but cannot go to lower than minimal record
    NSInteger minRec = [self.dataSource minimumRecord];
    int rec1 = self.currentPosition.recordId;
    CGFloat sumHeight = self.currentPosition.offset;
    CGFloat width = self.frame.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    
    if (rec1 > minRec || fabs(sumHeight) > 1.0)
    {
        //NSLog(@"GO TO UP:: First record is %d  %f", frloc.record.recordId, frloc.record.recordPaintOffset);
        
        CGFloat maxHeight = L0;
        while (rec1 > minRec && sumHeight > maxHeight)
        {
            rec1--;
            FDRecordBase * rec = [self.dataSource getRawRecord:rec1];
            if (rec != nil) {
                CGFloat recHeight = [rec validateForWidth:width];
                sumHeight -= recHeight;
            }
        }
        
        if (sumHeight < maxHeight)
        {
            self.currentPosition.offset = sumHeight - maxHeight;
            sumHeight = maxHeight;
        }
        else
        {
            self.currentPosition.offset = 0;
        }
        self.currentPosition.recordId = rec1;
        
        self.preparedContentOffset = CGPointMake(0, self.parentScrollView.contentOffset.y - sumHeight);
        self.preparedContentOffsetValid = YES;
        [self setNeedsDisplay];
        
    }
}

/*
 *
 * direction: >0 means scrolling to higher records
 *            <0 means scrolling to lower records
 * check the position of scrolling window to ensure, that
 * all records needed for drawing are available.
 * the limit is that if offset is lower than some minimum or maximum
 * then we will rearrange content of view (and possibly also view size (and content size)
 *
 * when offset is lower than minimum:
 *      get starting record
 *      try to go to as much previous records as to fill space of
 */

-(void)scrollViewDidScroll:(CGFloat)scrollOffset withDirection:(int)direction
{
    CGFloat L0 = self.frame.size.height / 5;
    CGFloat L1 = L0 * 1.0;
    CGFloat L2 = L0 * 3.5;
    CGFloat width = self.frame.size.width;
    //NSLog(@"scrollViewDidScroll at %f", scrollOffset);
    if (scrollOffset < L1)
    {
        if (direction < 0)
        {
            [self moveCurrentRecordWithOffset:-L0*2];
        }
    }
    else if (scrollOffset > L2)
    {
        if (direction > 0)
        {
            // try to go to next records
            // but cannot go above maximum record
            EndlessTextViewHistoryPosition * pos = [EndlessTextViewHistoryPosition new];
            if ([self getPosition:pos atPoint:CGPointMake(200,L0*5)])
            {
                NSInteger maxRec = [self.dataSource maximumRecord];
                CGFloat maxHeight = L0 * 2;
                CGFloat sumHeight = 0;
                sumHeight = [self getRecordsHeightFrom:(NSInteger)pos.recordId
                                                    to:maxRec
                                                 width:width startHeight:pos.offset
                                             maxHeight:maxHeight];
                if (sumHeight > maxHeight)
                    sumHeight = maxHeight;
                CGPoint newContOffset = CGPointMake(0, sumHeight);
                if ([self getPosition:pos atPoint:newContOffset])
                {
                    //NSLog(@" X1: Perhaps new position will be %d:[%f]", pos.recordId, pos.offset);
                    self.currentPosition.recordId = pos.recordId;
                    self.currentPosition.offset = pos.offset;
                    self.preparedContentOffset = CGPointMake(0, self.parentScrollView.contentOffset.y - sumHeight);
                    self.preparedContentOffsetValid = YES;
                    [self setNeedsDisplay];
                }
            }
        }
    }
}

-(CGFloat)getRecordsHeightFrom:(NSInteger)startRec to:(NSInteger)maxRec width:(CGFloat)width
                   startHeight:(CGFloat)startHeight
                     maxHeight:(CGFloat)maxHeight
{
    CGFloat sumHeight = startHeight;
    NSInteger rec1 = startRec;
    
    while (rec1 < maxRec && sumHeight < maxHeight)
    {
        FDRecordBase * rec = [self.dataSource getRawRecord:(unsigned int)rec1];
        if (rec != nil) {
            sumHeight += [rec validateForWidth:width];
        }
        rec1++;
    }

    return sumHeight;
}

-(void)pageUp:(CGFloat)height
{
    // try to go to previous records
    // but cannot go to lower than minimal record
    NSInteger minRec = [self.dataSource minimumRecord];
    int rec1 = self.currentPosition.recordId;
    CGFloat sumHeight = self.currentPosition.offset;
    CGFloat width = self.frame.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    
    if (rec1 > minRec || fabs(sumHeight) > 1.0)
    {
        //NSLog(@"GO TO UP:: First record is %d  %f", frloc.record.recordId, frloc.record.recordPaintOffset);
        
        CGFloat maxHeight = -height;
        while (rec1 > minRec && sumHeight > maxHeight)
        {
            rec1--;
            FDRecordBase * rec = [self.dataSource getRawRecord:rec1];
            if (rec != nil) {
                CGFloat recHeight = [rec validateForWidth:width];
                sumHeight -= recHeight;
            }
        }
        
        if (sumHeight < maxHeight)
        {
            self.currentPosition.offset = sumHeight - maxHeight;
            sumHeight = maxHeight;
        }
        else
        {
            self.currentPosition.offset = 0;
        }
        self.currentPosition.recordId = rec1;

        if (rec1 == 0 && self.currentPosition.offset < 1)
        {
            self.preparedContentOffset = CGPointMake(0, 0);
            self.preparedContentOffsetValid = YES;
        }
        [self setNeedsDisplay];
        
    }
}

-(void)pageDown:(CGFloat)height
{
    // try to go to next records
    // but cannot go above maximum record
    CGFloat width = self.frame.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    EndlessTextViewHistoryPosition * pos = [EndlessTextViewHistoryPosition new];
    if ([self getPosition:pos atPoint:CGPointMake(200,self.frame.size.height)])
    {
        NSInteger maxRec = [self.dataSource maximumRecord];
        CGFloat maxHeight = height;
        CGFloat sumHeight = 0;
        sumHeight = [self getRecordsHeightFrom:(NSInteger)pos.recordId
                                            to:maxRec
                                         width:width startHeight:pos.offset
                                     maxHeight:maxHeight];
        if (sumHeight > maxHeight)
            sumHeight = maxHeight;
        CGPoint newContOffset = CGPointMake(0, sumHeight);
        if ([self getPosition:pos atPoint:newContOffset])
        {
            //NSLog(@" X1: Perhaps new position will be %d:[%f]", pos.recordId, pos.offset);
            self.currentPosition.recordId = pos.recordId;
            self.currentPosition.offset = pos.offset;
//            self.preparedContentOffset = CGPointMake(0, self.parentScrollView.contentOffset.y - sumHeight);
//            self.preparedContentOffsetValid = YES;
            [self setNeedsDisplay];
        }
    }
}

#pragma mark -
#pragma mark Handling callbacks from gesture recognizers


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * returned = nil;
    
    returned = [super hitTest:point withEvent:event];

    [self testHitSelectionPoint:point];

    //NSLog(@"HX: hit test with point %f,%f", point.x, point.y);
    //NSLog(@"HX: selPoint:%d", [self testHitSelectionPoint:point]);
    
    return returned;
}

-(void)handleTap
{
    UIGestureRecognizerState state = [self.tapRecognizer state];
    
    if (state == UIGestureRecognizerStateEnded)
    {
        self.fadeScrolling = NO;
        CGPoint current = [self.longPressRecognizer locationInView:self];
        FDRecordLocation * hr = [self getHitLocation:current];
        //NSLog(@"curr pos TAP %f,%f", current.x, current.y);
        if (hr == nil)
        {
            [self clearSelection];
            [self setNeedsDisplay];
        }
        else if (hr.areaType == [FDRecordLocation AREA_PARA])
        {
            if (hr.cell != nil && [hr.cell isKindOfClass:[FDPartSized class]])
            {
                FDPartSized * part = (FDPartSized *)hr.cell;
                if (part.link)
                {
                    NSDictionary * dictData = [NSDictionary dictionaryWithObjectsAndKeys:
                           part.link.link, @"LINK",
                           part.link.type, @"TYPE",
                           [NSNumber numberWithInt:hr.record.recordId], @"RECORDID",
                           [NSValue valueWithCGPoint:current], @"POINT",
                           part.link.completeTag, @"TAG", nil];
                    [self.delegate endlessTextView:self
                                      navigateLink:dictData];
                }
                else
                {
                    [self clearSelection];
                    [self setNeedsDisplay];
                }
            }
            if ([self.delegate respondsToSelector:@selector(endlessTextView:paraAreaClicked:withRect:)])
            {
                [self.delegate endlessTextView:self
                               paraAreaClicked:hr.record.recordId
                                      withRect:CGRectMake(current.x - 20, current.y - 20, 40, 40)];
            }
        }
        else if (hr.areaType == [FDRecordLocation AREA_LEFT_SIDE])
        {
            [self.delegate endlessTextView:self
                           leftAreaClicked:hr.record.recordId
                                  withRect:CGRectMake(current.x - 16, current.y - 16, 32, 32)];
        }
        else if (hr.areaType == [FDRecordLocation AREA_RIGHT_SIDE])
        {
            [self.delegate endlessTextView:self
                          rightAreaClicked:hr.record.recordId
                                  withRect:CGRectMake(current.x - 16, current.y - 16, 32, 32)];
        }
    }
}

-(void)handleLongPress
{
    switch ([self.longPressRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            //NSLog(@"long START");
        {
            CGPoint current = [self.longPressRecognizer locationInView:self];
            if ([self testHitSelectionPoint:current] >= 0)
            {
                self.trackingMode = TRACK_DRAG_SELECTION;
                self.needsDisplayRecordA = self.selection.orderedPoints.A.record.recordId;
                self.needsDisplayRecordB = self.selection.orderedPoints.B.record.recordId;
            }
            else
            {
                self.prevHitLocation = nil;
                FDRecordLocation * hr = [self getHitLocation:current];
                if (hr == nil)
                {
                    self.trackingMode = TRACK_NONE;
                }
                else if (hr.cell && hr.areaType == [FDRecordLocation AREA_PARA])
                {
                    // if we have some selection
                    // we should clean it
                    if (self.selection.selectionPoints.A != nil) {
                        [self processSelectionPoints:YES];
                    }
                    
                    // initial setting
                    self.selection.selectionPoints.A = hr;
                    self.selection.selectionPoints.B = [hr clone];
                    self.selection.currentSelectionPoint = 0;
                    
                    
                    [self processSelectionPoints:NO];
                    self.needsDisplayRecordA = hr.record.recordId;
                    self.needsDisplayRecordB = hr.record.recordId;
                    [self setNeedsDisplayRecords];
                    
                    [self startSelectionContext];
                    
                    self.trackingMode = TRACK_DRAG_SELECTION;
                }
                else if (hr.areaType == [FDRecordLocation AREA_LEFT_SIDE])
                {
                    [self.delegate endlessTextView:self
                               leftAreaLongClicked:hr.record.recordId
                                          withRect:CGRectMake(current.x - 16, current.y - 16, 32, 32)];
                }
                else if (hr.areaType == [FDRecordLocation AREA_RIGHT_SIDE])
                {
                    [self.delegate endlessTextView:self
                              rightAreaLongClicked:hr.record.recordId
                                          withRect:CGRectMake(current.x - 16, current.y - 16, 32, 32)];
                }
                else
                {
                    self.trackingMode = TRACK_NONE;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            if (self.trackingMode == TRACK_DRAG_SELECTION)
            {
                CGPoint current = [self.longPressRecognizer locationInView:self];
                [self onDragSelection:current];
            }
            //NSLog(@"long CHANGED");
            break;
        case UIGestureRecognizerStateEnded:
            if (self.trackingMode == TRACK_DRAG_SELECTION)
            {
                [self onDragSelectionEnd];
            }
            self.trackingMode = TRACK_NONE;
            self.selection.currentSelectionPoint = -1;
            //NSLog(@"long END");
            break;
        case UIGestureRecognizerStateCancelled:
            self.trackingMode = TRACK_NONE;
            self.selection.currentSelectionPoint = -1;
            //NSLog(@"long CANCEL");
            break;
        case UIGestureRecognizerStateFailed:
            self.trackingMode = TRACK_NONE;
            self.selection.currentSelectionPoint = -1;
            //NSLog(@"long FAILED");
            break;
        default:
            break;
    }
}

-(void)handlePanGesture
{
    //NSLog(@"pan gesture");
    CGPoint current = [self.panRecognizer locationInView:self];
    switch ([self.panRecognizer state]) {
        case UIGestureRecognizerStateBegan:
//            NSLog(@"curr pos PAN %f,%f    %d", current.x, current.y, self.currentSelectionPoint);
            if (self.selection.currentSelectionPoint < 0)
                [self testHitSelectionPoint:current];
            if (self.selection.currentSelectionPoint >= 0)
            {
                self.trackingMode = TRACK_DRAG_SELECTION;
                self.scrollStartOffset = [self.parentScrollView contentOffset];
                self.needsDisplayRecordA = self.selection.orderedPoints.A.record.recordId;
                self.needsDisplayRecordB = self.selection.orderedPoints.B.record.recordId;
                //self.parentScrollView.scrollEnabled = NO;
                //NSLog(@"handlePanGesture drag selection start ");
            }
            else
            {
                if (!self.emmbededInScroll)
                {
                    //[self.panRecognizer reset];
                    self.trackingMode = TRACK_DRAG_CONTENT;
                    self.sumDifferenceX = 0;
                    self.sumDifferenceY = 0;
                    self.tapStartTime = time(NULL);
                }
            }
            break;
        case UIGestureRecognizerStateChanged:
            //NSLog(@"curr pos PAN %f,%f", current.x, current.y);
            if (self.trackingMode == TRACK_DRAG_SELECTION)
            {
                [self.parentScrollView setContentOffset:self.scrollStartOffset];
                [self onDragSelection:current];
            }
            else
            {
                if (!self.emmbededInScroll)
                {
                    self.lastDifferenceY = (current.y - self.lastY);
                    self.currentPosition.offset += self.lastDifferenceY;
                    self.lastDifferenceX = (current.x - self.lastX);
                    self.sumDifferenceX += self.lastDifferenceX;
                    self.sumDifferenceY += ABS(self.lastDifferenceY);
                    [self setNeedsDisplay];
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.trackingMode == TRACK_DRAG_SELECTION)
            {
                [self onDragSelectionEnd];
            }
            else
            {
                if (!self.emmbededInScroll)
                {
                    if (self.sumDifferenceX < -70 && self.sumDifferenceY < 30) {
                        [self.delegate endlessTextView:self swipeLeft:current];
                    } else if (self.sumDifferenceX > 70 && self.sumDifferenceY < 30) {
                        [self.delegate endlessTextView:self swipeRight:current];
                    } else {
                        self.fadeScrolling = true;
                        [self setNeedsDisplay];
                    }
                }
            }
            self.selection.currentSelectionPoint = -1;
            self.parentScrollView.scrollEnabled = YES;
            self.trackingMode = TRACK_NONE;
            break;
        case UIGestureRecognizerStateCancelled:
            self.trackingMode = TRACK_NONE;
            self.parentScrollView.scrollEnabled = YES;
            self.selection.currentSelectionPoint = -1;
            break;
        case UIGestureRecognizerStateFailed:
            self.trackingMode = TRACK_NONE;
            self.parentScrollView.scrollEnabled = YES;
            self.selection.currentSelectionPoint = -1;
            break;
        default:
            self.parentScrollView.scrollEnabled = YES;
            self.trackingMode = TRACK_NONE;
            self.selection.currentSelectionPoint = -1;
            break;
    }
    
    self.lastX = current.x;
    self.lastY = current.y;
    
}

-(void)handlePinchGesture
{
    float scale = self.pinchRecognizer.scale;
    
    switch ([self.pinchRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            self.pinchStartSize = [FDCharFormat multiplyFontSize];
            //NSLog(@"pinch gesture A, scale: %f", self.pinchRecognizer.scale);
            break;
        case UIGestureRecognizerStateChanged:
            /*if (scale >= 1.0f)
             {
             scale *= 2.0f;
             newIndex += (int)scale;
             }
             else if (scale > 0.1f)
             {
             scale = -2.0f / scale;
             newIndex += (int)scale;
             }
             if (newIndex < 0)
             newIndex = 0;
             else if (newIndex > 19)
             newIndex = 19;
             [FDCharFormat setFontSizeIndex:newIndex];*/
            scale = 1.0 - (1.0 - scale) / 3.0;
            scale *= self.pinchStartSize;
            if (scale < 0.8)
                scale = 0.8;
            else if (scale > 4.0)
                scale = 4.0;
            [FDCharFormat setMultiplyFontSize:scale];
            [self setNeedsDisplay];
            //NSLog(@"pinch gesture B, index change: %d", (int)scale);
            break;
        case UIGestureRecognizerStateEnded:
            //NSLog(@"pinch gesture C, scale: %f", self.pinchRecognizer.scale);
            break;
        case UIGestureRecognizerStateCancelled:
            //NSLog(@"pinch gesture D");
            break;
        case UIGestureRecognizerStateFailed:
            //NSLog(@"pinch gesture E");
            break;
        default:
            //NSLog(@"pinch gesture DEF");
            break;
    }
}

-(void)handleSwipeToLeft
{
    [self.delegate endlessTextView:self swipeLeft:[self.swipeToLeftRecognizer locationInView:self]];
//    NSLog(@"SWIPE HERE LEFT");
}

-(void)handleSwipeToRight
{
    [self.delegate endlessTextView:self swipeRight:[self.swipeToRightRecognizer locationInView:self]];
}


#pragma mark -

-(void)startSelectionContext
{
}

-(void)endSelectionContext
{
    [self processSelectionPoints:YES];
    self.selection.selectionPoints.A = nil;
    self.selection.selectionPoints.B = nil;
    self.selection.orderedPoints.A = nil;
    self.selection.orderedPoints.B = nil;
    self.selection.currentSelectionPoint = -1;
    //if (actionModeStarted != null)
    //    actionModeStarted.finish();
    [self setNeedsDisplay];
}

-(void)processSelectionPoints:(BOOL)clearSelection
{
    
    if (self.selection.selectionPoints.A == nil || self.selection.selectionPoints.B == nil)
        return;
    
    BOOL oneParaSel;
    int start;
    int end;
    
    // sort selection points
    oneParaSel = [self sortSelectionPoints];
    
    if (oneParaSel) {
        // if selection only within 1 paragraph
        // then we align selection to words
        start = self.selection.orderedPoints.A.cellNum;
        end = self.selection.orderedPoints.B.cellNum;
        
        FDParagraph * para = self.selection.orderedPoints.A.para;
        if (para != nil) {
            if (clearSelection) {
                for(int i = start; i <= end; i++) {
                    FDPartBase * cell = [para.parts objectAtIndex:i];
                    cell.selected = [FDSelection None];
                }
            } else {
                for(int i = start + 1; i < end; i++) {
                    FDPartBase * cell = [para.parts objectAtIndex:i];
                    cell.selected = [FDSelection Middle];
                }
                if (start == end) {
                    FDPartBase * cell = [para.parts objectAtIndex:start];
                    cell.selected = [FDSelection First] | [FDSelection Last];
                    //NSLog(@"selected object: %@", [cell class]);
                } else {
                    FDPartBase * cell = [para.parts objectAtIndex:start];
                    cell.selected = [FDSelection First];
                    cell = [para.parts objectAtIndex:end];
                    cell.selected = [FDSelection Last];
                }
            }
        }
        
    } else {
        // if selection covers more paragraphs
        // then we align selection to paragraph
        start = self.selection.orderedPoints.A.record.recordId;
        end = self.selection.orderedPoints.B.record.recordId;
        
        FDRecordBase * rec;
        if (clearSelection) {
            
            rec = [self.dataSource getRawRecord:start];
            for(FDRecordPart * part in rec.parts) {
                part.selected = FDSelection.None;
            }
            
            for(int i = start + 1; i < end; i++) {
                rec = [self.dataSource getRawRecord:i];
                for(FDRecordPart * part in rec.parts) {
                    part.selected = FDSelection.None;
                }
            }
            
            rec = [self.dataSource getRawRecord:end];
            for(FDRecordPart * part in rec.parts) {
                part.selected = FDSelection.None;
            }
            
        } else {
            
            rec = [self.dataSource getRawRecord:start];
            for(FDRecordPart * part in rec.parts) {
                if (part.orderNo == self.selection.orderedPoints.A.partNum) {
                    part.selected = FDSelection.First;
                } else if (part.orderNo > self.selection.orderedPoints.A.partNum) {
                    part.selected = FDSelection.Middle;
                }
            }
            
            for(int i = start + 1; i < end; i++) {
                rec = [self.dataSource getRawRecord:i];
                for(FDRecordPart * part in rec.parts) {
                    part.selected = FDSelection.Middle;
                }
            }
            
            rec = [self.dataSource getRawRecord:end];
            for(FDRecordPart * part in rec.parts) {
                if (part.orderNo == self.selection.orderedPoints.B.partNum) {
                    if (part.selected == FDSelection.First)
                        part.selected |= FDSelection.Last;
                    else
                        part.selected = FDSelection.Last;
                } else if (part.orderNo < self.selection.orderedPoints.B.partNum) {
                    part.selected = FDSelection.Middle;
                }
            }
        }
    }

    
}

-(BOOL)sortSelectionPoints
{
    
    BOOL oneParaSel;
    //NSLog(@"trans compare recIds: %d %d",
    //                             self.selectionPoints.A.record.recordId,
    //                             self.selectionPoints.B.record.recordId);
    if (self.selection.selectionPoints.A.record.recordId == self.selection.selectionPoints.B.record.recordId) {
        // we are in 1 record and both are paragraphs
        if (self.selection.selectionPoints.A.partNum == self.selection.selectionPoints.B.partNum) {
            oneParaSel = YES;
            // sorting within 1 para
            if (self.selection.selectionPoints.A.cellNum > self.selection.selectionPoints.B.cellNum) {
                [self sortSelectionReverseOrder];
            } else {
                [self sortSelectionNormalOrder];
            }
        } else {
            // different parts, we have to select whole parts
            oneParaSel = false;
            if (self.selection.selectionPoints.A.partNum > self.selection.selectionPoints.B.partNum) {
                [self sortSelectionReverseOrder];
            } else {
                [self sortSelectionNormalOrder];
            }
        }
    } else {
        oneParaSel = false;
        if (self.selection.selectionPoints.A.record.recordId > self.selection.selectionPoints.B.record.recordId)
        {
            [self sortSelectionReverseOrder];
        } else {
            [self sortSelectionNormalOrder];
        }
    }
    
    // setting 
    if (oneParaSel) {
        
    } else {
        
    }
    return oneParaSel;
}

-(void)sortSelectionNormalOrder
{
    self.selection.orderedPoints.A = self.selection.selectionPoints.A;
    self.selection.orderedPoints.B = self.selection.selectionPoints.B;
}

-(void)sortSelectionReverseOrder
{
    self.selection.orderedPoints.A = self.selection.selectionPoints.B;
    self.selection.orderedPoints.B = self.selection.selectionPoints.A;
}

-(BOOL)getPosition:(EndlessTextViewHistoryPosition *)pos atPoint:(CGPoint)point
{
    int max = (int)[[self paintedRecords] count];
    
    for (int i = max - 1;i >= 0; i--) {
        FDRecordBase * base = [self.paintedRecords objectAtIndex:i];
        if (point.y > base.recordPaintOffset)
        {
            [pos setRecordId:base.recordId];
            [pos setOffset:-(point.y - base.recordPaintOffset)];
            return YES;
        }
    }
    
    return NO;
}

-(FDRecordLocation *)getHitLocation:(CGPoint)curr
{
    FDRecordLocation * hr = [[FDRecordLocation alloc] init];
    hr.x = curr.x;
    hr.y = curr.y;
    FDRecordBase * prev = nil;
    
    for(FDRecordBase * base in self.paintedRecords) {
        
        if ([base testHit:hr paddingLeft:self.drawer.paddingLeft paddingRight:self.drawer.paddingRight])
        {
            [hr.path insertObject:base atIndex:0];
            self.prevHitLocation = hr;
            return hr;
        }
        
        prev = base;
    }
    
    return nil;
}

-(FDRecordLocation *)getHitLocationOrPrevious:(CGPoint)curr
{
    FDRecordLocation * hr = [[FDRecordLocation alloc] init];
    hr.x = curr.x;
    hr.y = curr.y;
    FDRecordBase * prev = nil;
    
    for(FDRecordBase * base in self.paintedRecords) {
        
        if ([base testHit:hr paddingLeft:self.drawer.paddingLeft paddingRight:self.drawer.paddingRight])
        {
            [hr.path insertObject:base atIndex:0];
            self.prevHitLocation = hr;
            return hr;
        }
        
        prev = base;
    }

    return self.prevHitLocation;
}


-(BOOL)movementIndicated:(CGPoint)curr
{
    return (fabs(curr.x - self.lastX) >= self.moveSensitivityX) || (fabs(curr.y - self.lastY) >= self.moveSensitivityY);
}

-(void)onDragContent:(CGPoint)pt
{
}

-(void)onDragSelection:(CGPoint)pt
{
    if (self.selection.currentSelectionPoint >= 0) {
        
        [self processSelectionPoints:YES];

        FDRecordLocation * currentLocation = [self getHitLocationOrPrevious:pt];
        if (self.selection.currentSelectionPoint == 0)
            self.selection.selectionPoints.A = currentLocation;
        else
            self.selection.selectionPoints.B = currentLocation;
        
        [self processSelectionPoints:NO];
        
        self.needsDisplayRecordA = MIN(self.needsDisplayRecordA, self.selection.orderedPoints.A.record.recordId);
        self.needsDisplayRecordB = MAX(self.needsDisplayRecordB, self.selection.orderedPoints.B.record.recordId);
        [self setNeedsDisplayRecords];
    }
}

-(void)onDragSelectionEnd
{
    self.needsDisplayRecordA = -1;
    self.needsDisplayRecordB = -1;
    [self showEditMenuIfAppropriate];
}

-(void)showEditMenuIfAppropriate
{
    CGRect rect = [self bounds];
    BOOL changed = NO;
    CGFloat t =0;
    CGPoint pt;
    CGFloat left = 0;
    CGFloat right = 0;
    CGFloat top = rect.origin.y;
    CGFloat bottom = rect.origin.y + rect.size.height;
    if (self.selection.orderedPoints.A && self.selection.orderedPoints.A.hotSpot.y > 0)
    {
        changed = YES;
        pt.x = self.selection.orderedPoints.A.hotSpot.x;
        pt.y = self.selection.orderedPoints.A.hotSpot.y;
        t = MAX(rect.size.width - pt.x, pt.x);
        top = self.selection.orderedPoints.A.hotSpot.y;
        left = pt.x - t;
        right = pt.x + t;
    }
    else if (self.selection.orderedPoints.B && self.selection.orderedPoints.B.hotSpot.y > 0)
    {
        changed = YES;
        pt.x = self.selection.orderedPoints.A.hotSpot.x;
        pt.y = self.selection.orderedPoints.A.hotSpot.y;
        t = MAX(rect.size.width - pt.x, pt.x);
        bottom = pt.y;
        left = pt.x - t;
        right = pt.x + t;
    }
    
    if (changed)
    {
        rect.origin.y = top;
        rect.size.height = bottom - top;
        rect.origin.x = left;
        rect.size.width = right - left;
        [self.delegate endlessTextView:self selectionDidChange:rect];
    }
}

-(int)testHitSelectionPoint:(CGPoint)pt
{
    return [self.selection testHitSelectionPoint:pt];
}


- (void)addMissingRecords:(CGFloat *)yCurr_p width:(int)width pRecordId:(int *)iRecord_p
{
    CGFloat partHeight;
    while (*yCurr_p > 0) {
        if (*iRecord_p == 0) {
            *yCurr_p = 0;
            break;
        }
        (*iRecord_p)--;
        FDRecordBase * record = [self.dataSource getRawRecord:*iRecord_p];
        if (record != nil) {
            for (FDRecordPart * p in record.parts)
            {
                if (p.delegate == nil)
                    p.delegate = self.skinDelegate;
            }
            partHeight = [record validateForWidth:width];
            *yCurr_p -= partHeight;
        }
    }
    
    self.currentPosition.offset = *yCurr_p;
    self.currentPosition.recordId = *iRecord_p;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    NSLog(@"ETV drawRect %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    // Drawing code
    Canvas * canvas = [[Canvas alloc] init];
    int prevRec = self.currentPosition.recordId;
    int height = self.bounds.size.height;
    int width = self.bounds.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
 
    if (self.dataSource == nil)
        return;
    
    if (self.needsDisplayRecordsValid)
    {
        for(FDRecordBase * record in self.paintedRecords) {
            
            if (record.recordId < self.needsDisplayRecordA || record.recordId > self.needsDisplayRecordB)
                continue;
            
            if (record != nil) {
//                partHeight = [record validateForWidth:width];
                [self inCanvas:canvas drawRecord:record
                      position:record.recordPaintOffset
                         width:width];
            }
        }
        self.needsDisplayRecordsValid = NO;
    }
    else
    {
        [self.selection.orderedPoints resetHotSpots];
        
        //[@"Text" drawAtPoint:CGPointMake(10, 10) withFont:self.currentPaint.typeface];

        CGFloat yCurr = self.currentPosition.offset;
        CGFloat partHeight = 0;
        int iRecord = self.currentPosition.recordId;
        
        if (!self.emmbededInScroll)
        {
            [self addMissingRecords:&yCurr width:width pRecordId:&iRecord];
        }
        
        [self.paintedRecords removeAllObjects];
        BOOL currRepositioned = (yCurr >= 0.0);
        
        while(yCurr < height) {
            FDRecordBase * record = [self.dataSource getRawRecord:iRecord];
            
            if (record != nil) {
                [self.paintedRecords addObject:record];
                partHeight = [record validateForWidth:width];
                [self inCanvas:canvas drawRecord:record position:yCurr width:width];
            } else {
                partHeight = 1;
            }
            
            if (!self.emmbededInScroll)
            {
                if (yCurr + partHeight > 0 && !currRepositioned) {
                    self.currentPosition.recordId = iRecord;
                    self.currentPosition.offset = yCurr;
                    currRepositioned = YES;
                }
            }

            yCurr += partHeight;
            iRecord++;
        }
        
        if (prevRec != self.currentPosition.recordId) {
            if (self.delegate != nil) {
                //delegate.endlessTextViewRecordChanged(self.currentRecord);
            }
        }

        if (!self.emmbededInScroll)
        {
            [self handleFadeScrolling];
            if (self.fadeScrolling)
                [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0];
        }

        if (self.preparedContentOffsetValid && self.parentScrollView != nil)
        {
            [self.parentScrollView setContentOffset:self.preparedContentOffset];
            self.preparedContentOffsetValid = NO;
            self.preparedContentOffset = CGPointZero;
        }
    }
    
    // selection marks should be painted
    // here, since they have TOP priority of visibility
    if (canvas.startSelectionValid || canvas.endSelectionValid)
    {
        [canvas saveState];
        [canvas drawSelectionStart];
        [canvas drawSelectionEnd];
        [canvas restoreState];
        canvas.startSelectionValid = NO;
        canvas.endSelectionValid = NO;
    }
    
}

/**
 * This is handling of faded scrolling
 * We gradually decrease the speed of scrolling.
 * Finally if scroll is lower than 1.5 pixel, we stop fading.
 */

-(void)handleFadeScrolling {
    if (self.fadeScrolling) {
        if (self.lastDifferenceY > 1.5) {
            //NSLog(@"fade A");
            if (self.lastDifferenceY > 120) {
                self.lastDifferenceY = 120;
            }
            self.lastDifferenceY *= 0.8;
            self.currentPosition.offset += self.lastDifferenceY;
            [self setNeedsDisplay];
            //invalidate();
        } else if (self.lastDifferenceY < -1.5) {
            //NSLog(@"fade B");
            if (self.lastDifferenceY < -120) {
                self.lastDifferenceY = -120;
            }
            self.lastDifferenceY *= 0.8;
            self.currentPosition.offset += self.lastDifferenceY;
            //invalidate();
            [self setNeedsDisplay];
        } else {
            //NSLog(@"fade C");
            self.lastDifferenceY = 0;
            self.lastDifferenceX = 0;
            self.fadeScrolling = false;
            [self showEditMenuIfAppropriate];
        }
    }
}

-(void)inCanvas:(Canvas *)canvas drawRecord:(FDRecordBase *)record position:(float)yCurr width:(float)width
{
    BOOL savedState = NO;

    if (self.drawLineBeforeRecord) {
        //[canvas setPaint:self.currentPaint];
        CGContextSaveGState(canvas.context);
        [canvas setStrokeWidth:1.0];
        [canvas setStrokeColor:self.drawer.recordNumberColor];
        [canvas lineFrom:CGPointMake(0, yCurr)
                      to:CGPointMake(self.drawer.paddingLeft, yCurr)];
        savedState = YES;
    }
    if (self.drawRecordNumber) {
        if (!savedState)
            CGContextSaveGState(canvas.context);
        NSString * recordNum = [NSString stringWithFormat:@"%d", record.recordId];
        [canvas setFillColor:self.drawer.recordNumberColor];
         [recordNum drawAtPoint:CGPointMake(2, yCurr + 2)
                 withAttributes:self.drawer.recordNumberAttributes];
        savedState = YES;
    }
    if (record.recordMark != nil) {
        if (!savedState)
            CGContextSaveGState(canvas.context);
        [canvas setFillColor:self.drawer.recordMarkColor];
        [record.recordMark drawAtPoint:CGPointMake(8, yCurr + 2)
                              withAttributes:self.drawer.recordMarkAttributes];
        savedState = YES;
    }
    if (savedState) {
        CGContextRestoreGState(canvas.context);
        savedState = NO;
    }
    
    record.recordPaintOffset = yCurr;
    
    if (record.loading) {
    } else if ([record.parts count] > 0) {
        //Log.i("drawpane", "drawing -OK- record");
        float x = self.drawer.paddingLeft;
        float y = yCurr;
        int order = 0;
        VBRecordNotes * notes;

        // draw note icon only if not interferring with history buttons
        notes = [self.dataSource recordNotesForRecord:record.recordId];
        if (y > 64 && notes.noteText && ([notes.noteText length] > 0)) {
            [canvas drawImage:[self.skinDelegate endlessTextViewRecordNoteImage]
                         rect:CGRectMake(10, y+4, 32, 32)];
            record.noteIcon = true;
        }
        
        /*if ([self.dataSource recordHasBookmark:record.recordId])
        {
            [canvas drawImage:[self.skinDelegate endlessTextViewBookmarkImage]
                         rect:CGRectMake(width + self.paddingLeft + 10, yCurr + 4, 32, 32)];
        }*/
        
        FDHighlightTracker * tracker = nil;
        
        if (notes && notes.anchorsCount > 0)
        {
            tracker = [[FDHighlightTracker alloc] init];
            tracker.charCounter = 0;
            tracker.notes = notes;
            tracker.highlighterIndex = 0;
            tracker.anchor = [notes anchorAtIndex:0];
        }

        canvas.orderedPoints = self.selection.orderedPoints;
        canvas.anchor = tracker;
        canvas.phrases = self.highlightPhrases;
        
        for (FDRecordPart * rp in record.parts) {
            if (rp.delegate == nil)
                rp.delegate = self.skinDelegate;
            rp.orderNo = order;
            rp.absoluteTop = y;
            rp.absoluteRight = width + self.drawer.paddingLeft;
            
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

            y += [rp drawWithCanvas:canvas
                             xstart:x
                             ystart:y];
            
            //rp.draw(canvas, x, y, orderedPoints, anch);
            rp.absoluteBottom = y;
            order++;
        }
        
        if (self.selection.currentRecordLeftHighlighter == record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(0, yCurr, self.drawer.paddingLeft, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
        else if (self.selection.currentRecordRightHighlighter == record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(width + self.drawer.paddingLeft, yCurr, self.drawer.paddingRight, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
    }
}


-(NSString *)getSelectedText:(BOOL)b
{
    NSMutableString * sb = [[NSMutableString alloc] init];
    int firstRecId = -1;
    if (self.selection.orderedPoints.A != nil && self.selection.orderedPoints.B != nil) {
        firstRecId = self.selection.orderedPoints.A.record.recordId;
        for(int i = firstRecId; i <= self.selection.orderedPoints.B.record.recordId; i++) {
            FDRecordBase * rd = [self.dataSource getRawRecord:i];
            for(FDRecordPart * part in rd.parts) {
                [part getSelectedText:sb];
            }
            [sb appendString:@"\n"];
        }
    }
    
    if (b && firstRecId >= 0) {
        [sb appendFormat:@"\n[%@]\n\n", [self.dataSource getRecordPath:firstRecId]];
    }
    
    return sb;
}

-(void)clearSelection
{
    if (self.selection.orderedPoints.A != nil && self.selection.orderedPoints.B != nil) {
        for(int i = self.selection.orderedPoints.A.record.recordId;
            i <= self.selection.orderedPoints.B.record.recordId; i++) {
            FDRecordBase * rd = [self.dataSource getRawRecord:i];
            [rd clearSelection];
        }
    }
}

-(BOOL)getSelectedRangeOfTextStartRec:(int *)pFromGlobRecId startIndex:(int *)pStartIndex endRec:(int *)pToGlobRecId endIndex:(int *)pEndIndex
{
    return [self.selection getSelectedRangeOfTextStartRec:pFromGlobRecId
                                        startIndex:pStartIndex
                                            endRec:pToGlobRecId
                                          endIndex:pEndIndex];
}


-(void)saveUIState
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:[NSNumber numberWithDouble:[FDCharFormat multiplyFontSize]]
                 forKey:@"FDCharFormat_multiplyFontSize"];
    
    [settings setObject:[NSNumber numberWithDouble:[FDCharFormat multiplySpaces]]
                 forKey:@"FDCharFormat_multiplySpace"];
    
    [settings setObject:[FDTypeface defaultFontName]
                 forKey:@"FDTypeface_defaultFontName"];
    
    [settings setObject:[NSNumber numberWithDouble:[FDTypeface defaultFontSize]]
                 forKey:@"FDTypeface_defaultFontSize"];
    
    [settings setObject:[NSNumber numberWithBool:self.drawLineBeforeRecord]
                 forKey:@"ETV_lineBeforeRecord"];
    
    [settings setObject:[NSNumber numberWithBool:self.drawRecordNumber]
                 forKey:@"ETV_drawRecordNumber"];
    
    EndlessTextViewHistoryPosition * pos = [self currentTopPosition];
    [settings setInteger:pos.recordId forKey:@"lastTopRecordId"];
    [settings setDouble:pos.offset forKey:@"lastTopRecordOffset"];
    //NSLog(@"SAVE rec and offset: %d, %f", pos.recordId, pos.offset);
    
    
}

-(void)restoreUIState
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [FDCharFormat setMultiplyFontSize:[settings doubleForKey:@"FDCharFormat_multiplyFontSize"]];
    [FDCharFormat setMultiplySpaces:[settings doubleForKey:@"FDCharFormat_multiplySpace"]];
    [FDTypeface setDefaultFontName:[settings
                                    stringForKey:@"FDTypeface_defaultFontName"]];
    [FDTypeface setDefaultFontSize:[settings
                                    doubleForKey:@"FDTypeface_defaultFontSize"]];
    
    self.drawLineBeforeRecord = [settings boolForKey:@"ETV_lineBeforeRecord"];
    self.drawRecordNumber = [settings boolForKey:@"ETV_drawRecordNumber"];

}

-(void)restoreTextPosition
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];

    EndlessTextViewHistoryPosition * pos = [EndlessTextViewHistoryPosition new];
    pos.recordId = (int)[settings integerForKey:@"lastTopRecordId"];
    pos.offset = (float)[settings doubleForKey:@"lastTopRecordOffset"];
    
    //NSLog(@"RESTORE rec and offset: %d, %f", pos.recordId, pos.offset);
    self.currentTopPosition = pos;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Handling history


-(BOOL)canGoBack
{
    return (self.textHistoryPos > 0);
}

-(BOOL)canGoForward
{
    return (self.textHistoryPos < (self.textHistory.count - 1));
}

-(void)goBack
{
    if (self.textHistoryPos > 0)
    {
        self.textHistoryPos--;
        self.currentTopPosition = [self.textHistory objectAtIndex:self.textHistoryPos];
        [self setNeedsDisplay];
    }
}

-(void)goForward
{
    if (self.textHistoryPos < self.textHistory.count - 1)
    {
        self.textHistoryPos++;
        self.currentTopPosition = [self.textHistory objectAtIndex:self.textHistoryPos];
        [self setNeedsDisplay];
    }
}

-(void)setCurrentRecord:(int)recId
{
    [self setCurrentRecord:recId withOffset:0];
}

-(void)setCurrentRecord:(int)recId withOffset:(float)off
{
    while([self canGoForward])
    {
        [self.textHistory removeLastObject];
    }

    EndlessTextViewHistoryPosition * posx = [EndlessTextViewHistoryPosition new];
    posx.recordId = recId;
    posx.offset = off;
    [self.textHistory addObject:posx];
    self.textHistoryPos = self.textHistory.count - 1;
    self.currentTopPosition = posx;
    [self setNeedsDisplay];
}

-(void)setCurrentOffset:(float)off
{
    self.currentPosition.offset = off;
}

#pragma mark -

-(EndlessTextViewHistoryPosition *)currentTopPosition
{
    EndlessTextViewHistoryPosition * pos = [EndlessTextViewHistoryPosition new];
    [self getPosition:pos atPoint:self.parentScrollView.contentOffset];
    return pos;
}

-(void)setCurrentTopPosition:(EndlessTextViewHistoryPosition *)pos
{
    //self.currentPosition = pos;
    
    // try to go to previous records
    // but cannot go to lower than minimal record
    NSInteger minRec = [self.dataSource minimumRecord];
    int rec1 = pos.recordId;
    CGFloat sumHeight = pos.offset;
    CGFloat width = self.frame.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    
    if (rec1 > minRec || fabs(sumHeight) > 1.0)
    {
        CGFloat maxHeight = -self.frame.size.height * 2.0 / 5;
        while (rec1 > minRec && sumHeight > maxHeight)
        {
            rec1--;
            FDRecordBase * rec = [self.dataSource getRawRecord:rec1];
            if (rec != nil) {
                CGFloat recHeight = [rec validateForWidth:width];
                sumHeight -= recHeight;
            }
        }
        
        if (sumHeight < maxHeight)
        {
            self.currentPosition.offset = sumHeight - maxHeight;
            sumHeight = maxHeight;
        }
        else
        {
            self.currentPosition.offset = 0;
        }
        self.currentPosition.recordId = rec1;
        
        self.preparedContentOffset = CGPointMake(0, -sumHeight);
        self.preparedContentOffsetValid = YES;
    }
}


@end
