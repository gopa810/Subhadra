//
//  VBFolioObject.h
//  VedabaseB
//
//  Created by Peter Kollath on 4/14/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>



#define NSOffState 0
#define NSOnState  1
#define NSMixedState 2

@class VBFolioBase;

@interface VBFolioObject : NSObject

@property(nonatomic, retain) NSString * objectName;
@property(nonatomic, retain) NSString * objectType;
@property(nonatomic, retain) NSData * objectData;

@end

@interface VBFolioContentItem : NSObject
{
    BOOL selectedChanged;
    BOOL childValid;
    int  selected;
}

@property (strong) NSString * text;
@property (strong) NSString * simpleText;
@property (assign) int isLeaf;
@property (strong) NSString * subtext;
@property (assign, readwrite) int parentId;
@property (assign, readwrite) int recordId;
@property (assign) int nextSibling;
@property (assign) int nodeType;
@property (strong) NSString * nodeCode;

@property (assign, readwrite) int level;
@property (assign, readwrite) int selected;
@property (assign, readonly)  BOOL       selectedChanged;
@property (assign, readonly)  BOOL       childValid;
@property (weak,nonatomic) VBFolioContentItem * parent;
@property (nonatomic, strong) VBFolioContentItem * child;
@property (nonatomic, strong) VBFolioContentItem * next;
@property (nonatomic, strong) VBFolioBase * storage;

-(id)initWithStorage:(VBFolioBase *)store;
-(VBFolioContentItem *)findRecord:(NSUInteger)recId;
-(VBFolioContentItem *)findRecordPath:(NSUInteger)recId;
-(void)addChildItem:(VBFolioContentItem *)item;
-(BOOL)isRecordSelected:(NSUInteger)recId;
-(void)propagateStatusToChildren:(int)status;
-(void)propagateNewStatusToParent:(int)status;
-(NSString *)listOfSelectedItems;

@end
