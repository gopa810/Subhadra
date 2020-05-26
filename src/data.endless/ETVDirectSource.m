//
//  ETVDirectSource.m
//  VedabaseB
//
//  Created by Peter Kollath on 14/08/14.
//
//

#import "ETVDirectSource.h"

@implementation ETVDirectSource

-(id)init
{
    self = [super init];
    if (self)
    {
        self.maxRec = -1;
    }
    return self;
}

-(FDRecordBase *)getRawRecord:(unsigned int)recid
{
    return [self.folio.firstStorage getRawRecord:recid];
}

-(NSInteger)minimumRecord
{
    return 0;
}

-(NSInteger)maximumRecord
{
    if (self.maxRec < 0)
    {
        self.maxRec = [self getRecordCount] - 1;
    }
    return self.maxRec;
}

-(int)getRecordCount
{
	return (int)[self.folio.firstStorage textCount];
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    return [self.folio.firstStorage recordNotesForRecord:recId];
}

-(NSString *)getRecordPath:(int)record
{
    return [self.folio.firstStorage getRecordPath:record];
}

-(id)findObject:(NSString *)strName
{
    return [self.folio.firstStorage findObject:strName];
}

-(BOOL)recordHasNote:(int)recid
{
    VBRecordNotes * notes = [self.folio.firstStorage recordNotesForRecord:recid];
    return (notes != nil && [notes hasText]);
}

-(BOOL)recordHasBookmark:(int)recid
{
    /*NSArray * bookmarks = [self.folio.firstStorage bookmarks];
    for (VBBookmark * bk in bookmarks)
    {
        if (bk.recordId == recid)
            return YES;
    }*/
    return NO;
}

-(int)bookmarksCount
{
    return (int)[self.folio.firstStorage.bookmarks count];
}

-(BOOL)canHaveBookmarks
{
    return YES;
}

-(BOOL)canHaveNotes
{
    return YES;
}


@end
