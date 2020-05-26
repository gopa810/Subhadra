//
//  VBUnicodeWordMatcher.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/15/13.
//
//

#import <Foundation/Foundation.h>

#define CompareModeNormal 0
#define CompareModeWild 1
#define CompareModeWaitForEnd 2
#define CompareModeRequiredEnd 3
#define CompareModeRequiredStart 4
#define CompareModeWaitStartWord 5

@interface VBUnicodeWordMatchThread : NSObject

@property NSString * word;
@property int compareMode;
// index in word
@property NSInteger currIndex;
@property NSInteger partIndex;
@property BOOL activeThread;

-(id)initWithWord:(NSString *)str;
-(int)checkWildCard;
-(BOOL)matchingIsOver;
-(unichar)currentChar;

@end

@interface VBUnicodeWordMatcher : NSObject


@property NSString * word;
// indexes in text
@property NSInteger startIndex;
@property NSInteger lastIndex;
@property NSMutableArray * threads;
@property NSInteger startFindRange;
@property NSInteger lastFindIndex;

-(BOOL)sendChar:(unichar)chr atIndex:(int)index;
-(NSRange)range;

@end
