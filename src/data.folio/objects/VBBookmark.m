//
//  VBBookmark.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "VBBookmark.h"

@implementation VBBookmark

-(id)init
{
    self = [super init];
    if (self) {
        self.ID = -1;
        self.parentId = -1;
    }
    return self;
}

-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:[NSNumber numberWithInt:self.recordId] forKey:@"recordId"];
    [dict setValue:self.createDate forKey:@"createDate"];
    [dict setValue:[NSNumber numberWithInteger:self.ID] forKey:@"id"];
    [dict setValue:[NSNumber numberWithInteger:self.parentId] forKey:@"parentid"];
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    self.name = [obj valueForKey:@"name"];
    self.recordId = [[obj valueForKey:@"recordId"] intValue];
    self.createDate = [obj valueForKey:@"createDate"];
    NSNumber * n;
    
    n = [obj valueForKey:@"id"];
    if (n != nil)
        self.ID = [n integerValue];
    else
        self.ID = -1;
    n = [obj valueForKey:@"parentid"];
    if (n != nil)
        self.parentId = [n integerValue];
    else
        self.parentId = -1;
    
}

@end
