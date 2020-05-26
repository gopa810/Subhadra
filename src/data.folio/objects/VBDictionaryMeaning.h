//
//  VBDictionaryMeaning.h
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import <Foundation/Foundation.h>
@class VBFolioStorage;

@interface VBDictionaryMeaning : NSObject

@property VBFolioStorage * storage;
@property int dictionaryID;
@property int wordID;
@property int recordID;
@property NSString * meaning;

-(id)initWithStorage:(VBFolioStorage *)store;
-(void)write;
-(void)createTables;
-(NSArray *)findMeaningForWord:(int)wordid;

@end
