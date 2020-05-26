//
//  VBDictionaryInstance.h
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import <Foundation/Foundation.h>
@class VBFolioStorage;

@interface VBDictionaryInstance : NSObject

@property VBFolioStorage * storage;
@property int ID;
@property NSString * name;


-(id)initWithStorage:(VBFolioStorage *)store;
-(void)write;
-(void)createTables;
-(NSArray *)dictionaries;

@end
