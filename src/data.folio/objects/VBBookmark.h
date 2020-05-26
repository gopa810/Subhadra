//
//  VBBookmark.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import <Foundation/Foundation.h>

@interface VBBookmark : NSObject

@property NSInteger ID;
@property NSInteger parentId;
@property (nonatomic, copy) NSString * name;
@property int recordId;
@property NSDate * createDate;
@property (weak) VBBookmark * originalItem;


-(NSDictionary *)dictionaryObject;
-(void)setDictionaryObject:(NSDictionary *)obj;

@end
