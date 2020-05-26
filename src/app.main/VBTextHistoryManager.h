//
//  VBTextHistoryManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 17/09/14.
//
//

#import <Foundation/Foundation.h>

@interface VBTextHistoryManager : NSObject

@property NSMutableArray * textHistory;
@property NSMutableArray * offsetHistory;
@property NSInteger textHistoryCurr;

-(NSUInteger)historyGetPrev;
-(NSUInteger)historyGetNext;
-(float)historyGetCurrentOffset;
-(void)historyPushTop:(NSUInteger)recID offset:(float)textOffset;
-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(void)historyChangeTop:(NSUInteger)recID offset:(float)textOffset;
-(BOOL)isAtTopOfHistory;
-(void)saveCurrent:(int)currId new:(int)newRecordId offset:(float)textOffset;

@end
