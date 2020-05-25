//
//  VBUserQuery.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/5/14.
//
//

#import <Foundation/Foundation.h>
#import "VBQueryTemplate.h"

@interface VBUserQuery : VBQueryTemplate

@property (nonatomic, copy) NSString * userQuery;
@property (assign) int userScope;

-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;
-(NSString *)realQuery;

@end
