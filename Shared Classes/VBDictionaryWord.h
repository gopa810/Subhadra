//
//  VBDictionaryWord.h
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import <Foundation/Foundation.h>
@class VBFolioStorage;

@interface VBDictionaryWord : NSObject

@property VBFolioStorage * storage;
@property int ID;
@property NSString * word;
@property NSString * simple;

-(id)initWithStorage:(VBFolioStorage *)store;
-(void)write;
-(void)createTables;

-(NSArray *)findExactWords:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results;
-(NSArray *)findWordsWithPrefix:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results;
-(NSArray *)findWordsContaining:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results;


@end
