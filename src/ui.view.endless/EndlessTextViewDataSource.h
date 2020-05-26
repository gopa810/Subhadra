//
//  EndlessTextViewDataSource.h
//  VedabaseB
//
//  Created by Peter Kollath on 14/08/14.
//
//

#import <Foundation/Foundation.h>

@class EndlessTextView;
@class FDRecordBase;
@class VBRecordNotes;

@protocol EndlessTextViewDataSource <NSObject>

-(FDRecordBase *)getRawRecord:(unsigned int)recid;
-(int)getRecordCount;
-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId;
-(NSString *)getRecordPath:(int)record;
-(id)findObject:(NSString *)strName;
-(BOOL)recordHasNote:(int)recid;
-(BOOL)recordHasBookmark:(int)recid;
-(int)bookmarksCount;
-(BOOL)canHaveBookmarks;
-(BOOL)canHaveNotes;
-(NSInteger)minimumRecord;
-(NSInteger)maximumRecord;

@end
