//
//  EndlessParagraphView.h
//  VedabaseB
//
//  Created by Peter Kollath on 17/01/15.
//
//

#import <UIKit/UIKit.h>
#import "FDRecordBase.h"
#import "VBRecordNotes.h"
#import "FDDrawingProperties.h"
#import "EndlessTextViewDataSource.h"
#import "FDSelectionContext.h"

#define EPV_POS_FIRST    1
#define EPV_POS_MIDDLE   2
#define EPV_POS_LAST     3


@class EndlessScrollView;

@interface EndlessParagraphView : UIView

@property BOOL headRecord;
@property BOOL tailRecord;
@property BOOL visibleRecord;
@property BOOL resetPinchChangePending;
@property int recordId;
@property FDRecordBase * record;
@property VBRecordNotes * notes;
@property (weak) FDDrawingProperties * drawer;
@property EndlessScrollView * manager;
@property (weak) id<EndlessTextViewDataSource> dataSource;

-(void)handleTap:(int)recognizerState point:(CGPoint)current;
-(void)handleLong:(int)recognizerState point:(CGPoint)current;
-(void)showRecord:(int)recId align:(int)align;
-(CGFloat)topY;
-(CGFloat)bottomY;


-(FDRecordLocation *)getHitLocation:(CGPoint)curr;
-(FDRecordLocation *)getHitLocationOrPrevious:(CGPoint)curr;

-(CGRect)rearrangeByPosition:(CGFloat)pos;
-(CGRect)rearrangeByTop:(CGFloat)top;
-(CGRect)rearrangeByBottom:(CGFloat)bottom;

@end

