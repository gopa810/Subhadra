//
//  VBPlaylist.h
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import <Foundation/Foundation.h>

@class VBFolioStorage;

@interface VBPlaylist : NSObject

@property (assign) VBFolioStorage * storage;
@property (assign) NSInteger ID;
@property (assign) NSInteger parentID;
@property (retain) NSString * title;

// array of strings (names of objects)
@property (retain) NSMutableArray * objects;
@property (retain) NSMutableArray * chain;
@property (assign) NSInteger chainPos;


-(id)initWithStorage:(VBFolioStorage *)pStore;
-(id)initWithStorage:(VBFolioStorage *)pStore objectName:(NSString *)object;
-(void)createTables;
-(void)write;
-(NSArray *)children;
-(BOOL)hasChild;
-(void)load;
-(NSString *)nextObject;
-(void)back;
-(void)gotoEnd;

@end
