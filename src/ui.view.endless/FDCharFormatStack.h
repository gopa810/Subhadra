//
//  FDCharFormatStack.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/01/15.
//
//

#import <Foundation/Foundation.h>
@class FDTypeface;

@interface FDCharFormatStackItem : NSObject

@property NSString * tag;
@property id value;
// 1 - scalar value
// 2 - NSDictionary
@property int valueType;

@end


@interface FDCharFormatStack : NSObject

@property NSMutableArray * stack;

// basic methods
-(void)removeKey:(NSString *)tag;
-(id)valueForKey:(NSString *)tag;
-(void)setValue:(id)value forKey:(NSString *)tag;

// fonrmatting management
-(NSMutableDictionary *)getDictionary;
-(FDTypeface *)getTypeface;
-(NSString *)getTypefaceHash;
-(NSString *)getHash;

// char formatting
-(int)foregroundColor;
-(BOOL)subScript;
-(BOOL)superScript;
-(BOOL)italic;
-(BOOL)strikeOut;
-(BOOL)underline;
-(BOOL)hidden;
-(BOOL)bold;
-(int)backgroundColor;
-(NSString *)fontName;
-(float)textSize;

@end
