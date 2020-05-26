//
//  VBViewRecord.h
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import <Foundation/Foundation.h>

@class VBFolioStorage;

@interface VBViewRecord : NSObject

@property (assign) VBFolioStorage * storage;
@property (assign) BOOL loaded;
@property (assign) NSInteger ID;
@property (assign) NSInteger parentID;
@property (retain) NSString * title;

// array of integers (record IDs) sorted
@property (retain) NSMutableArray * records;


-(id)initWithStorage:(VBFolioStorage *)pStore;
-(void)createTables;
-(void)write;
-(NSArray *)children;
-(BOOL)hasChild;
-(void)load;
-(void)loadRecords;
-(NSInteger)findViewAtPath:(NSArray *)path;

@end
