//
//  VBFolioRecordMapping.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#import "VBFolioRecordMapping.h"


@implementation VBFolioRecordMappingItem

@end


@implementation VBFolioRecordMapping


-(void)readFile:(NSString *)fileName
{
    NSString * map = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
    NSArray * lines = [map componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    self.map = [NSMutableArray new];

    VBFolioRecordMappingItem * item = [VBFolioRecordMappingItem new];
    item.recordFrom = 0;
    item.recordTo = 0;
    item.correction = 0;
    [self.map addObject:item];
    
    
    for (NSString * line in lines)
    {
        NSArray * pp = [line componentsSeparatedByString:@" "];
        if (pp.count == 5 && [pp[0] isEqualToString:@"A"] && [pp[2] isEqualToString:@"B"] && [pp[4] isEqualToString:@"C"])
        {
            VBFolioRecordMappingItem * item = [VBFolioRecordMappingItem new];
            item.recordFrom = [(NSString *)[pp objectAtIndex:1] intValue];
            item.recordTo = 20000000;
            item.correction = [(NSString *)[pp objectAtIndex:3] intValue];
            [self.map addObject:item];
        }
    }
    
    for(int x = 0; x < [self.map count] - 1; x++)
    {
        VBFolioRecordMappingItem * T = [self.map objectAtIndex:x];
        VBFolioRecordMappingItem * U = [self.map objectAtIndex:x+1];
        
        T.recordTo = U.recordFrom - 1;
    }
}

-(int)correctionForRecord:(int)recId
{
    for (VBFolioRecordMappingItem * item in self.map)
    {
        if (item.recordFrom <= recId && item.recordTo >= recId)
            return recId + item.correction;
    }
    
    return recId;
}

@end
