//
//  ETVRecords.m
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import "ETVRecords.h"
#import "VBFolio.h"
#import "VBFolioStorage.h"

@implementation ETVRecords

-(NSInteger)minimumRecord
{
    return 0;
}

-(NSInteger)maximumRecord
{
    return self.records.count - 1;
}

-(FDRecordBase *)getRawRecord:(unsigned int)recid
{
    if ([self.records count] <= recid)
        return nil;
    FDRecordBase * record = [self getRecordFromArray:recid];
    if (record == nil || record.linkedRecordId < 0)
    {
        NSNumber * rec = [self.records objectAtIndex:recid];
        record = [self.folio.firstStorage getRawRecord:[rec intValue]];
        FDRecordBase * recCopy = [record lightCopy];
        recCopy.linkedRecordId = recCopy.recordId;
        recCopy.recordId = recid;
        [self setRecord:recCopy toIndex:recid];
        record = recCopy;
    }
    
    return record;
}


-(FDRecordBase *)getRecordFromArray:(int)recid
{
    if ([self.rawRecords count] <= recid)
        return nil;
    return [self.rawRecords objectAtIndex:recid];
}

-(void)setRecord:(FDRecordBase *)record toIndex:(int)idx
{
    if (self.rawRecords == nil)
    {
        self.rawRecords = [[NSMutableArray alloc] initWithCapacity:self.records.count];
    }
    
    if ([self.rawRecords count] <= idx)
    {
        [self.rawRecords addObject:[FDRecordBase new]];
    }
    
    [self.rawRecords replaceObjectAtIndex:idx withObject:record];
}


-(int)originalRecordAtIndex:(int)recid
{
    if ([self.records count] <= recid)
        return 0;
    NSNumber * rec = [self.records objectAtIndex:recid];
    return [rec intValue];
}

-(int)getRecordCount
{
    return (int)[self.records count];
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    return nil;
}

-(NSString *)getRecordPath:(int)record
{
    return self.title;
}

-(id)findObject:(NSString *)strName
{
    return [self.folio.firstStorage findObject:strName];
}

-(BOOL)recordHasNote:(int)recid
{
    return NO;
}

-(BOOL)recordHasBookmark:(int)recid
{
    return NO;
}

-(int)bookmarksCount
{
    return 0;
}

-(BOOL)canHaveBookmarks
{
    return NO;
}

-(BOOL)canHaveNotes
{
    return NO;
}


@end
