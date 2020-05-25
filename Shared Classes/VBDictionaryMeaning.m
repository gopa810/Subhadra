//
//  VBDictionaryMeaning.m
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import "VBDictionaryMeaning.h"
#import "SQLiteWrapper.h"
#import "VBFolioStorage.h"

@implementation VBDictionaryMeaning

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
    [database execute:@"create table dict_means(wordid integer, dictid integer, recid integer PRIMARY KEY ASC ON CONFLICT REPLACE AUTOINCREMENT, meaning text)"];
    [database execute:@"create index idict_means on dict_means(dictid,wordid)"];

}

-(void)write
{
    SQLiteCommand * stat = [self.storage commandForKey:@"VBDictionaryMeaning_write_mean" query:@"insert into dict_means(wordid,dictid,meaning) values (?1,?2,?3)"];
    if (stat)
    {
        [stat bindInteger:self.wordID toVariable:1];
        [stat bindInteger:self.dictionaryID toVariable:2];
        [stat bindString:self.meaning toVariable:3];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting playlist record %d,%@", self.recordID, self.meaning);
        }
    }
}

-(NSArray *)findMeaningForWord:(int)wordid
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select wordid,dictid,meaning from dict_means where wordid = ?1 order by dictid,recid asc";
    SQLiteCommand * command = [self.storage commandForKey:@"VBDictMeaning_findExact"
                                                    query:query];
    [command bindInteger:wordid toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            VBDictionaryMeaning * pl = [[VBDictionaryMeaning alloc] initWithStorage:nil];
            pl.wordID = [command intValue:0];
            pl.dictionaryID = [command intValue:1];
            pl.meaning = [command stringValue:2];
            [results addObject:pl];
        }
    }
    return results;
}

@end
