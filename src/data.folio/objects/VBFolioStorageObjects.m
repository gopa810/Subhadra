//
//  VBFolioObject.m
//  VedabaseB
//
//  Created by Peter Kollath on 4/14/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "VBFolioStorageObjects.h"
#import "VBFolioBase.h"

@implementation VBFolioObject

@synthesize objectData;
@synthesize objectName;
@synthesize objectType;

@end


@implementation VBFolioContentItem

@synthesize level, recordId, text, simpleText;
@synthesize parent, next;
@synthesize selectedChanged, storage, childValid;

-(id)initWithStorage:(VBFolioBase *)store
{
    self = [super init];
    if (self) {
        self.storage = store;
        self.child = nil;
        childValid = NO;
        selectedChanged = NO;
        self.selected = 0;
    }
    return self;
}

-(BOOL)isRecordSelected:(NSUInteger)recId
{
    VBFolioContentItem * p = self;
    VBFolioContentItem * last = nil;

    while (p != nil)
    {
        if ([p recordId] == recId) {
            return p.selected;
        } else if ([p recordId] > recId) {
            return NO;
        } else if (([p next] && [[p next] recordId] > recId) || ([p next] == nil)) {
            
            if ([p childValid] == NO) {
                return p.selected;
            } else if ([p selected] != 2 && p.recordId != 0)
                return p.selected; 
            last = p;
            p = [p child];
        }
        else {
            last = p;
            p = [p next];
        }
    }
    
    return NO;
}

-(VBFolioContentItem *)findRecord:(NSUInteger)recId
{
    VBFolioContentItem * p = self;
    while (p != nil)
    {
        if ([p recordId] == recId) {
            return p;
        } else if ([p recordId] > recId) {
            return nil;
        } else if (([p next] && [[p next] recordId] > recId) || ([p next] == nil)) {
            p = [p child];
        }
        else {
            p = [p next];
        }
    }
    
    return nil;
}

-(VBFolioContentItem *)findRecordPath:(NSUInteger)recId
{
    VBFolioContentItem * p = self;
    VBFolioContentItem * last = nil;
    while (p != nil)
    {
        if ([p recordId] == recId) {
            return p;
        } else if ([p recordId] > recId) {
            return last;
        } else if (([p next] && [[p next] recordId] > recId) || ([p next] == nil)) {
            if ([p child] == nil) {
                return p;
            }
            last = p;
            p = [p child];
        }
        else {
            last = p;
            p = [p next];
        }
    }
    
    return nil;
}

-(void)addChildItem:(VBFolioContentItem *)item
{
    if (self.child == nil) {
        self.child = item;
        item.parent = self;
        return;
    }

    VBFolioContentItem * p = self.child;
    while (p != nil)
    {
        if (p.next == nil) {
            p.next = item;
            item.parent = self;
            break;
        }
        p = p.next;
    }
}

-(int)selected
{
    return selected;
}

-(void)setSelected:(int)aSelected
{
    selected = aSelected;
    selectedChanged = YES;
}

-(VBFolioContentItem *)child
{
    if (childValid)
        return _child;
    
    childValid = YES;
    
    SQLiteCommand * command = [storage commandForKey:@"read_content_items"];
    if (command) {
        [command bindInteger:(int)recordId toVariable:1];
        while ([command execute] == SQLITE_ROW) {
            VBFolioContentItem * item = [[VBFolioContentItem alloc] initWithStorage:storage];
            item.text = [command stringValue:0];
            item.recordId = [command intValue:1];
            item.parentId = [command intValue:2];
            item.level = [command intValue:3];
            item.simpleText = [command stringValue:4];
            item.subtext = [command stringValue:5];
            item.isLeaf = [command intValue:6];
            item->selected = self->selected;

            [self addChildItem:item];
        }
    }
    
    return _child;
}


-(void)propagateStatusToChildren:(int)status
{
    if (self.childValid)
    {
        VBFolioContentItem * item = self.child;
        while (item)
        {
            [item setSelected:status];
            [item propagateStatusToChildren:status];
            item = [item next];
        }
    }
}

-(void)propagateNewStatusToParent:(int)status
{
    if (self.parent) {
        VBFolioContentItem * brother = self.parent.child;
        while (brother)
        {
            if (brother.selected != status)
            {
                status = NSMixedState;
                break;
            }
            brother = brother.next;
        }
        
        [self.parent setSelected:status];
        [self.parent propagateNewStatusToParent:status];
    }
}

-(NSString *)listOfSelectedItems
{
    NSMutableString * str = [[NSMutableString alloc] initWithCapacity:10];
    
    VBFolioContentItem * E = self.child;
    while(E != nil) {
        if (E.selected != 0) {
            if ([str length] > 0) {
                [str appendString:@", "];
            }
            [str appendFormat:@"%@", E.text];
        }
        E = E.next;
    }
    return str;
}

@end