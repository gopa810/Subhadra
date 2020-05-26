//
//  VBViewRecord.m
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import "VBViewRecord.h"
#import "VBFolioStorage.h"

@implementation VBViewRecord

-(id)initWithStorage:(VBFolioStorage *)istore
{
    self = [super init];
    if (self) {
        self.storage = istore;
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        self.records = arr;
        self.loaded = NO;
//        [arr release];
    }
    return self;
}

-(void)createTables
{
    SQLiteDatabase * database = [self.storage getDatabase];
    [database execute:@"create table textviews(id integer, parent integer, title text)"];
    [database execute:@"create table textviews_texts(parent integer, textid integer)"];
}

-(void)load
{
    NSString * query = @"select parent,title from textviews where id = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPViewRecord_read_by_id" query:query];
    self.loaded = NO;
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        if ([command execute] == SQLITE_ROW) {
            self.parentID = [command intValue:0];
            self.title = [command stringValue:1];
            self.loaded = YES;
        }
    }
}

-(void)loadRecords
{
    NSString * query = @"select textid from textviews_texts where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPViewRecord_read_records_by_parent" query:query];
    self.loaded = NO;
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        [self.records removeAllObjects];
        while ([command execute] == SQLITE_ROW) {
            NSNumber * textID = [NSNumber numberWithInt:[command intValue:0]];
            [self.records addObject:textID];
        }
    }
}

-(BOOL)hasChild
{
    NSInteger results = 0;
    NSString * query = @"select count(*) from textviews where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBViewRecord_count_by_parent"
                                                    query:query];
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        if ([command execute] == SQLITE_ROW) {
            results = [command intValue:0];
        }
    }
    //[command release];
    return (results > 0);
}

-(void)write
{
    SQLiteCommand * stat = [self.storage commandForKey:@"VBViewRecord_write_view" query:@"insert into textviews(id,parent,title) values (?1,?2,?3)"];
    if (stat)
    {
        [stat bindInteger:(int)self.ID toVariable:1];
        [stat bindInteger:(int)self.parentID toVariable:2];
        [stat bindString:self.title toVariable:3];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting view record %ld,%ld,%@", (long)self.ID, (long)self.parentID, self.title);
        }
    }
    
    if ([self.records count] > 0)
    {
        stat = [self.storage commandForKey:@"VBViewRecord_write_detail" query:@"insert into textviews_texts(parent,textid) values (?1,?2)"];
        if (stat)
        {
            for(NSNumber * str in self.records)
            {
                [stat reset];
                [stat bindInteger:(int)self.ID toVariable:1];
                [stat bindInteger:(int)[str integerValue] toVariable:2];
                [stat execute];
            }
        }
    }
}

-(NSArray *)children
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select id,title from textviews where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPViewRecord_read_by_parent" query:query];
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            VBViewRecord * pl = [[VBViewRecord alloc] initWithStorage:self.storage];
            pl.ID = [command intValue:0];
            pl.parentID = self.ID;
            pl.title = [command stringValue:1];
            [results addObject:pl];
        }
    }
    //[command release];
    return results;

}

-(NSInteger)findViewAtPath:(NSArray *)path
{
    int cidx = 0;
    VBViewRecord * vr = [[VBViewRecord alloc] initWithStorage:self.storage];
    vr.ID = -1;
    BOOL found = NO;
    NSArray * c;
    
    while(cidx < path.count)
    {
        c = [vr children];
        for(VBViewRecord * vv in c)
        {
            if ([vv.title isEqualToString:path[cidx]])
            {
                cidx++;
                vr = vv;
                found = YES;
                break;
            }
        }
        
        if (!found)
        {
            return -1;
        }
    }
    
    return vr.ID;
}

@end
