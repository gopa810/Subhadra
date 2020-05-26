//
//  SQLiteWrapper.m
//  VedabaseB
//
//  Created by Peter Kollath on 11/8/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "SQLiteWrapper.h"

@implementation SQLiteWrapper

@end


@implementation SQLiteDatabase

-(id)init
{
    self = [super init];
    if (self)
    {
        _lock = [[NSLock alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [self close];
    _lock = nil;
}


-(sqlite3 *)database
{
    return _database;
}

-(int)open:(NSString *)filePath
{
    [_lock lock];
    int result = sqlite3_open_v2([filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    [_lock unlock];
    return result;
}

-(void)close
{
    if (_database)
    {
        [_lock lock];
        sqlite3_close(_database);
        _database = NULL;
        [_lock unlock];
    }
}

-(int)execute:(NSString *)statement
{
    int r = 0;
    [_lock lock];
    r = sqlite3_exec(_database, [statement UTF8String], NULL, NULL, NULL);
    [_lock unlock];
    return r;
}

-(int)startTransaction
{
    return [self execute:@"BEGIN"];
}

-(int)endTransaction
{
    return [self execute:@"END"];
}

-(int)commit
{
    return [self execute:@"COMMIT;"];
}

-(SQLiteCommand *)createCommand:(NSString *)statement
{
    SQLiteCommand * command = nil;
    @try {
        sqlite3_stmt * stm;
        [_lock lock];
        if (sqlite3_prepare_v2(_database,
                               [statement UTF8String], -1, &stm, NULL) != SQLITE_OK)
        {
            sqlite3_finalize(stm);
            [_lock unlock];
            return nil;
        }
        [_lock unlock];
        
        command = [[SQLiteCommand alloc] initWithStatement:stm database:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot find object for statement: %@", statement);
    }
    @finally {
    }
    return command;
}

-(void)lock
{
    [_lock lock];
}

-(void)unlock
{
    [_lock unlock];
}

-(SQLiteBlob *)openBlob:(int64_t)rowId database:(NSString *)theDBName table:(NSString *)theTableName column:(NSString *)theColumnName
{
    sqlite3_blob * blob;

    [_lock lock];
    sqlite3_blob_open(_database, [theDBName UTF8String], [theTableName UTF8String], [theColumnName UTF8String], rowId, 0, &blob);
    [_lock unlock];
    
    if (blob != NULL)
    {
        SQLiteBlob * blobObject = [[SQLiteBlob alloc] initWithBlob:blob];
        blobObject.database = self;
        return blobObject;
    }
    
    return nil;
}

@end


@implementation SQLiteBlob

-(id)initWithBlob:(sqlite3_blob *)theBlob
{
    self = [super init];
    if (self)
    {
        _blob = theBlob;
    }
    return self;
}

-(NSData *)data
{
    return (NSData *)[self mutableData];
}

-(NSMutableData *)mutableData
{
    NSMutableData * data = nil;
    int size = [self length];
    data = [[NSMutableData alloc] initWithLength:size];
    [self.database lock];
    if (sqlite3_blob_read(_blob, [data mutableBytes], size, 0) != SQLITE_OK)
    {
        //[data release];
        data = nil;
    }
    [self.database unlock];
    return data;// autorelease];
}

-(int)length
{
    return sqlite3_blob_bytes(_blob);
}

/*
 * close connection to BLOB
 */
-(void)close
{
    [self.database lock];
    sqlite3_blob_close(_blob);
    [self.database unlock];
}

-(int)readBytes:(void *)aBuffer length:(int)aLength offset:(int)aOffset
{
    [self.database lock];
    int i = sqlite3_blob_read(_blob, aBuffer, aLength, aOffset);
    [self.database unlock];
    return i;
}

@end


@implementation SQLiteCommand


-(id)initWithStatement:(sqlite3_stmt *)theStat database:(SQLiteDatabase *)db
{
    self = [super init];
    if (self) {
        _statement = theStat;
        self.database = db;
    }
    
    return self;
}

-(void)dealloc
{
    [self close];
}


-(void)close
{
    if (_statement != NULL)
    {
        sqlite3_finalize(_statement);
        _statement = NULL;
    }
}

-(void)bindString:(NSString *)str toVariable:(int)theVar
{
    [self.database lock];
    sqlite3_bind_text(_statement, theVar, [str UTF8String], -1, NULL);
    [self.database unlock];
}

-(void)bindData:(NSData *)objectData toVariable:(int)theVar
{
    [self.database lock];
    sqlite3_bind_blob(_statement, theVar, [objectData bytes], (int)[objectData length], NULL);
    [self.database unlock];
}

-(void)bindInteger:(int)number toVariable:(int)theVar
{
    [self.database lock];
    sqlite3_bind_int(_statement, theVar, number);
    [self.database unlock];
}


-(int)execute
{
    [self.database lock];
    int r = sqlite3_step(_statement);
    [self.database unlock];
    return r;
}

-(void)reset
{
    [self.database lock];
    sqlite3_reset(_statement);
    [self.database unlock];
}

-(NSString *)stringValue:(int)index
{
    [self.database lock];
    const char * cString = (const char *)sqlite3_column_text(_statement, index);
    [self.database unlock];
    if (cString == NULL)
        return nil;
    return [NSString stringWithUTF8String:cString];
}

-(int)intValue:(int)index
{
    [self.database lock];
    int i = sqlite3_column_int(_statement, index);
    [self.database unlock];
    return i;
}

-(int64_t)int64Value:(int)index
{
    [self.database lock];
    int64_t i64 = sqlite3_column_int64(_statement, index);
    [self.database unlock];
    return i64;
}

@end



























