//
//  VBSearchResultsCollection.m
//  VedabaseB
//
//  Created by Peter Kollath on 14/09/14.
//
//

#import "VBSearchResultsCollection.h"

@implementation VBSearchResultsCollection

-(id)init
{
    self = [super init];
    if (self) {
        [self clear];
    }
    return self;
}

-(BOOL)hasSpace
{
    return (self.count < SEARCH_RESULTS_COLLECTION_SIZE);
}

-(void)add:(int)recordId
{
    if ([self hasSpace]) {
        int * bytes = (int *)[self.recordsData bytes];
        bytes[self.count] = recordId;
        self.count ++;
    }
}

-(void)clear
{
    self.recordsData = [NSMutableData dataWithLength:SEARCH_RESULTS_COLLECTION_SIZE * sizeof(int)];
    self.count = 0;
    self.raws = nil;
}

-(BOOL)hasRawTexts
{
    return self.raws != nil;
}

-(FDRecordBase *)rawTextAtIndex:(int)index
{
    if (self.raws == nil || self.raws.count <= index)
        return nil;
    
    return [self.raws objectAtIndex:index];
}

-(int)recordIdAtIndex:(int)index
{
    if (index >= 0 && index < self->_count)
    {
        int * bytes = (int *)[self.recordsData bytes];
        return bytes[index];
    }
    return 0;
}




@end
