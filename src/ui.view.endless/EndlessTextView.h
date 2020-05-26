//
//  EndlessTextView.h
//  VedabaseB
//
//  Created by Peter Kollath on 28/07/14.
//
//

#import <UIKit/UIKit.h>
#import "VBFolio.h"
#import "EndlessTextViewDataSource.h"
#import "EndlessTextViewDelegate.h"
#import "EndlessTextViewSkinDelegate.h"
#import "FDTextHighlighter.h"
#import "EndlessTextViewHistoryPosition.h"
#import "FDDrawingProperties.h"
#import "FDSelectionContext.h"

@class FDRecordLocationPair;


@interface EndlessTextView : UIView <UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    UIImage * noteImage;
}

//@property VBFolio * source;
@property IBOutlet id<EndlessTextViewDataSource> dataSource;
@property IBOutlet id<EndlessTextViewSkinDelegate> skinDelegate;
@property IBOutlet id<EndlessTextViewDelegate> delegate;
@property IBOutlet FDDrawingProperties * drawer;
@property IBOutlet FDSelectionContext * selection;

@property FDTextHighlighter * highlightPhrases;

@property CGPoint lastMultitouchCenterPoint;
@property CGPoint multitouchCenterPoint;
@property int trackingMode;
//@property float offset;
//@property int currentRecord;
@property EndlessTextViewHistoryPosition * currentPosition;
@property NSMutableArray * textHistory;
@property NSUInteger textHistoryPos;

//public GestureDetector mDetector;
//public ScaleGestureDetector mScaleDetector;
@property BOOL drawLineBeforeRecord;
@property BOOL drawRecordNumber;
@property BOOL highlightBordersWhenRecordActive;

//public int touchMode = 0;
@property float startX;
@property float startY;
@property float lastX;
@property float lastY;
@property float startDist;
@property float lastDist;
@property float startRatio;
@property float lastRatio;
@property CGFloat lastScrollOffset;
@property int lastScrollDirection;
@property float scrollOffsetValid;
@property CGPoint preparedContentOffset;
@property BOOL preparedContentOffsetValid;

@property float moveSensitivityX;
@property float moveSensitivityY;
@property long longClickTimeout;

@property int currentTouchesCount;
@property CGPoint scrollStartOffset;

@property int needsDisplayRecordA;
@property int needsDisplayRecordB;
@property BOOL needsDisplayRecordsValid;

@property NSMutableArray/*<FDRecordBase>*/ * paintedRecords;


@property float lastDifferenceY;
@property float lastDifferenceX;
@property float sumDifferenceX;
@property float sumDifferenceY;
@property BOOL fadeScrolling;
@property NSInteger tapStartTime;

@property float pinchStartSize;
//@property int currentRecordLeftHighlighter;
//@property int currentRecordRightHighlighter;

@property IBOutlet UIScrollView * parentScrollView;
@property NSTimer * longTimer;
@property UIPinchGestureRecognizer * pinchRecognizer;
@property UIPanGestureRecognizer * panRecognizer;
@property UILongPressGestureRecognizer * longPressRecognizer;
@property UITapGestureRecognizer * tapRecognizer;
@property UISwipeGestureRecognizer * swipeToLeftRecognizer;
@property UISwipeGestureRecognizer * swipeToRightRecognizer;
@property EndlessTextViewHistoryPosition * currentTopPosition;
@property UIImage * backgroundImagePlane;
@property BOOL emmbededInScroll;

@property FDRecordLocation * prevHitLocation;


-(void)setNeedsDisplayRecords;
-(NSString *)getSelectedText:(BOOL)b;
-(BOOL)getSelectedRangeOfTextStartRec:(int *)pFromGlobRecId
                           startIndex:(int *)pStartIndex
                               endRec:(int *)pToGlobRecId
                             endIndex:(int *)pEndIndex;
-(void)clearSelection;

-(void)saveUIState;
-(void)restoreUIState;

#pragma mark -
#pragma mark Handling history

-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(void)goBack;
-(void)goForward;
-(void)setCurrentRecord:(int)recId;
-(void)setCurrentRecord:(int)recId withOffset:(float)off;
-(void)setCurrentOffset:(float)off;
-(void)handlePanGesture;
-(void)setScrollParent:(UIScrollView *)scrollView;
-(void)updateTextViewSize;
-(void)recalculateSizeAndTextOffset;
-(void)restoreTextPosition;
-(void)pageUp:(CGFloat)height;
-(void)pageDown:(CGFloat)height;

@end
