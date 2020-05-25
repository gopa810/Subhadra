//
//  VBQueryTemplate.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/5/14.
//
//

#import <Foundation/Foundation.h>

@interface VBQueryTemplate : NSObject

@property (nonatomic, copy) NSString * templateName;
@property (nonatomic, copy) NSString * templateString;
@property (assign) BOOL custom;

-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;
-(NSString *)realQuery:(NSString *)userQuery;

@end
