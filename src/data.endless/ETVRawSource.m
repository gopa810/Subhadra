//
//  ETVRawSource.m
//  VedabaseB
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import "ETVRawSource.h"
#import "FlatParagraph.h"
#import "FolioTextRecord.h"
@implementation ETVRawSource

-(id)init
{
    self = [super init];
    if (self)
    {
        self.records = [[NSMutableArray alloc] init];
        self.objects = [NSMutableDictionary new];
    }
    return self;
}

-(void)addFlatText:(NSString *)str
{
    [self addFlatText:str withLevel:nil];
}

-(void)addFlatText:(NSString *)str withLevel:(NSString *)strLevel
{
    FolioTextRecord * ftr = [[FolioTextRecord alloc] init];
    
    ftr.levelName = strLevel;
    ftr.plainText = str;
    ftr.recordId = (unsigned int)[self.records count] + 1;
    
    FlatParagraph * fp = [[FlatParagraph alloc] initWithFolio:(VBFolioStorage *)self];
    [self.records addObject:[fp convertToRaw:ftr]];
}

-(FDRecordBase *)getRawRecord:(unsigned int)recid
{
    if (recid < [self.records count])
        return [self.records objectAtIndex:recid];
    return nil;
}

-(int)getRecordCount
{
    return (int)[self.records count];
}

-(void)clear
{
    [self.records removeAllObjects];
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    return nil;
}

-(NSString *)getRecordPath:(int)record
{
    return @"";
}

-(id)findObject:(NSString *)strName
{
    return [self.objects valueForKey:strName];
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

-(NSInteger)minimumRecord
{
    return 0;
}

-(NSInteger)maximumRecord
{
    return (NSInteger)self.records.count - 1;
}

@end
