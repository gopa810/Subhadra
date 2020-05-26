//
//  VBFolioBase.m
//  VedabaseB
//
//  Created by Peter Kollath on 23/01/15.
//
//

#import "VBFolioBase.h"
#import "VBFolioStorageObjects.h"

@implementation VBFolioBase


-(NSString *)commandTextForKey:(NSString *)key
{
    if ([key caseInsensitiveCompare:@"find_content_item"] == NSOrderedSame) {
        return @"select c1.title,c1.record,c1.parent,c1.level,c1.simpletitle,c1.subtext,"
        "c1.node_children, c1.node_code, c1.node_type, c1.next_sibling "
        "from contents c1 where c1.record = ?1";
    } else if ([key caseInsensitiveCompare:@"read_content_items"] == NSOrderedSame) {
        return @"select c1.title,c1.record,c1.parent,c1.level,c1.simpletitle,c1.subtext,"
        "c1.node_children, c1.node_code, c1.node_type, c1.next_sibling "
        "from contents c1 where c1.parent = ?1 order by c1.record";
    } else if ([key caseInsensitiveCompare:@"find_content_range"] == NSOrderedSame) {
        return @"select c1.title,c1.record,c1.parent,c1.level,c1.simpletitle,c1.subtext,"
        "c1.node_children, c1.node_code, c1.node_type, c1.next_sibling "
        "from contents c1 where c1.record <= ?1 and c1.next_sibling >= ?1 and c1.node_type = ?2";
    } else if ([key caseInsensitiveCompare:@"find_link"] == NSOrderedSame) {
        return @"select recid from linkrefs where linkid = ?1";
    } else if ([key caseInsensitiveCompare:@"write_record"] == NSOrderedSame) {
        return @"insert into texts(recid,showid,plain,levelname,stylename) values (?1,?2,?3,?4,?5)";
    } else if ([key caseInsensitiveCompare:@"insert_object"] == NSOrderedSame) {
        return  @"insert into objects(objectName,objectType,objectData) values(?1,?2,?3)";
    } else if ([key caseInsensitiveCompare:@"insert_note"] == NSOrderedSame) {
        return @"insert into popup(plain,class,title) values(?1,?2,?3)";
    } else if ([key caseInsensitiveCompare:@"insert_content_item"] == NSOrderedSame) {
        return @"insert into contents(title,record,parent,level,simpletitle,subtext) values(?1,?2,?3,?4,?5,?6)";
    } else if ([key caseInsensitiveCompare:@"insert_word"] == NSOrderedSame) {
        return @"insert into words(word,uid,indexbase,data,idx) values (?1,?2,?3,?4,?5)";
    } else if ([key caseInsensitiveCompare:@"get_property"] == NSOrderedSame) {
        return @"select valuex from docinfo where name = ?1";
    } else if ([key caseInsensitiveCompare:@"content_level_items"] == NSOrderedSame) {
        return @"select record from contents where level = ?1 and simpletitle = ?2";
    } else if ([key caseInsensitiveCompare:@"enum_level_items"] == NSOrderedSame) {
        return @"select record from contents where level = ?1";
    } else if ([key caseInsensitiveCompare:@"insert_style"] == NSOrderedSame) {
        return @"insert into styles(name,id) values(?1,?2)";
    } else if ([key caseInsensitiveCompare:@"insert_style_detail"] == NSOrderedSame) {
        return @"insert into styles_detail(styleid,name,valuex) values (?1,?2,?3)";
    } else if ([key caseInsensitiveCompare:@"enum_styles"] == NSOrderedSame) {
        return @"select styles.name, styles_detail.name, styles_detail.valuex from styles, styles_detail where styles.id = styles_detail.styleid order by styles.id";
    } else if ([key caseInsensitiveCompare:@"findOriginalLevelIndex"] == NSOrderedSame) {
        return @"select id from levels where original=?1";
    } else if ([key caseInsensitiveCompare:@"insert_group"] == NSOrderedSame) {
        return @"insert into groups(groupname,recid) values(?1,?2)";
    } else if ([key caseInsensitiveCompare:@"insert_jumplink"] == NSOrderedSame) {
        return @"insert into jumplinks(title,recid) values(?1,?2)";
    }
    
    
    return nil;
}

-(SQLiteCommand *)commandForKey:(NSString *)key
{
    SQLiteCommand * cmd = (SQLiteCommand *)[self.commands objectForKey:key];
    if (cmd == nil) {
        cmd = [self.database createCommand:[self commandTextForKey:key]];
        if (cmd) {
            [self.commands setObject:cmd forKey:key];
        }
    } else {
        [cmd reset];
    }
    return cmd;
}

-(SQLiteCommand *)commandForKey:(NSString *)key query:(NSString *)text
{
    if (self.commands == nil) {
        self.commands = [[NSMutableDictionary alloc] init];
    }
    SQLiteCommand * cmd = (SQLiteCommand *)[self.commands objectForKey:key];
    if (cmd == nil) {
        cmd = [self.database createCommand:text];
        if (cmd) {
            [self.commands setObject:cmd forKey:key];
        }
    } else {
        [cmd reset];
    }
    return cmd;
}

-(SQLiteCommand *)createSqlCommand:(NSString *)query
{
    return [self.database createCommand:query];
}

-(SQLiteDatabase *)getDatabase
{
    return self.database;
}

#pragma mark -
#pragma mark General Store operations

-(BOOL)openStorage:(NSString *)filePath
{
    BOOL needCreateTables = NO;
    
    //sqlite part
    if (self.database == nil)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO)
            needCreateTables = YES;
        self.database = [[SQLiteDatabase alloc] init];
        int result = [self.database open:filePath];
        if (result != SQLITE_OK)
        {
            NSLog(@"creation of database %@ failed with error: %d", filePath, result);
            //[database release];
            self.database = nil;
            return NO;
        };
        
        if (needCreateTables == YES)
        {
            [self.database execute:@"create table contents(title text, record integer, parent integer, level integer, simpletitle text, subtext text)"];
            [self.database execute:@"create table words(word text, uid integer, indexbase integer, data blob, idx text)"];
            [self.database execute:@"create table docinfo(name text, valuex text, idx integer)"];
            [self.database execute:@"create table objects(objectName text, objectType text, objectData blob)"];
            [self.database execute:@"create table groups(groupname text, recid integer)"];
            [self.database execute:@"create table texts(plain text, recid integer, showid integer, levelname text, stylename text)"];
            [self.database execute:@"create table levels(level text, id integer, original text)"];
            [self.database execute:@"create table popup(title text, class text, plain text)"];
            [self.database execute:@"create table jumplinks(title text, recid integer)"];
            [self.database execute:@"create table styles(name text, id integer)"];
            [self.database execute:@"create table styles_detail(styleid integer, name text, valuex text)"];
            [self.database execute:@"create index iwords on words(word)"];
            [self.database execute:@"create index icontents on contents(parent)"];
            [self.database execute:@"create index itexts on texts(recid)"];
            [self.database execute:@"create index ipopup on popup(title)"];
            [self.database execute:@"create index igroup on groups(groupname)"];
            [self.database execute:@"create index iobject on objects(objectName)"];
            //[database execute:@"create index iwindex on words(uid)"];
            
            // version 2
            [self.database execute:@"create index icontents2 on contents(level)"];
            [self.database execute:@"create index itxstyle on texts(stylename)"];
            //[database execute:@"create index icontents4 on contents(simpletitle)"];
            //[self.database startTransaction];
            statCounter = 0;
        }
        
    }
    
    
    return YES;
    
}

-(void)startTransaction
{
    [self.database startTransaction];
}

-(void)endTransaction
{
    [self.database endTransaction];
}

-(void)commit
{
    
    //sqlite
    [self.database commit];
    
}

-(int)executeScript:(NSString *)script
{
    return [self.database execute:script];
}

-(void)close
{
    // common part
    [self.database commit];
    
    NSString * cmd;
    NSEnumerator * en = [self.commands keyEnumerator];
    while((cmd = [en nextObject]) != nil)
    {
        [[self commandForKey:cmd] close];
    }
    [self.commands removeAllObjects];
    
    self.database = nil;
    
}

+(NSDictionary *)infoDictionaryFromFile:(NSString *)filePath
{
    NSMutableDictionary * returnedValue = [[NSMutableDictionary alloc] init];
    
    [returnedValue setObject:filePath forKey:@"FileName"];
    
    sqlite3 * database = NULL;
    
    if (sqlite3_open_v2([filePath UTF8String], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        sqlite3_stmt * statement = NULL;
        if (sqlite3_prepare(database, "select name, valuex, idx from docinfo order by name, idx", -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString * name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString * valuex = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                int idx = sqlite3_column_int(statement, 2);
                
                //NSLog(@"property read name=%@ value=%@ idx=%d", name, valuex, idx);
                if (idx == 0) {
                    [returnedValue setObject:valuex forKey:name];
                } else {
                    NSMutableArray * array = [returnedValue objectForKey:name];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        [returnedValue setObject:array forKey:name];
                        //[array release];
                    }
                    [array addObject:valuex];
                }
            }
        }
        
        // finish statement
        sqlite3_finalize(statement);
        
        if (sqlite3_prepare(database, "select rowid from objects where objectName='FolioImage'", -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSData * data = [VBFolioBase readObject:@"FolioImage" fromDatabase:database];
                [returnedValue setObject:data forKey:@"Image"];
            }
        }
        
        // finish statement
        sqlite3_finalize(statement);
        
    }
    
    // close database
    sqlite3_close(database);
    
    if ([returnedValue count] == 0)
    {
        return nil;
    }
    return returnedValue;
}

+(NSInteger)resultsInPage
{
    return 25;
}

#pragma mark -
#pragma mark Insert methods

-(void)insertObject:(NSData *)objectData name:(NSString *)objectName type:(NSString *)objectType
{
    SQLiteCommand * stat = [self commandForKey:@"insert_object"];
    
    if (stat)
    {
        [stat bindString:objectName toVariable:1];
        [stat bindString:objectType toVariable:2];
        [stat bindData:objectData toVariable:3];
        
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting object");
        }
    }
}

-(void)writeNote:(NSDictionary *)dict
{
    SQLiteCommand * stat = [self commandForKey:@"insert_note"];
    
    if (stat)
    {
        NSString * fullParaText = [dict objectForKey:@"plain"];
        NSString * className = [dict objectForKey:@"className"];
        NSString * strTitle = [dict objectForKey:@"title"];
        //NSLog(@"WRITING NAMED POPUP WITH DATA:\n  TITLE: %@\n  CLASSNAME: %@\nEND.", strTitle, className);
        [stat bindString:(fullParaText ? fullParaText : @"") toVariable:1];
        [stat bindString:(strTitle ? strTitle : @"") toVariable:3];
        [stat bindString:(className ? className : @"") toVariable:2];
        
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting object");
        }
    }
}


-(void)insertFolioProperty:(NSString *)propName value:(NSString *)propValue
{
    NSString * str = [NSString stringWithFormat:@"insert into docinfo(name,valuex,idx) values('%@','%@',0)", propName, propValue];
    [self.database execute:str];
}

-(void)insertFolioProperty:(NSString *)propName value:(NSString *)propValue index:(NSInteger)idx
{
    NSString * str = [NSString stringWithFormat:@"insert into docinfo(name,valuex,idx) values('%@','%@',%ld)", propName, propValue, (long)idx];
    [self.database execute:str];
}

-(void)insertContentItem:(NSDictionary *)contItem
{
    SQLiteCommand * stat = [self commandForKey:@"insert_content_item"];
    if (stat)
    {
        [stat bindString:[contItem objectForKey:@"text"] toVariable:1];
        [stat bindInteger:[(NSNumber *)[contItem objectForKey:@"record"] intValue] toVariable:2];
        [stat bindInteger:[(NSNumber *)[contItem objectForKey:@"parent"] intValue] toVariable:3];
        [stat bindInteger:[(NSNumber *)[contItem objectForKey:@"level"] intValue] toVariable:4];
        [stat bindString:[contItem objectForKey:@"simpletitle"] toVariable:5];
        [stat bindString:[contItem objectForKey:@"subtext"] toVariable:6];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting content item for record %@", [contItem objectForKey:@"record"]);
        }
    }
    /*NSString * str = [NSString stringWithFormat:@"insert into contents(title,record,parent,level,simpletitle) values('%@',%@,%@,%@,'%@')", [contItem objectForKey:@"text"], [contItem objectForKey:@"record"], [contItem objectForKey:@"parent"], [contItem objectForKey:@"level"], [contItem objectForKey:@"simpletitle"]];
     [database execute:str];*/
}

-(void)insertStyleRef:(NSString *)styleName index:(int)idx
{
    SQLiteCommand * stat = [self commandForKey:@"insert_style"];
    if (stat)
    {
        [stat bindString:styleName toVariable:1];
        [stat bindInteger:idx toVariable:2];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting style record %@", styleName);
        }
    }
}

-(void)insertStyleDetail:(NSString *)detailName value:(NSString *)detailValue index:(int)idx
{
    SQLiteCommand * stat = [self commandForKey:@"insert_style_detail"];
    if (stat)
    {
        [stat bindInteger:idx toVariable:1];
        [stat bindString:detailName toVariable:2];
        [stat bindString:detailValue toVariable:3];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting style detail %d, %@", idx, detailName);
        }
    }
}

-(void)insertLevelDefinition:(NSDictionary *)levelDict
{
    NSString * str = [NSString stringWithFormat:@"insert into levels(level,id,original) values ('%@',%@,'%@')", [levelDict objectForKey:@"safe"], [levelDict objectForKey:@"index"], [levelDict objectForKey:@"original"]];
    //NSLog(@"execute: %@", str);
    [self.database execute:str];
}


-(NSString *)errorText:(int)error
{
    switch (error) {
        case SQLITE_ERROR:
            return @"ERROR";
        case SQLITE_MISUSE:
            return @"MISUSE";
        case SQLITE_DONE:
            return @"DONE";
        case SQLITE_OK:
            return @"OK";
        case SQLITE_BUSY:
            return @"BUSY";
        default:
            return [NSString stringWithFormat:@"%d", error];
    }
}

-(void)setCheckpoint
{
    if (statCounter > 50000)
    {
        [self.database commit];
        [self.database startTransaction];
        statCounter = 0;
    }
    statCounter++;
}

-(void)insertWordRef:(NSString *)inword wordID:(uint32_t)wid data:(NSData *)dataRefs index:(NSString *)idxTag recordIndexBase:(int)indexBase
{
    [self setCheckpoint];
    
    SQLiteCommand * cmd = [self commandForKey:@"insert_word"];
    
    if (cmd != nil)
    {
        //sqlite3_clear_bindings(insertWordIndexStatement);
        [cmd bindString:inword toVariable:1];
        [cmd bindInteger:wid toVariable:2];
        [cmd bindInteger:indexBase toVariable:3];
        [cmd bindData:dataRefs toVariable:4];
        [cmd bindString:idxTag toVariable:5];
        
        int res = SQLITE_DONE;
        res = [cmd execute];
        if (res != SQLITE_DONE)
        {
            NSLog(@"Insert statement (%@) not executed for %@,%d", [self errorText:res], inword, wid);
        }
        
    }
}

-(void)insertGroup:(NSString *)group record:(uint32_t)recID
{
    SQLiteCommand * stat = [self commandForKey:@"insert_group"];
    if (stat)
    {
        [stat bindString:group toVariable:1];
        [stat bindInteger:recID toVariable:2];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting group %@ for record %d", group, recID);
        }
    }
}

-(void)insertJumpLink:(NSString *)jump record:(uint32_t)recID
{
    SQLiteCommand * stat = [self commandForKey:@"insert_jumplink"];
    if (stat)
    {
        [stat bindString:jump toVariable:1];
        [stat bindInteger:recID toVariable:2];
        if ([stat execute] != SQLITE_DONE)
        {
            NSLog(@"error when inserting group %@ for record %d", jump, recID);
        }
    }
}

-(void)writeRecord:(uint32_t)recid plainText:(NSString *)plain levelName:(NSString *)levelName
         styleName:(NSString *)styleName
{
    SQLiteCommand * writeRecordSt = [self commandForKey:@"write_record"];
    
    if (writeRecordSt != nil)
    {
        [writeRecordSt bindInteger:recid toVariable:1];
        [writeRecordSt bindInteger:recid toVariable:2];
        [writeRecordSt bindString:plain toVariable:3];
        [writeRecordSt bindString:levelName toVariable:4];
        [writeRecordSt bindString:styleName toVariable:5];
        
        int res = SQLITE_DONE;
        res = [writeRecordSt execute];
        if (res != SQLITE_DONE)
        {
            NSLog(@"Insert statement (%@) not executed for %d,%@", [self errorText:res], recid, plain);
        }
    }
}


#pragma mark
#pragma mark Getter methods


-(NSString *)getObjectType:(NSString *)objName
{
    NSString * result = nil;
    NSString * query = @"select objectType from objects where objectName = ?1";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command)
    {
        [command bindString:objName toVariable:1];
        while ([command execute] == SQLITE_ROW)
        {
            result = [command stringValue:0];
        }
    }
    //[command release];
    
    return result;
    
}

-(void)initContentObject
{
    if (self.content != nil) return;
    
    //NSString * query = [NSString stringWithFormat:@"select title,record,parent,level,simpletitle from contents order by record"];
    //SQLiteCommand * command = [database createCommand:query];
    VBFolioContentItem * root = [[VBFolioContentItem alloc] initWithStorage:self];
    /*
     int parent;
     if (command)
     {
     while ([command execute] == SQLITE_ROW)
     {
     VBFolioContentItem * item = [[VBFolioContentItem alloc] initWithStorage:self];
     item.text = [command stringValue:0];
     item.recordId = [command intValue:1];
     parent = [command intValue:2];
     item.level = [command intValue:3];
     item.simpleText = [command stringValue:4];
     
     VBFolioContentItem * par = [root findRecord:parent];
     if (par == nil)
     {
     NSLog(@"Not found record %d in contents.", parent);
     [root addChildItem:item];
     item.parent = root;
     } else {
     [par addChildItem:item];
     item.parent = par;
     }
     }
     }
     [command release];
     */
    self.content = root;
    //[root release];
}

-(NSString *)getRecordPath:(int)record
{
    NSString * title = @"";
    VBFolioContentItem * item = [self findRecordPath:record];
    if (item != nil) {
        title = [self getDocumentPath:item];
    }
    if ([title length] < 1)
        title = @"Vedabase";
    return title;
}

-(VBFolioContentItem *)findRecordPath:(NSInteger)recID
{
    [self initContentObject];
    return [self.content findRecordPath:recID];
}

-(NSString *)getDocumentPath:(VBFolioContentItem *)item
{
    if (item == nil)
        return @"";
    
    NSMutableString * str1 = [[NSMutableString alloc] init];
    
    while(item.parent != nil)
    {
        if ([str1 length] == 0) {
            [str1 appendString:[item text]];
        } else {
            [str1 insertString:@" / " atIndex:0];
            [str1 insertString:[item text] atIndex:0];
        }
        item = item.parent;
    }
    return str1;//[str1 autorelease];
}

-(NSString *)findDocumentPath:(uint32_t)recID
{
    VBFolioContentItem * item = [self findRecordPath:recID];
    if (item == nil)
        return @"Vedabase";
    return [self getDocumentPath:item];
}

+(NSData *)readObject:(NSString *)objectName fromDatabase:(sqlite3 *)db
{
    NSMutableData * data = nil;
    sqlite3_stmt * statement = NULL;
    NSString * query = [NSString stringWithFormat:@"select rowid from objects where objectName = '%@'", objectName];
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            sqlite3_blob * blob = NULL;
            sqlite3_blob_open(db, "main", "objects", "objectData",
                              sqlite3_column_int64(statement, 0), 0, &blob);
            int size = sqlite3_blob_bytes(blob);
            data = [[NSMutableData alloc] initWithLength:size];
            if (sqlite3_blob_read(blob, [data mutableBytes], size, 0) != SQLITE_OK)
            {
                NSLog(@"=== sqlite blob read error ===");
            }
            sqlite3_blob_close(blob);
            
        }
    }
    sqlite3_finalize(statement);
    
    return data;//[data autorelease];
}

-(id)findObject:(NSString *)strName
{
    NSData * data = nil;
    NSString * query = @"select rowid from objects where objectName = ?1";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        [cmd bindString:strName toVariable:1];
        if ([cmd execute] == SQLITE_ROW)
        {
            SQLiteBlob * blob = [self.database openBlob:[cmd int64Value:0] database:@"main" table:@"objects" column:@"objectData"];
            data = [blob data];
            [blob close];
            
        }
    }
    //[cmd release];
    
    return data;
}

-(BOOL)objectExists:(NSString *)strName
{
    BOOL data = NO;
    NSString * query = @"select rowid from objects where objectName = ?1";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        [cmd bindString:strName toVariable:1];
        if ([cmd execute] == SQLITE_ROW)
        {
            data = YES;
        }
    }
    //[cmd release];
    
    return data;
}

-(uint32_t)findLinkReference:(uint32_t)linkRef
{
    SQLiteCommand * findLinkStatement = [self commandForKey:@"find_link"];
    
    if (findLinkStatement != NULL)
    {
        //sqlite3_clear_bindings(findLinkStatement);
        [findLinkStatement bindInteger:linkRef toVariable:1];
        
        int res = SQLITE_DONE;
        res = [findLinkStatement execute];
        if (res == SQLITE_ROW)
        {
            return [findLinkStatement intValue:0];
        }
        
    }
    
    
    return 0;
    
}


-(BOOL)jumpExists:(NSString *)jumpDest
{
    return [self findJumpDestination:jumpDest] != -1;
}

-(int32_t)findJumpDestination:(NSString *)targetJump
{
    int result = -1;
    NSString * query = @"select recid from jumplinks where title=?1";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        [command bindString:targetJump toVariable:1];
        if ([command execute] == SQLITE_ROW) {
            result = [command intValue:0];
        }
    }
    //[command release];
    
    return result;
}

-(void)findGroupRefs:(NSString *)groupStr resultArray:(NSMutableArray *)results
{
    NSMutableArray * currList = nil;
    NSString * query = @"select distinct recid from groups where group=?1 order by recid";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command)
    {
        [command bindString:groupStr toVariable:1];
        while ([command execute] == SQLITE_ROW)
        {
            if (currList == nil || [currList count] > 25)
            {
                NSMutableDictionary * md = [[NSMutableDictionary alloc] init];
                currList = [[NSMutableArray alloc] init];
                [md setObject:currList forKey:@"data"];
                //[currList release];
                [results addObject:md];
                //[md release];
            }
            
            if (currList != nil)
            {
                [currList addObject:[NSNumber numberWithUnsignedInt:[command intValue:0]]];
            }
        }
    }
    
    //[command release];
}


-(NSArray *)contentItemsForPage:(uint32_t)pageID
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"select a.title, a.record, a.parent, count(*) from contents a, contents b where a.parent = %d and b.parent = a.record group by a.title, a.record, a.parent order by a.record;", pageID];
    SQLiteCommand * command = [self.database createCommand:query];
    if (command)
    {
        while ([command execute] == SQLITE_ROW)
        {
            NSMutableDictionary * md = [[NSMutableDictionary alloc] init];
            [md setObject:[command stringValue:0] forKey:@"title"];
            [results addObject:md];
            //[md release];
            [md setObject:[NSNumber numberWithUnsignedInt:[command intValue:1]]
                   forKey:@"record"];
            [md setObject:[NSNumber numberWithUnsignedInt:[command intValue:2]]
                   forKey:@"parent"];
            [md setObject:[NSNumber numberWithUnsignedInt:[command intValue:1]]
                   forKey:@"itemid"];
            [md setObject:[NSNumber numberWithUnsignedInt:[command intValue:3]]
                   forKey:@"child"];
        }
        
    }
    
    //[command release];
    
    return results;
}

-(NSArray *)enumerateLevelRecords:(NSInteger)level
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    //    NSString * query = [NSString stringWithFormat:@"select record from contents where level = %d", level];
    SQLiteCommand * command = [self commandForKey:@"enum_level_items"];
    [command bindInteger:(int)level toVariable:1];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

-(NSArray *)enumerateLevelRecords:(NSInteger)level withSimpleTitle:(NSString *)simple
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    SQLiteCommand * command = [self commandForKey:@"content_level_items"];
    
    [command bindInteger:(int)level toVariable:1];
    [command bindString:simple toVariable:2];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

-(NSArray *)enumerateLevelRecords:(NSInteger)level likeSimpleTitle:(NSString *)simple
{
    NSString * wild = @"%";
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select record from contents where level = ?1 and simpletitle like ?2";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        [command bindInteger:(int)level toVariable:1];
        [command bindString:[NSString stringWithFormat:@"%@%@%@", wild, simple, wild] toVariable:2];
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

-(uint32_t)getSubRangeEndForRecord:(NSInteger)record
{
    uint32_t results = 0;
    NSString * query = [NSString stringWithFormat:@"select min(b.record) from contents a, contents b where a.record = %ld and b.level <= a.level and b.record > a.record", (long)record];
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        if ([command execute] == SQLITE_ROW) {
            int a = [command intValue:0];
            results = a - 1;
        } else {
            SQLiteCommand * commandCount = [self.database createCommand:@"select max(recid) from texts"];
            if (commandCount) {
                results = [commandCount intValue:0] - 1;
            }
            //[commandCount release];
        }
    }
    //[command release];
    return results;
}

-(NSArray *)enumerateContentItemsForParent:(uint32_t)recId
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"select record from contents where parent = %d order by record", recId];
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}


-(NSArray *)enumerateContentItemsWithSimpleText:(NSString *)simpleText
{
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select record from contents where simpletitle = ?1 order by record";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        [command bindString:simpleText toVariable:1];
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

-(NSArray *)enumerateContentItemsLikeSimpleText:(NSString *)simpleText
{
    if ([simpleText length] == 0)
        return [NSArray array];
    NSString * wildcart = @"%";
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query = @"select record from contents where simpletitle like ?1";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        [command bindString:[NSString stringWithFormat:@"%@%@%@", wildcart, simpleText, wildcart] toVariable:1];
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}

-(NSString *)simpleContentTextForRecord:(NSInteger)recordId
{
    NSString * result = nil;
    NSString * query = @"select simpletitle from contents where record = ?1";
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        [command bindInteger:(int)recordId toVariable:1];
        while ([command execute] == SQLITE_ROW) {
            result = [command stringValue:0];
        }
    }
    //[command release];
    return result;
}

-(NSArray *)enumerateGroupRecords:(NSString *)groupName
{
    BOOL needGroup = NO;
    NSMutableArray * results = [[NSMutableArray alloc] init];
    NSString * query;
    if ([groupName length] > 0) {
        query = @"select recid from groups where groupname = ?1 order by recid";
        needGroup = YES;
    } else {
        query = @"select distinct recid from groups order by recid";
    }
    SQLiteCommand * command = [self.database createCommand:query];
    if (command) {
        if (needGroup) {
            [command bindString:groupName toVariable:1];
        }
        while ([command execute] == SQLITE_ROW) {
            [results addObject:[NSNumber numberWithInt: [command intValue:0]]];
        }
    }
    //[command release];
    return results;
}


-(NSDictionary *)findPopupText:(NSString *)popupID
{
    NSLog(@"findPopupText:%@", popupID);
    NSDictionary * results = nil;
    NSString * query = @"select class, plain from popup where title = ?1";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        [cmd bindString:popupID toVariable:1];
        if ([cmd execute] == SQLITE_ROW)
        {
            results = [NSDictionary dictionaryWithObjectsAndKeys:[cmd stringValue:0], @"className", [cmd stringValue:1], @"plain", nil];
        }
    }
    
    //[cmd release];
    
    return results;
}

-(int)findTextCount
{
    int result = -1;
    SQLiteCommand * cmd = [self.database createCommand:@"select max(recid) from texts"];
    if (cmd)
    {
        if ([cmd execute] == SQLITE_ROW)
        {
            result = [cmd intValue:0];
        }
        
    }
    
    //[cmd release];
    
    return result;
}

-(NSDictionary *)readText:(uint32_t)recid forKey:(NSString *)strKey
{
    NSDictionary * result = nil;
    NSString * query = [NSString stringWithFormat:@"select %@, levelname from texts where recid = %d", strKey, recid];
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        if ([cmd execute] == SQLITE_ROW)
        {
            result = [NSDictionary dictionaryWithObjectsAndKeys:
                      [cmd stringValue:0], strKey,
                      [cmd stringValue:1], @"levelName",
                      [NSNumber numberWithUnsignedInt:recid], @"record",
                      nil];
        }
        
    }
    
    //[cmd release];
    
    return result;
}

-(int)findOriginalLevelIndex:(NSString *)levelName
{
    int result = -1;
    NSString * query = @"select id from levels where original=?1";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        [cmd bindString:levelName toVariable:1];
        if ([cmd execute] == SQLITE_ROW)
        {
            result = [cmd intValue:0];
        }
        
    }
    
    //[cmd release];
    return result;
}

// retrieves word's index blob
-(NSArray *)getWordIndexBlob:(NSString *)word forIndex:(NSString *)idxTag
{
    NSMutableArray * array = [NSMutableArray new];
    NSString * query = @"select rowid, indexbase from words where word = ?1 and idx=?2 order by indexbase";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        [cmd bindString:word toVariable:1];
        [cmd bindString:idxTag toVariable:2];
        while ([cmd execute] == SQLITE_ROW)
        {
            NSDictionary * item = [NSDictionary dictionaryWithObjectsAndKeys:@"main", @"DBNAME",
                                   @"words", @"TABLENAME", @"data", @"COLUMNNAME",
                                   [NSNumber numberWithInt:[cmd intValue:1]], @"INDEXBASE",
                                   [NSNumber numberWithInteger:[cmd int64Value:0]], @"ROWID",
                                   nil];
            [array addObject:item];
        }
    }
    
    //[cmd release];
    return array;
}

-(NSUInteger)textCount
{
    if (!textCountValid)
    {
        textCount = [self findTextCount];
        textCountValid = YES;
    }
    
    return textCount;
}

-(NSString *)stylesObject
{
    NSMutableString * object = [[NSMutableString alloc] init];
    
    SQLiteCommand * stat = [self commandForKey:@"enum_styles"];
    NSString * prevStyleName = nil;
    NSString * currStyleName = nil;
    NSString * currDetailName = nil;
    NSString * currDetailValue = nil;
    NSRange spaceRange;
    if (stat)
    {
        while ([stat execute] == SQLITE_ROW)
        {
            currStyleName = [stat stringValue:0];
            currDetailName = [stat stringValue:1];
            currDetailValue = [stat stringValue:2];
            
            if (prevStyleName == nil || [prevStyleName isEqualToString:currStyleName] == NO)
            {
                if (prevStyleName)
                {
                    [object appendString:@"}\n"];
                }
                [object appendFormat:@".%@ {\n", currStyleName];
                prevStyleName = currStyleName;
            }
            spaceRange = [currDetailValue rangeOfString:@" "];
            if (spaceRange.location == NSNotFound)
            {
                [object appendFormat:@"  %@:%@;\n", currDetailName, currDetailValue];
            }
            else
            {
                [object appendFormat:@"  %@:\"%@\";\n", currDetailName, currDetailValue];
            }
        }
        if (prevStyleName)
        {
            [object appendString:@"}\n"];
        }
        
        //NSLog(@"StylesObject created: %@", object);
    }
    
    return object;
}


// searches words like word
-(NSArray *)searchWords:(NSString *)word forIndex:(NSString *)idxTag
{
    word = [[word stringByReplacingOccurrencesOfString:@"?" withString:@"_"] stringByReplacingOccurrencesOfString:@"*" withString:@"%"];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSString * query = @"select word from words where word like ?1 and idx = ?2";
    SQLiteCommand * cmd = [self.database createCommand:query];
    if (cmd)
    {
        int max = 0;
        [cmd bindString:word toVariable:1];
        [cmd bindString:idxTag toVariable:2];
        while ([cmd execute] == SQLITE_ROW && max < 32)
        {
            max++;
            [arr addObject:[cmd stringValue:0]];
        }
        
    }
    
    //[cmd release];
    return arr;
}

-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    return nil;
}



@end
