//
//  EndlessScrollView.h
//  VedabaseB
//
//  Created by Peter Kollath on 17/01/15.
//
//

#import <UIKit/UIKit.h>
#import "EndlessPosition.h"
#import "EndlessTextViewDelegate.h"
#import "EndlessTextViewDataSource.h"
#import "FDDrawingProperties.h"
#import "FDSelectionContext.h"
#import "FDRecordLocation.h"
#import "EndlessSelectionMarkView.h"

@class EndlessParagraphView;

@interface EndlessScrollView : UIView <UIGestureRecognizerDelegate>


@property UITapGestureRecognizer * tapGesture;
@property UIPanGestureRecognizer * panGesture;
@property UILongPressGestureRecognizer * longGesture;
@property UIPinchGestureRecognizer * pinchGesture;
@property UISwipeGestureRecognizer * swipeLeftGesture;
@property UISwipeGestureRecognizer * swipeRightGesture;
@property CGPoint panStartPoint;
@property FDDrawingProperties * drawer;
@property FDSelectionContext * selection;
@property NSMutableArray * recordViews;
@property NSMutableArray * visibleViews;
@property CGFloat lastScrollOffsetY;
@property FDRecordLocation * prevHitLocation;
@property CGPoint lastMultitouchCenterPoint;
@property CGPoint multitouchCenterPoint;
@property int trackingMode;
@property int needsDisplayRecordA;
@property int needsDisplayRecordB;
@property BOOL needsDisplayRecordsValid;
@property BOOL pinchPending;
@property BOOL pinchChangePending;
@property EndlessParagraphView * pinchStartView;
@property CGFloat pinchStartPosition;
@property CGFloat pinchStartMultiplier;
@property BOOL animationPending;
@property BOOL fillingPending;
@property CGFloat prevPinchScale;
@property BOOL shouldFade;

// history of records
@property NSMutableArray * textHistory;
@property NSUInteger textHistoryPos;
@property IBOutlet EndlessPosition * position;

// selection mark views
@property EndlessSelectionMarkView * selMarkViewA;
@property EndlessSelectionMarkView * selMarkViewB;

@property (nonatomic) IBOutlet id<EndlessTextViewDataSource> dataSource;
@property IBOutlet id<EndlessTextViewSkinDelegate> skinManager;
@property IBOutlet id<EndlessTextViewDelegate> delegate;

-(void)clearRecordViews;
-(void)endlessViewDidShow:(EndlessParagraphView *)view;
-(void)setCurrentRecord:(int)recId offset:(CGFloat)offset;
-(void)setSkin:(id<EndlessTextViewSkinDelegate>)skinManager;
-(void)refreshPartWithRecordId:(int)recId;

// history management

-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(void)goBack;
-(void)goForward;
-(void)saveCurrentPos;
-(void)saveUIState;
-(void)restoreUIState;
-(void)restoreTextPosition;

// navigation
-(void)pageUp:(CGFloat)height;
-(void)pageDown:(CGFloat)height;
-(void)rearrangeForOrientation;

// Selection Management

-(BOOL)hasSelection;
-(void)clearSelection;
-(void)startSelectionContext;
-(void)endSelectionContext;
-(void)processSelectionPoints:(BOOL)clearSelection;
-(void)onDragSelection:(CGPoint)pt;
-(void)onDragSelectionEnd;
-(NSString *)getSelectedText:(BOOL)includeReference;
-(void)setNeedsDisplayRecord:(int)recId;

@end
