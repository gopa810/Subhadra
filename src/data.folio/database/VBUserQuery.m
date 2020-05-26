//
//  VBUserQuery.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/5/14.
//
//

#import "VBUserQuery.h"

@implementation VBUserQuery


-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * __autoreleasing dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:self.templateName forKey:@"name"];
    [dict setValue:self.templateString forKey:@"string"];
    [dict setValue:self.userQuery forKey:@"userQuery"];
    [dict setValue:[NSNumber numberWithInt:self.userScope] forKey:@"userScope"];
    
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    self.templateName = [obj valueForKey:@"name"];
    self.templateString = [obj valueForKey:@"string"];
    self.userQuery = [obj valueForKey:@"userQuery"];
    NSNumber * n = [obj valueForKey:@"userScope"];
    self.userScope = (n != nil ? [n intValue] : 0);
}

-(NSString *)realQuery
{
    return [self realQuery:self.userQuery];
}

@end
