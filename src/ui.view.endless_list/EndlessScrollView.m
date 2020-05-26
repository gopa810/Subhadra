//
//  EndlessScrollView.m
//  VedabaseB
//
//  Created by Peter Kollath on 17/01/15.
//
//

#import "EndlessScrollView.h"
#import "EndlessParagraphView.h"
#import "EndlessScrollConstants.h"
#import "FDSelection.h"
#import "FDPartBase.h"
#import "FDParagraph.h"
#import "FDCharFormat.h"

@implementation EndlessScrollView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"drawRect in EndlessScrollView");
    [super drawRect:rect];
}
*/


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self selfInit];
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self selfInit];
    }
    return self;
}

-(void)setDataSource:(id<EndlessTextViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if ([self.recordViews count] > 0)
    {
        for (EndlessParagraphView * e in self.recordViews) {
            e.dataSource = dataSource;
        }
    }
}

-(void)selfInit
{
    self.animationPending = NO;
    self.fillingPending = NO;
    self.shouldFade = NO;
    self.pinchChangePending = NO;
    self.clipsToBounds = YES;
    self.recordViews = [NSMutableArray new];
    self.visibleViews = [[NSMutableArray alloc] initWithCapacity:200];
    self.position = [EndlessPosition new];
    self.selection = [FDSelectionContext new];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:self.tapGesture];
    
    self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLong:)];
    [self addGestureRecognizer:self.longGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:self.pinchGesture];
    
    self.swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    self.swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeRightGesture.delegate = self;
    [self addGestureRecognizer:self.swipeRightGesture];
    
    self.swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    self.swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeLeftGesture.delegate = self;
    [self addGestureRecognizer:self.swipeLeftGesture];
    
    self.selMarkViewA = [[EndlessSelectionMarkView alloc] initWithFrame:CGRectMake(0, 0, 48, 64)];
    //self.selMarkViewA.backgroundColor = [UIColor blueColor];
    self.selMarkViewA.hotSpotOffset = CGSizeMake(24, 61);
    self.selMarkViewA.reverseImage = NO;
    self.selMarkViewA.userInteractionEnabled = NO;
    self.selMarkViewA.hidden = YES;
    [self addSubview:self.selMarkViewA];
    
    self.selMarkViewB = [[EndlessSelectionMarkView alloc] initWithFrame:CGRectMake(0, 100, 48, 64)];
    self.selMarkViewB.reverseImage = YES;
    self.selMarkViewB.hotSpotOffset = CGSizeMake(24, 3);
    self.selMarkViewB.userInteractionEnabled = NO;
    self.selMarkViewB.hidden = YES;
    [self addSubview:self.selMarkViewB];
    
    self.textHistory = [NSMutableArray new];
    self.textHistoryPos = 0;
    [self.textHistory addObject:self.position];

    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)setSkin:(id<EndlessTextViewSkinDelegate>)skinManager
{
    self.skinManager = skinManager;
    self.selMarkViewA.image = [skinManager imageForName:@"selectionmark"];
    self.selMarkViewB.image = [skinManager imageForName:@"selectionmark"];
}

-(void)clearRecordViews
{
    for (EndlessParagraphView * ep in self.visibleViews) {
        [ep setFrame:CGRectMake(0, 3000, 1000, 100)];
        ep.record.recordView = nil;
        ep.visibleRecord = NO;
    }

    [self.visibleViews removeAllObjects];
}

-(void)refreshPartWithRecordId:(int)recId
{
    for(EndlessParagraphView * ep in self.visibleViews) {
        if (ep.recordId == recId)
        {
            [ep setNeedsDisplay];
        }
    }
}

#pragma mark -
#pragma mark handling gesture recognizers

-(FDRecordLocation *)getHitLocation:(CGPoint)pt
{
    EndlessParagraphView * ep = [self subviewWithPoint:pt];
    if (ep != nil)
    {
        CGPoint sub = [self convertPoint:pt toView:ep];
        return [ep getHitLocation:sub];
    }
    return nil;
}

-(FDRecordLocation *)getHitLocationOrPrevious:(CGPoint)pt
{
    EndlessParagraphView * ep = [self subviewWithPoint:pt];
    if (ep != nil)
    {
        CGPoint sub = [self convertPoint:pt toView:ep];
        return [ep getHitLocationOrPrevious:sub];
    }
    return nil;
}

-(void)handleLong:(id)sender
{
    int state = (int)self.longGesture.state;
    CGPoint pt = [self.longGesture locationInView:self];
    EndlessParagraphView * ep = [self subviewWithPoint:pt];
    self.shouldFade = NO;
    if (ep != nil)
    {
        pt = [self.longGesture locationInView:ep];
        [ep handleLong:state point:pt];
    }
}

-(void)handleTap:(id)sender
{
    int state = (int)self.tapGesture.state;
    CGPoint pt = [self.tapGesture locationInView:self];
    EndlessParagraphView * ep = [self subviewWithPoint:pt];
    self.shouldFade = NO;
    if (ep != nil)
    {
        pt = [self.tapGesture locationInView:ep];
        [ep handleTap:state point:pt];
    }
}

-(void)handlePan:(id)sender
{
    int state = (int)self.panGesture.state;
    
    if (state == UIGestureRecognizerStateBegan)
    {
        self.panStartPoint = [self.panGesture locationInView:self];
        if ([self testHitSelectionPoints:self.panStartPoint])
        {
            self.trackingMode = TRACK_DRAG_SELECTION;
        }
        else
        {
            self.trackingMode = TRACK_DRAG_CONTENT;
        }
    }
    else if (state == UIGestureRecognizerStateCancelled)
    {
    }
    else if (state == UIGestureRecognizerStateChanged)
    {
        CGPoint pt = [self.panGesture locationInView:self];
        if (self.trackingMode == TRACK_DRAG_CONTENT)
        {
            int state = [self checkRecordViewOver];
            CGFloat offset = pt.y - self.panStartPoint.y;
            if (state > 0)
            {
                offset *= 0.3;
            }
            [self moveViewsWithOffset:offset];
        }
        else if (self.trackingMode == TRACK_DRAG_SELECTION)
        {
            [self onDragSelection:pt];
        }
        self.panStartPoint = pt;
        [self saveCurrentPos];
        if ([self.delegate respondsToSelector:@selector(endlessTextView:topRecordChanged:)])
        {
            [self.delegate endlessTextView:self topRecordChanged:self.position.recordId];
        }
    }
    else if (state == UIGestureRecognizerStateEnded)
    {
        if (self.trackingMode == TRACK_DRAG_CONTENT)
        {
            int state = [self checkRecordViewOver];
            if (state == 0)
            {
                self.shouldFade = YES;
                [self fadeScrolling];
            }
            else
                [self startAdjustmentOver:state];
        }
        else if (self.trackingMode == TRACK_DRAG_SELECTION)
        {
            [self onDragSelectionEnd];
        }
    }
    else
    {
    }    
    
}

-(void)handlePinch:(id)sender
{
    int state = (int)self.pinchGesture.state;
    CGPoint location = [self.pinchGesture locationInView:self];
    if (state == UIGestureRecognizerStateBegan)
    {
        self.shouldFade = NO;
        [self clearSelection];
        self.pinchPending = YES;
        self.prevPinchScale = 0.0;
        self.pinchStartView = [self subviewWithPoint:location];
        CGRect viewRect = self.pinchStartView.frame;
        if (viewRect.size.height < 1)
            self.pinchStartPosition = 1.0;
        else
            self.pinchStartPosition = (location.y - viewRect.origin.y) / viewRect.size.height;
        if (self.pinchGesture.numberOfTouches == 2)
            self.pinchStartMultiplier = [FDCharFormat multiplyFontSize];
        else
            self.pinchStartMultiplier = [FDCharFormat multiplySpaces];
    }
    else if (state == UIGestureRecognizerStateChanged)
    {
        // change font multiplier
        NSLog(@"pinch scale: %f", self.pinchGesture.scale);
        //if (fabs(self.prevPinchScale - self.pinchGesture.scale) >= 0.1 && self.pinchGesture.scale < 4)
        {
            self.prevPinchScale = self.pinchGesture.scale;
            if ([self.pinchGesture numberOfTouches] == 2)
            {
                float V = self.pinchStartMultiplier * self.pinchGesture.scale;
                V = MAX(V, [FDCharFormat multiplyFontSizeMin]);
                V = MIN(V, [FDCharFormat multiplyFontSizeMax]);
                [FDCharFormat setMultiplyFontSize:V];
            }
            else
            {
                float V = self.pinchStartMultiplier * self.pinchGesture.scale;
                V = MAX(V, [FDCharFormat multiplySpacesMin]);
                V = MIN(V, [FDCharFormat multiplySpacesMax]);
                [FDCharFormat setMultiplySpaces:V];
            }
        
            [self rearrangeRecordViews:NO];
        }
    }
    else if (state == UIGestureRecognizerStateEnded)
    {
        self.pinchChangePending = NO;
        // do the same recalculation as for state change
        // but now for all paragraphs in self.visibleViews
        [self rearrangeRecordViews:YES];

        self.pinchPending = NO;
    }
    else
    {
        self.pinchPending = NO;
    }
}

- (void)swipeRightAction:(id)ignored
{
    [self.delegate endlessTextView:self swipeRight:[self.swipeRightGesture locationInView:self]];
}

- (void)swipeLeftAction:(id)ignored
{
    [self.delegate endlessTextView:self swipeLeft:[self.swipeLeftGesture locationInView:self]];
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
    if ([self canGoBack])
    {
        self.textHistoryPos--;
        EndlessPosition * pos = [self.textHistory objectAtIndex:self.textHistoryPos];
        [self setCurrentRecord:pos save:NO];
    }
}

-(void)goForward
{
    if ([self canGoForward])
    {
        self.textHistoryPos++;
        EndlessPosition * pos = [self.textHistory objectAtIndex:self.textHistoryPos];
        [self setCurrentRecord:pos save:NO];
    }
}

#pragma mark -
#pragma mark public methods

//
// we are adding 50 because we want to have it little lower
// not right under the top of screen
// because when header is displayed, then is would obscure the beginning of text
//

-(void)setCurrentRecord:(int)recId offset:(CGFloat)offset
{
    EndlessPosition * ep = [EndlessPosition new];
    ep.recordId = recId;
    ep.offset = offset + 50;
    [self setCurrentRecord:ep save:YES];
}

-(void)setCurrentRecord:(EndlessPosition *)pos save:(BOOL)saveToHistory
{
    [self saveCurrentPos];
    [self clearRecordViews];
    if (saveToHistory)
    {
        [self.textHistory addObject:pos];
        self.textHistoryPos = (int)self.textHistory.count - 1;
    }
    self.position = pos;
    
    EndlessParagraphView * epv = [self getFreeView];
    
    epv.frame = CGRectMake(0, pos.offset, self.frame.size.width, 100);
    epv.recordId = pos.recordId;
    
    
    for (EndlessParagraphView * ep in self.visibleViews) {
        ep.record.recordView = nil;
    }
    [self clearSelection];
    [self.visibleViews removeAllObjects];
    [self.visibleViews addObject:epv];
    
    [epv showRecord:pos.recordId align:0];
    
    if ([self.delegate respondsToSelector:@selector(endlessTextView:topRecordChanged:)])
    {
        [self.delegate endlessTextView:self topRecordChanged:pos.recordId];
    }
    
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
    
/*    [settings setObject:[NSNumber numberWithBool:self.drawLineBeforeRecord]
                 forKey:@"ETV_lineBeforeRecord"];
    
    [settings setObject:[NSNumber numberWithBool:self.drawRecordNumber]
                 forKey:@"ETV_drawRecordNumber"];
*/
    [self saveCurrentPos];
    
    [settings setInteger:self.position.recordId forKey:@"lastTopRecordId"];
    [settings setDouble:self.position.offset forKey:@"lastTopRecordOffset"];
//    NSLog(@"SAVE rec and offset: %d, %f", pos.recordId, pos.offset);
    
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
    
    //self.drawLineBeforeRecord = [settings boolForKey:@"ETV_lineBeforeRecord"];
    //self.drawRecordNumber = [settings boolForKey:@"ETV_drawRecordNumber"];
    
}

-(void)restoreTextPosition
{
    //NSLog(@"restoreTextPosition");
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    EndlessPosition * pos = [EndlessPosition new];
    pos.recordId = (int)[settings integerForKey:@"lastTopRecordId"];
    pos.offset = (float)[settings doubleForKey:@"lastTopRecordOffset"];

    [self setCurrentRecord:pos save:YES];
}

#pragma mark -
#pragma mark Navigation

-(void)pageUp:(CGFloat)height
{
    if (self.animationPending || self.fillingPending)
        return;
    // try to go to previous records
    // but cannot go to lower than minimal record
    NSInteger minRec = [self.dataSource minimumRecord];
    [self saveCurrentPos];
    int rec1 = self.position.recordId;
    CGFloat sumHeight = self.position.offset;
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
            sumHeight = maxHeight;
        }
        
        // move views with offset sumHeight
        [self animateMoveRecords:-sumHeight];
    }
}

-(void)pageDown:(CGFloat)height
{
    if (self.animationPending || self.fillingPending)
        return;
    // try to go to next records
    // but cannot go above maximum record
    CGFloat width = self.frame.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;
    //EndlessPosition * pos = [EndlessPosition new];
    EndlessParagraphView * ep = [self getRecordViewAtPos:CGPointMake(200, self.frame.size.height)];
    if (ep != nil)
    {
        NSInteger maxRec = [self.dataSource maximumRecord];
        CGFloat maxHeight = height;
        CGFloat sumHeight = 0;
        int rec1 = ep.recordId;
        while (rec1 < maxRec && sumHeight < maxHeight)
        {
            rec1++;
            FDRecordBase * rec = [self.dataSource getRawRecord:rec1];
            if (rec != nil) {
                CGFloat recHeight = [rec validateForWidth:width];
                sumHeight += recHeight;
            }
        }
        
        if (sumHeight > maxHeight)
            sumHeight = maxHeight;

        // move views with offset sumHeight
        [self animateMoveRecords:-sumHeight];
    }
}

#pragma mark -
#pragma mark Selection Management

-(BOOL)hasSelection
{
    return (self.selection.selectionPoints.A != nil && self.selection.selectionPoints.B != nil);
}

-(void)clearSelection
{
    [self processSelectionPoints:YES];
    self.selMarkViewA.hidden = YES;
    self.selMarkViewB.hidden = YES;
    self.selection.selectionPoints.A = nil;
    self.selection.selectionPoints.B = nil;
    self.selection.orderedPoints.A = nil;
    self.selection.orderedPoints.B = nil;
    self.selection.currentSelectionPoint = -1;
}

-(void)startSelectionContext
{
}

-(void)endSelectionContext
{
}

-(void)processSelectionPoints:(BOOL)clearSelection
{
    
    if (self.selection.selectionPoints.A == nil || self.selection.selectionPoints.B == nil)
        return;

    // sort selection points
    [self.selection sortSelectionPoints];

    // if selection covers more paragraphs
    // then we align selection to paragraph
    FDRecordLocation * start = self.selection.orderedPoints.A;
    FDRecordLocation * end = self.selection.orderedPoints.B;
    
    FDRecordBase * rec;
    if (clearSelection) {
        for(int i = start.recNum; i <= end.recNum; i++) {
            rec = [self.dataSource getRawRecord:i];
            for(FDRecordPart * part in rec.parts) {
                part.selected = FDSELECTION_NONE;
                for(FDPartBase * pbase in part.parts)
                {
                    pbase.selected = FDSELECTION_NONE;
                }
            }
            [rec.recordView setNeedsDisplay];
        }
    } else {
        for(int i = start.recNum; i <= end.recNum; i++) {
            rec = [self.dataSource getRawRecord:i];
            [self.selection applySelectionToRecord:rec];
        }
        
    }
}

-(void)onDragSelection:(CGPoint)pt
{
    if (self.selection.currentSelectionPoint == 0)
    {
        [self.selMarkViewA setHandleLocation:pt];
        pt = [self convertPoint:self.selMarkViewA.hotSpotLocation toView:self];
    }
    else if (self.selection.currentSelectionPoint == 1)
    {
        [self.selMarkViewB setHandleLocation:pt];
        pt = [self convertPoint:self.selMarkViewB.hotSpotLocation toView:self];
    }

    if (self.selection.currentSelectionPoint >= 0) {
        
        [self processSelectionPoints:YES];
        
        FDRecordLocation * currentLocation = [self getHitLocationOrPrevious:pt];
        if (self.selection.currentSelectionPoint == 0)
            self.selection.selectionPoints.A = currentLocation;
        else
            self.selection.selectionPoints.B = currentLocation;
        
        [self processSelectionPoints:NO];
    }
    
}

-(void)onDragSelectionEnd
{
    [self.selMarkViewA setHotSpotLocation:self.selection.hotSpotA];
    [self.selMarkViewB setHotSpotLocation:self.selection.hotSpotB];
    self.selection.selectionPoints.A = self.selection.orderedPoints.A;
    self.selection.selectionPoints.B = self.selection.orderedPoints.B;
    
    [self showEditMenuIfAppropriate];
}

-(void)showEditMenuIfAppropriate
{
    if (self.selMarkViewA.hidden == NO && self.selMarkViewB.hidden == NO)
    {
        CGRect rect = CGRectUnion(self.selMarkViewA.frame, self.selMarkViewB.frame);
        
        if (!CGRectIsNull(CGRectIntersection(rect, self.bounds)))
        {
            [self.delegate endlessTextView:self selectionDidChange:rect];
        }
    }

    return;
}

-(BOOL)testHitSelectionPoints:(CGPoint)curr
{
    if (self.selMarkViewA.hidden == NO && CGRectContainsPoint(self.selMarkViewA.frame, curr))
    {
        self.selMarkViewA.handlePoint = [self convertPoint:curr toView:self.selMarkViewA];
        self.selection.currentSelectionPoint = 0;
        return YES;
    }
    
    if (self.selMarkViewB.hidden == NO && CGRectContainsPoint(self.selMarkViewB.frame, curr))
    {
        self.selMarkViewB.handlePoint = [self convertPoint:curr toView:self.selMarkViewB];
        self.selection.currentSelectionPoint = 1;
        return YES;
    }
    
    return NO;
}

-(NSString *)getSelectedText:(BOOL)includeReference
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
    
    if (includeReference && firstRecId >= 0) {
        [sb appendFormat:@"\n[%@]\n\n", [self.dataSource getRecordPath:firstRecId]];
    }
    
    return sb;
}

#pragma mark -
#pragma mark private methods

-(EndlessParagraphView *)subviewWithPoint:(CGPoint)pt
{
    for (EndlessParagraphView * ep in self.visibleViews) {
        if (CGRectContainsPoint(ep.frame, pt))
            return ep;
    }
    
    return nil;
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.animationPending = NO;
    [self checkParagraphsFilling];
    [self showEditMenuIfAppropriate];
    
    [self saveCurrentPos];
    if ([self.delegate respondsToSelector:@selector(endlessTextView:topRecordChanged:)])
    {
        [self.delegate endlessTextView:self topRecordChanged:self.position.recordId];
    }
}

//
// returns actions needed to perform
// so layout of records looks consistent
//
// 1 - first visible view should be aligned to top of superview
//     its origin is higher that 0, should be set to 0
// 2 - first visible view should be aligned to top of superview
//     its origin is lower than 0, should be set to 0
// 3 - last visible view should be aligned with bottom of superview
-(int)checkRecordViewOver
{
    EndlessParagraphView * epv = [self.visibleViews firstObject];
    EndlessParagraphView * eph = [self.visibleViews lastObject];
    
    if (epv == nil || eph == nil)
        return 0;
    
    if (epv.headRecord)
    {
        if (epv.frame.origin.y > 0.5)
            return 1;
        if (!eph.tailRecord)
            return 0;
        if ((eph.frame.origin.y + eph.frame.size.height) < (self.frame.size.height - 0.5))
        {
            if (([eph bottomY] - [epv topY]) < (self.frame.size.height - 0.5))
                return 1;
            else
                return 3;
        }
        return 0;
    }
    else if (eph.tailRecord)
    {
        if (eph.frame.origin.y + eph.frame.size.height < self.frame.size.height - 0.5)
            return 3;
    }
    
    return 0;
    
}

-(void)startAdjustmentOver:(int)state
{
    if (state == 1 || state == 2)
    {
        CGFloat offset = ((EndlessParagraphView *)[self.visibleViews firstObject]).frame.origin.y;
        [self animateMoveRecords:-offset];
    }
    else if (state == 3)
    {
        CGRect frame = ((EndlessParagraphView *)[self.visibleViews lastObject]).frame;
        CGFloat offset = self.frame.size.height - frame.origin.y - frame.size.height;
        if (offset > 0.5)
            [self animateMoveRecords:offset];
    }
    else
    {
        [self showEditMenuIfAppropriate];
    }
}

- (void)animateMoveRecords:(CGFloat)offset
{
    self.animationPending = YES;
    [UIView beginAnimations:@"adjustViews" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    for (EndlessParagraphView * epp in self.visibleViews) {
        CGRect orig = epp.frame;
        epp.frame = CGRectOffset(orig, 0, offset);
    }
 
    self.selMarkViewA.frame = CGRectOffset(self.selMarkViewA.frame, 0, offset);
    self.selMarkViewB.frame = CGRectOffset(self.selMarkViewB.frame, 0, offset);
    
    [UIView commitAnimations];
}

-(EndlessParagraphView *)getFreeView
{
    for (EndlessParagraphView * epv in self.recordViews)
    {
        if (epv.visibleRecord == NO)
        {
            epv.visibleRecord = YES;
            return epv;
        }
    }
    
    EndlessParagraphView * subview = [[EndlessParagraphView alloc] initWithFrame:CGRectMake(0, -2000, 100, 100)];
    //self.aSubview = subview;
    subview.backgroundColor = self.backgroundColor;
    subview.userInteractionEnabled = NO;
    subview.drawer = self.drawer;
    subview.manager = self;
    subview.record = nil;
    subview.dataSource = self.dataSource;
    subview.headRecord = NO;
    subview.tailRecord = NO;
    subview.visibleRecord = YES;
    [self.recordViews addObject:subview];

    [self addSubview:subview];
    
    [self bringSubviewToFront:self.selMarkViewA];
    [self bringSubviewToFront:self.selMarkViewB];
    
    return subview;
}

-(void)endlessViewDidShow:(EndlessParagraphView *)view
{
    //NSLog(@"view did show: %d with height %f", view.recordId, view.frame.size.height);
    [self checkParagraphsFilling];
    
    if (view.resetPinchChangePending)
    {
        view.resetPinchChangePending = NO;
        self.pinchChangePending = NO;
    }
}

//
// this is main functions for ensuring that
// screen is filled with paragraphs
//
// executed:
//    - after displaying single record view
//    - after moving record views
//
-(void)checkParagraphsFilling
{
    int nextRec;
    EndlessParagraphView * last = [self.visibleViews lastObject];
    if (last != nil)
    {
        if (last.bottomY < self.frame.size.height*2)
        {
            if (last.recordId < [self.dataSource maximumRecord])
            {
                EndlessParagraphView * newView = [self getFreeView];
                newView.frame = CGRectMake(10,last.bottomY + 1, 100, 100);
                [self.visibleViews addObject:newView];
                nextRec = last.recordId + 1;
                [newView showRecord:nextRec align:0];
                self.fillingPending = YES;
                return;
            }
        }

        while ([last topY] > self.frame.size.height*2)
        {
            //NSLog(@"ESV.MAINTAIN removing view at index %d", (int)[self.visibleViews count]-1);
            last.visibleRecord = NO;
            [last.record setRecordView:nil];
            [self.visibleViews removeLastObject];
            last = [self.visibleViews lastObject];
        }
    }
    

    EndlessParagraphView * first = [self.visibleViews firstObject];
    if (first != nil)
    {
        if (first.topY > -self.frame.size.height)
        {
            if (first.recordId > [self.dataSource minimumRecord])
            {
                EndlessParagraphView * newView = [self getFreeView];
                newView.frame = CGRectMake(10,[first topY] - 101, 100, 100);
                newView.recordId = first.recordId - 1;
                [self.visibleViews insertObject:newView atIndex:0];
                [newView showRecord:newView.recordId align:1];
                self.fillingPending = YES;
                return;
            }
        }
        
        while([first bottomY] < -self.frame.size.height)
        {
            //NSLog(@"ESV.MAINTAIN removing view at index 0");
            [first.record setRecordView:nil];
            first.visibleRecord = NO;
            [self.visibleViews removeObjectAtIndex:0];
            first = [self.visibleViews firstObject];
        }
    }

    self.fillingPending = NO;
}

-(void)moveViewsWithOffset:(CGFloat)yDiff
{
    self.lastScrollOffsetY = yDiff;
    
    for (EndlessParagraphView * ep in self.visibleViews)
    {
        CGRect rc = ep.frame;
        ep.frame = CGRectOffset(rc, 0, yDiff);
    }
    
    self.selMarkViewA.frame = CGRectOffset(self.selMarkViewA.frame, 0, yDiff);
    self.selMarkViewB.frame = CGRectOffset(self.selMarkViewB.frame, 0, yDiff);
    
    [self checkParagraphsFilling];
}

-(void)fadeScrolling
{
    int status = [self checkRecordViewOver];
    CGFloat ratio = ((status == 0) ? 0.95 : 0.5);
    
    if (self.shouldFade && self.lastScrollOffsetY > 1.0)
    {
        CGFloat off = self.lastScrollOffsetY * ratio;
        if (self.lastScrollOffsetY > 1.0)
        {
            [self moveViewsWithOffset:off];
            [self performSelector:@selector(fadeScrolling) withObject:nil afterDelay:0.01];
        }
    }
    else if (self.shouldFade && self.lastScrollOffsetY < -1.0)
    {
        CGFloat off = self.lastScrollOffsetY * ratio;
        if (self.lastScrollOffsetY < -1.0)
        {
            [self moveViewsWithOffset:off];
            [self performSelector:@selector(fadeScrolling) withObject:nil afterDelay:0.01];
        }
    }
    else
    {
        [self startAdjustmentOver:status];
        self.lastScrollOffsetY = 0;
        self.shouldFade = NO;
    }
}

-(void)setNeedsDisplayRecord:(int)recId
{
    for (EndlessParagraphView * ep in self.visibleViews) {
        if (ep.recordId == recId)
        {
            ep.record.calculatedWidth = 0;
            [ep setNeedsDisplay];
        }
    }
}

-(void)rearrangeForOrientation
{
    self.pinchStartPosition = 0;
    self.pinchStartView = [self getRecordViewAtPos:CGPointMake(0, 0)];
    if (self.pinchStartView != nil)
    {
        [self rearrangeRecordViews:YES];
    }
}

- (void)rearrangeRecordViews:(BOOL)allViews
{
    if (self.pinchChangePending == YES)
    {
        NSLog(@"- omit pinch");
        return;
    }
    self.pinchChangePending = YES;
    //if (allViews == NO)        [self performSelectorOnMainThread:@selector(rearrangeRecordViewsAsync2:) withObject:@NO waitUntilDone:NO];    else
    [self performSelectorOnMainThread:@selector(rearrangeRecordViewsAsync:)
                           withObject:[NSNumber numberWithBool:allViews]
                        waitUntilDone:NO];
}

- (void)rearrangeRecordViewsAsync:(NSNumber *)allViewsObj
{
    //NSLog(@"- accepted pinch");
    EndlessParagraphView * last = self.pinchStartView;
    BOOL allViews = [allViewsObj boolValue];
    // recalculate size for all paragraphs on screen and change their size
    //   - find index of pinchStartView
    NSInteger index = [self.visibleViews indexOfObject:self.pinchStartView];
    
    //   - pinchStartView resize according pinchStartPosition
    CGRect baseRect = [self.pinchStartView rearrangeByPosition:self.pinchStartPosition];
    [self.pinchStartView setNeedsDisplay];
    CGRect aboveRect = baseRect;
    CGRect underRect = baseRect;
    NSInteger aboveIndex = index - 1;
    NSInteger underIndex = index + 1;
    
    //if (allViews)
    {
        //   - previous views resize in one way (align bottom to next)
        while ((aboveRect.origin.y + aboveRect.size.height > 0 || allViews) && aboveIndex >= 0)
        {
            EndlessParagraphView * ep = [self.visibleViews objectAtIndex:aboveIndex];
            aboveRect = [ep rearrangeByBottom:aboveRect.origin.y];
            [ep setNeedsDisplay];
            aboveIndex--;
        }
        
        //   - next views resize in second way (align top to previous)
        while ((underRect.origin.y < self.frame.size.height || allViews) && underIndex < self.visibleViews.count)
        {
            EndlessParagraphView * ep = [self.visibleViews objectAtIndex:underIndex];
            underRect = [ep rearrangeByTop:underRect.origin.y + underRect.size.height];
            [ep setNeedsDisplay];
            underIndex++;
        }
    }
    
    if (last != nil)
        last.resetPinchChangePending = YES;
    //self.pinchChangePending = NO;
}

- (void)rearrangeRecordViewsAsync2:(NSNumber *)allViewsObj
{
    //NSLog(@"- accepted pinch");
    EndlessParagraphView * last = self.pinchStartView;
    BOOL allViews = [allViewsObj boolValue];
    // recalculate size for all paragraphs on screen and change their size
    //   - find index of pinchStartView
    NSInteger index = [self.visibleViews indexOfObject:self.pinchStartView];
    
    //   - pinchStartView resize according pinchStartPosition
    CGRect frame = self.pinchStartView.frame;
    CGFloat yb = frame.origin.y + frame.size.height * self.pinchStartPosition;
    frame.size.height *= self.pinchGesture.scale;
    frame.size.width *= self.pinchGesture.scale;
    frame.origin.y = yb - frame.size.height * self.pinchStartPosition;
    self.pinchStartView.frame = frame;
//    CGRect baseRect = [self.pinchStartView rearrangeByPosition:self.pinchStartPosition];
//    [self.pinchStartView setNeedsDisplay];
    CGRect aboveRect = frame;
    CGRect underRect = frame;
    NSInteger aboveIndex = index - 1;
    NSInteger underIndex = index + 1;
    
    //   - previous views resize in one way (align bottom to next)
    while ((aboveRect.origin.y + aboveRect.size.height > 0 || allViews) && aboveIndex >= 0)
    {
        EndlessParagraphView * ep = [self.visibleViews objectAtIndex:aboveIndex];
        frame = ep.frame;
        frame.size.height *= self.pinchGesture.scale;
        frame.size.width *= self.pinchGesture.scale;
        frame.origin.y = aboveRect.origin.y - frame.size.height;
        ep.frame = frame;
        aboveRect = frame;
        aboveIndex--;
        last = ep;
    }
    
    //   - next views resize in second way (align top to previous)
    while ((underRect.origin.y < self.frame.size.height || allViews) && underIndex < self.visibleViews.count)
    {
        EndlessParagraphView * ep = [self.visibleViews objectAtIndex:underIndex];
        frame = ep.frame;
        frame.size.height *= self.pinchGesture.scale;
        frame.size.width *= self.pinchGesture.scale;
        frame.origin.y = underRect.origin.y + underRect.size.height;
        ep.frame = frame;
        underRect = frame;
        underIndex++;
        last = ep;
    }
    
    if (last != nil)
        last.resetPinchChangePending = YES;
    //self.pinchChangePending = NO;
}

-(EndlessParagraphView *)getRecordViewAtPos:(CGPoint)point
{
    EndlessParagraphView * last = nil;
    for (EndlessParagraphView * ep in self.visibleViews) {
        if (ep.frame.origin.y <= point.y)
        {
            last = ep;
        }
        else
        {
            break;
        }
    }
    
    if (last == nil && self.visibleViews.count > 0)
    {
        last = [self.visibleViews lastObject];
        if (!CGRectContainsPoint(last.frame, point))
            last = nil;
    }

    return last;
}

//
// updates value of self.position
// according current situation in views
//
-(void)saveCurrentPos
{
    EndlessParagraphView * last = [self getRecordViewAtPos:CGPointMake(0, 0)];
    
    if (last != nil)
    {
        self.position.recordId = last.recordId;
        self.position.offset = last.frame.origin.y;
    }
}

@end
