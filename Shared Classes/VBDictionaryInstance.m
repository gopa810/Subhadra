//
//  VBDictionaryInstance.m
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import "VBDictionaryInstance.h"
#import "SQLiteWrapper.h"
#import "VBFolioStorage.h"

@implementation VBDictionaryInstance

-(id)initWithStorage:(VBFolioStorage *)store
{
    self = [super init];
    if (self)
    {
        self.storage = store;
    }
    return self;
}

-(void)createTables
{
    SQLiteDatabase * database = [self.storage getDatabase];
    [database execute:@"create table dictionary(id integer, name text)"];
}

-(void)write
{
    SQLiteCommand * stat = [self.storage commandForKey:@"VBDictionary_write_dict" query:@"insert into dictionary(id,name) values (?1,?2)"];
    if (stat)
    {
        [stat bindInteger:self.ID toVariable:1];
        [stat bindString:self.name toVariable:2];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting playlist record %d,%@", self.ID, self.name);
        }
    }
}

-(NSArray *)dictionaries
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select id,name from dictionary where 1=1 order by id";
    SQLiteCommand * command = [self.storage commandForKey:@"VBDictionaryInst_enum_all"
                                                    query:query];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            VBDictionaryInstance * pl = [[VBDictionaryInstance alloc] initWithStorage:nil];
            pl.ID = [command intValue:0];
            pl.name = [command stringValue:1];
            [results addObject:pl];
        }
    }
    return results;
}

@end
