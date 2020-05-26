//
//  VBQueryTemplate.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/5/14.
//
//

#import "VBQueryTemplate.h"

@implementation VBQueryTemplate

-(id)init
{
    self = [super init];
    if (self)
    {
        self.custom = NO;
    }
    return self;
}

-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:self.templateName forKey:@"name"];
    [dict setValue:self.templateString forKey:@"string"];
    
    return dict;//[dict autorelease];
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    self.templateName = [obj valueForKey:@"name"];
    self.templateString = [obj valueForKey:@"string"];
}

-(NSString *)realQuery:(NSString *)userQuery
{
    if (self.templateString == nil)
        return userQuery;
    return [self.templateString stringByReplacingOccurrencesOfString:@"$1" withString:userQuery];
}

@end
