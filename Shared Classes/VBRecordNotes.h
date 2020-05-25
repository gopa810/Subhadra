//
//  VBRecordNotes.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import <Foundation/Foundation.h>
#import "VBHighlighterAnchor.h"

@interface VBRecordNotes : NSObject

@property NSInteger ID;
@property NSInteger parentId;
@property NSInteger noteParentID;

@property NSMutableArray * p_highs;
@property uint32_t p_recId;

// path for record given by recId
@property (nonatomic, copy) NSString * recordPath;

// extracted part of highlighted text
@property (nonatomic, retain) NSString * highlightedText;

// text of NOTE
@property (nonatomic,copy) NSString * noteText;

// creation date and time
@property (nonatomic, retain) NSDate * createDate;

// modification date and time
@property (nonatomic, retain) NSDate * modifyDate;

// list of highlighter start/stop tags
// array of VBHighlighterAnchor objects
@property (nonatomic,readonly) NSArray * anchors;

// record ID
@property (assign) uint32_t recordId;

-(void)setHighlighter:(int)highlighterId fromChar:(int)start endChar:(int)stop;
-(int)anchorsCount;
-(VBHighlighterAnchor *)anchorAtIndex:(int)index;
-(BOOL)hasText;
-(void)refreshHighlightedTextWithString:(NSString *)str;
-(void)removeAllAnchors;

-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;
-(void)logDumpAnchors;

@end
