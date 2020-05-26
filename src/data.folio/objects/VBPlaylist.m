//
//  VBPlaylist.m
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import "VBPlaylist.h"
#import "VBFolioStorage.h"

@implementation VBPlaylist

-(id)initWithStorage:(VBFolioStorage *)pStore
{
    self = [super init];
    if (self) {
        self.storage = pStore;
        self.ID = 0;
        self.parentID = 0;
        self.title = @"";
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        self.objects = arr;
        //[arr release];
    }
    return self;
}

-(id)initWithStorage:(VBFolioStorage *)pStore objectName:(NSString *)object
{
    self = [super init];
    if (self) {
        self.storage = pStore;
        self.ID = 0;
        self.parentID = 0;
        self.title = @"";
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        self.objects = arr;
        self.chainPos = 0;
        arr = [[NSMutableArray alloc] init];
        self.chain = arr;
        [arr addObject:[NSDictionary dictionaryWithObject:object forKey:@"object"]];
        
        //[arr release];
    }
    return self;
}

-(void)createTables
{
    SQLiteDatabase * database = [self.storage getDatabase];
    [database execute:@"create table playlists(id integer, parent integer, title text)"];
    [database execute:@"create table playlists_detail(parent integer, ordernum integer, objectName text)"];
}

-(void)write
{
    SQLiteCommand * stat = [self.storage commandForKey:@"VBPlaylist_write_playlist" query:@"insert into playlists(id,parent,title) values (?1,?2,?3)"];
    if (stat)
    {
        [stat bindInteger:(int)self.ID toVariable:1];
        [stat bindInteger:(int)self.parentID toVariable:2];
        [stat bindString:self.title toVariable:3];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting playlist record %ld,%ld,%@", (long)self.ID, (long)self.parentID, self.title);
        }
    }
    
    if ([self.objects count] > 0)
    {
        stat = [self.storage commandForKey:@"VBPlaylists_write_object" query:@"insert into playlists_detail(parent,ordernum,objectName) values (?1,?2,?3)"];
        if (stat)
        {
            NSInteger order = 1;
            for(NSString * str in self.objects)
            {
                [stat reset];
                [stat bindInteger:(int)self.ID toVariable:1];
                [stat bindInteger:(int)order toVariable:2];
                [stat bindString:str toVariable:3];
                [stat execute];
                order++;
            }
        }
    }
}

-(void)load
{
    //NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select id,parent,title from playlists where id = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPlaylists_read_by_id"
                                                    query:query];
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            self.parentID = [command intValue:1];
            self.title = [command stringValue:2];
            break;
        }
    }
}

-(NSArray *)children
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select id,title from playlists where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPlaylists_read_by_parent"
                                                    query:query];
    [command bindInteger:(int)self.ID toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            VBPlaylist * pl = [[VBPlaylist alloc] initWithStorage:self.storage];
            pl.ID = [command intValue:0];
            pl.parentID = self.ID;
            pl.title = [command stringValue:1];
            [results addObject:pl];
        }
    }
    //[command release];
    return results;
}

-(BOOL)hasChild
{
    NSInteger results = 0;
    NSString * query = @"select count(*) from playlists where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPlaylists_count_by_parent"
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

-(void)back
{
    self.chainPos --;
    if (self.chainPos < 0)
        self.chainPos = 0;
}

-(void)gotoEnd
{
    self.chainPos = [self.chain count];
}

-(NSString *)nextObject
{
    if (self.chain == nil)
    {
        self.chain = [[NSMutableArray alloc] init];
    }
    
    if ([self.chain count] == 0)
    {
        [self.chain addObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.ID] forKey:@"playlist"]];
        self.chainPos = 0;
    }
    
    while ([self.chain count] > 0 && self.chainPos < [self.chain count])
    {
        NSDictionary * d = [self.chain objectAtIndex:self.chainPos];
        if ([d objectForKey:@"playlist"] != nil)
        {
            NSInteger pid = [(NSNumber *)[d objectForKey:@"playlist"] integerValue];
            NSArray * objs = [self loadObjectsForPlaylist:pid];
            NSArray * plays = [self loadPlaylistsForPlaylist:pid];
            NSMutableArray * ins = [[NSMutableArray alloc] init];
            for(NSString * N in objs)
            {
                [ins addObject:[NSDictionary dictionaryWithObject:N forKey:@"object"]];
            }
            for(NSNumber * N in plays)
            {
                [ins addObject:[NSDictionary dictionaryWithObject:N forKey:@"playlist"]];
            }
            
            [self.chain removeObjectAtIndex:self.chainPos];
            [self.chain insertObjects:ins atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.chainPos, ins.count)]];
        }
        else if ([d objectForKey:@"object"])
        {
            self.chainPos ++;
            return [d objectForKey:@"object"];
        }
    }
    
    return nil;
}

-(NSArray *)loadObjectsForPlaylist:(NSInteger)pid
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select objectName from playlists_detail where parent = ?1 order by ordernum";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPlaylists_readobjs_by_parent"
                                                    query:query];
    [command bindInteger:(int)pid toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[command stringValue:0]];
        }
    }
    //[command release];
    return results;
}

-(NSArray *)loadPlaylistsForPlaylist:(NSInteger)pid
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select id from playlists where parent = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBPlaylists_readids_by_parent"
                                                    query:query];
    [command bindInteger:(int)pid toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInteger:[command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

@end
