//
//  VBDictionaryWord.m
//  Builder_iPad
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import "VBDictionaryWord.h"
#import "SQLiteWrapper.h"
#import "VBFolioStorage.h"

@implementation VBDictionaryWord

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
    [database execute:@"create table dict_words(id integer, word text, simple text)"];
}

-(void)write
{
    SQLiteCommand * stat = [self.storage commandForKey:@"VBDictionaryWord_write_word" query:@"insert into dict_words(id,word,simple) values (?1,?2,?3)"];
    if (stat)
    {
        [stat bindInteger:self.ID toVariable:1];
        [stat bindString:self.word toVariable:2];
        [stat bindString:self.simple toVariable:3];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting playlist record %d,%@", self.ID, self.word);
        }
    }
}

-(NSArray *)findExactWords:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results
{
    NSString * query = @"select id,word,simple from dict_words where simple = ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBDictWord_findExact"
                                                    query:query];
    int i = (int)[results count];
    [command bindString:str toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            NSNumber * num = [NSNumber numberWithInt:[command intValue:0]];
            if (found != nil && [found containsObject:num])
                 continue;
            [found addObject:num];
            VBDictionaryWord * pl = [[VBDictionaryWord alloc] initWithStorage:nil];
            pl.ID = [command intValue:0];
            pl.word = [command stringValue:1];
            pl.simple = [command stringValue:2];
            [results addObject:pl];
            i++;
            if (i > maxCount)
                break;
        }
    }
    return results;
}

-(NSArray *)findWordsWithPrefix:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results
{
    NSString * query = @"select id,word,simple from dict_words where simple like ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBDictWord_findPrefixed"
                                                    query:query];
    int i = (int)[results count];
    [command bindString:[NSString stringWithFormat:@"%@%%", str] toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            NSNumber * num = [NSNumber numberWithInt:[command intValue:0]];
            if (found != nil && [found containsObject:num])
                continue;
            [found addObject:num];
            VBDictionaryWord * pl = [[VBDictionaryWord alloc] initWithStorage:nil];
            pl.ID = [command intValue:0];
            pl.word = [command stringValue:1];
            pl.simple = [command stringValue:2];
            [results addObject:pl];
            i++;
            if (i > maxCount)
                break;
        }
    }
    return results;
}

-(NSArray *)findWordsContaining:(NSString *)str limit:(int)maxCount alreadyFound:(NSMutableSet *)found results:(NSMutableArray *)results
{
    NSString * query = @"select id,word,simple from dict_words where simple like ?1";
    SQLiteCommand * command = [self.storage commandForKey:@"VBDictWord_findPrefixed"
                                                    query:query];
    int i = (int)[results count];
    [command bindString:[NSString stringWithFormat:@"%%%@%%", str] toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            NSNumber * num = [NSNumber numberWithInt:[command intValue:0]];
            if (found != nil && [found containsObject:num])
                continue;
            [found addObject:num];
            VBDictionaryWord * pl = [[VBDictionaryWord alloc] initWithStorage:nil];
            pl.ID = [command intValue:0];
            pl.word = [command stringValue:1];
            pl.simple = [command stringValue:2];
            [results addObject:pl];
            i++;
            if (i > maxCount)
                break;
        }
    }
    return results;
}


@end
