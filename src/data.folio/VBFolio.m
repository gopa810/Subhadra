//
//  VBFolio.m
//  VedabaseA
//
//  Created by Peter Kollath on 12/26/10.
//  Copyright 2010 GPSL. All rights reserved.
//

#import "VBFolio.h"
//#import "VBSearchTask.h"
#import "VBFolioStorage.h"
#import "FlatFileUtils.h"
#import "VBMainServant.h"
#import "FolioFileActive.h"
#import "VBRecordNotes.h"
#import "VBBookmark.h"
#import "VBUserQuery.h"
#import "VBQueryTemplate.h"
#import "VBFolioRecordMapping.h"

@implementation VBFolio

@synthesize info;
@synthesize title;
@synthesize loadedRangeStart, loadedRangeEnd, loadedRangeHit;


#pragma mark -
#pragma mark Object Lifecycle

-(id)initWithFileName:(NSString *)fileName
{
	if ((self = [super init]) != nil)
	{
        self.info = [VBFolio infoDictionaryFromFile:fileName];
		if (self.info == nil)
			return nil;
        
        if ([self.info valueForKey:@"CollectionName"] == nil)
            [self.info setValue:@"Untitled" forKey:@"CollectionName"];
		self.title = [self.info objectForKey:@"CollectionName"];

		// connects to CoreData file

        VBFolioStorage * storage = [[VBFolioStorage alloc] init];
        [storage openStorage:fileName];
        storage.fileName = [fileName lastPathComponent];
        //[storage.inclusionPath addObjectsFromArray:store.inclusionPath];
        
        self.firstStorage = storage;

        //NSString * defSize = [[self info] objectForKey:@"DefaultFontSize"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.bodyFontSize = [defaults integerForKey:@"bodySize"];
        NSLog(@"BODY FONT SIZE = %lu (load)", (unsigned long)self.bodyFontSize);

        if (self.bodyFontSize == 0)
            self.bodyFontSize = 18;
        NSString * lbodyFont = [defaults stringForKey:@"bodyFont"];
        if (lbodyFont == nil) {
            lbodyFont = [[self info] objectForKey:@"DefaultFontFamily"];
            if (lbodyFont == nil) {
                lbodyFont = @"Times";
            }
        }
        self.bodyFontFamily = lbodyFont;
        
        self.bodyLineSpacing = [defaults integerForKey:@"bodyLineHeight"];
        if (self.bodyLineSpacing == 0) {
            self.bodyLineSpacing = 120;
        }
        
        self.bodyPaddingLeft = 0;
        self.bodyPaddingRight = 0;
        
        self.bodyBackgroundImage = @"vbase://stylist_images/background_yellow";
        
        self.stylesCache = nil;
		storageTextCount = 0xffffffff;
        loadedRangeStart = 0;
        loadedRangeEnd = 0;
        loadedRangeHit = 0;
        
        queryHistory = [[NSMutableArray alloc] init];
        
	}
	
	return self;
}

+(NSString *)URL_STYLE_SHEETS
{
    return @"vbase://resources/styles.css";
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
                NSData * data = [VBFolioStorage readObject:@"FolioImage" fromDatabase:database];
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

-(void)dealloc
{
    self.stylesCache = nil;
}


#pragma mark -
#pragma mark Getters


-(void)close
{
    [self.firstStorage close];
    self.firstStorage = nil;
}

-(BOOL)checkFolioTextsOpen
{	
	return YES;
}

-(NSString *)text:(NSUInteger)gTextID
{
    int textID = (int)gTextID;
    VBFolioStorage * storage = [self firstStorage];
    
    NSDictionary * plainDict = [storage readText:(int)textID forKey:@"plain"];
    if (plainDict == nil)
        return nil;
    FlatFileString * str = [[FlatFileString alloc] init];
    str.validator = storage;
    [str setString:[plainDict valueForKey:@"plain"]];
    HtmlString * html = [str htmlStringWithStyles:nil forRecord:plainDict];
    if (str.dataObjectName) {
        if (![storage objectExists:str.dataObjectName]) {
            //[str release];
            return @"";
        }
    }
    //[str release];
    NSString * buff = [html string];
    return buff;
}

-(void)textsFromStart:(NSUInteger)startTextID toEnd:(NSUInteger)endTextID target:(NSMutableString *)target
{
    NSUInteger localStartID  = (int)startTextID;
    NSUInteger localEndID    = (int)endTextID;
    VBFolioStorage * storage = [self firstStorage];
    FlatFileString * str     = [[FlatFileString alloc] init];
    HtmlString * html        = [[HtmlString alloc] init];
    NSDictionary * plainDict = nil;

    for (NSUInteger textID = localStartID; textID <= localEndID; textID++)
    {
        plainDict = [storage readText:(int)textID forKey:@"plain"];
        if (plainDict == nil)
            continue;
        [str reset];
        [str setString:[plainDict valueForKey:@"plain"]];
        [str htmlStringWithStyles:nil forRecord:plainDict htmlString:html];

        if (str.dataObjectName) {
            if ([storage objectExists:str.dataObjectName]) {
                [target appendString:[html string]];
            }
        } else {
            [target appendString:[html string]];
        }
    }
    //[html release];
    //[str release];
}

-(NSString *)envelopeHtmlInBody:(NSString *)htmlContent
{
    NSMutableString * html = [[NSMutableString alloc] init];

    [html appendFormat:@"<html><head><title>Rec</title>"];
    [html appendFormat:@"<link href=\"%@\" type=text/css rel=stylesheet>\n",
     [VBFolio URL_STYLE_SHEETS]];
    [html appendFormat:@"<style>\n<!--\n"];
    //[strHtml appendFormat:@"body { background: 'vbase://resources/background_yellow';}"];
    [html appendFormat:@"\n-->\n</style>\n</head>\n<body style='%@' background=\"%@\">", [self bodyStyleString], self.bodyBackgroundImage];
    
    [html appendString:htmlContent];
    [html appendString:@"</body></html>"];
    
#if (TARGET_IPHONE_SIMULATOR)
    [html writeToFile:@"/Work/SimulatorPopupText.html"
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:NULL];
#endif

    return html;
}

-(NSString *)text:(NSUInteger)gTextID forPopupNumber:(NSInteger)pwCount
{
    VBFolioStorage * storage = [self firstStorage];

    //return [storage readText:textID forKey:@"html"];
    NSDictionary * plainDict = [storage readText:(int)gTextID forKey:@"plain"];
    if (plainDict == nil)
        return nil;
    
    FlatFileString * str = [[FlatFileString alloc] init];
    [str setString:[plainDict valueForKey:@"plain"]];
    [str setCatchPwCounter:(int)pwCount];
    plainDict = [plainDict dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"record", @"plain", nil]];
    HtmlString * html = [str htmlStringWithStyles:nil forRecord:plainDict];


    return [self envelopeHtmlInBody:[html string]];
}

//
// get plain text data
//

-(NSString *)plainText:(NSUInteger)gTextID
{
    VBFolioStorage * storage = [self firstStorage];

    return [[storage readText:(int)gTextID forKey:@"plain"] valueForKey:@"plain"];
}

#define kHtmlFileOverhead 2048
#define kHtmlFileNamedLink  32

+(NSString *)stringToSafe:(NSString *)str
{
	NSMutableData * s = [[NSMutableData alloc] initWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
	
	unsigned char * bt = [s mutableBytes];
	NSInteger len = [s length];
	
	for(NSInteger i = 0; i < len; i++)
	{
		if (!(isdigit(bt[i]) || isalnum(bt[i])))
		{
			bt[i] = '-';
		}
	}
	
	NSString * rets = [[NSString alloc] initWithData:s encoding:NSASCIIStringEncoding];
	//[s release];
	return rets;
}

-(NSString *)bodyStyleString
{
    return [NSString stringWithFormat:@"font-family:%@;font-size:%lupt;line-height:%lu%%;padding-left:%lupt;padding-right:%lupt;text-align:justify;",
            self.bodyFontFamily, (unsigned long)self.bodyFontSize, (unsigned long)self.bodyLineSpacing, (unsigned long)self.bodyPaddingLeft, (unsigned long)self.bodyPaddingRight];
}

//
// get HTML data for range of records around given record
//
-(NSData *)dataForRecordRange:(NSUInteger)gTextID
{
    int textID = (int)gTextID;
    VBFolioStorage * storage = [self firstStorage];

	int R1 = textID;
	int R2 = textID;
	
	R1 = (R1 < 20) ? 0 : (R1 - 20);
	R2 += 50;
	//NSLog(@"TextCount = %d\n", [self textCount]);
	if (R2 > [storage textCount])
		R2 = (int)[storage textCount];
	if (R2 < R1)
		R2 = R1;
	
	//NSLog(@"body style = %@\n", bodyStyle);
	loadedRangeStart = R1;
	loadedRangeEnd = R2 - 1;
	loadedRangeHit = gTextID;
	int recCount = R2 - R1 + 1;

	
	NSMutableData * result = [[NSMutableData alloc] initWithCapacity:10000];
	if (result == nil)
	{
//		[poss release];
		return [NSData data];
	}
	
	NSMutableString * strHtmlHead = [[NSMutableString alloc] init];
    
    [strHtmlHead appendFormat:@"<html><head><title>Rec</title>"];
	[strHtmlHead appendFormat:@"<link href=\"%@\" type=text/css rel=stylesheet>\n", 
     [VBFolio URL_STYLE_SHEETS]];
	[strHtmlHead appendFormat:@"<script type=\"text/javascript\" src=\"vbase://resources/maintext.js\">\n"];
/*    [strHtmlHead appendString:@"function increaseText() \n"];
    [strHtmlHead appendString:@"{\n"];
    [strHtmlHead appendString:@"  if (document.body.style.fontSize == \"\") \n"];
    [strHtmlHead appendString:@"  {\n"];
    [strHtmlHead appendString:@"     document.body.style.fontSize = \"14pt\";\n"];
    [strHtmlHead appendString:@"  }\n"];
    [strHtmlHead appendString:@"  document.body.style.fontSize = parseFloat(document.body.style.fontSize) + 1.0 + \"pt\";\n"];
    [strHtmlHead appendString:@"  return document.body.style.fontSize;\n"];
    [strHtmlHead appendString:@"}\n"];
    [strHtmlHead appendString:@"function decreaseText() \n"];
    [strHtmlHead appendString:@"{\n"];
    [strHtmlHead appendString:@"  if (document.body.style.fontSize == \"\") \n"];
    [strHtmlHead appendString:@"  {\n"];
    [strHtmlHead appendString:@"     document.body.style.fontSize = \"14pt\";\n"];
    [strHtmlHead appendString:@"  }\n"];
    [strHtmlHead appendString:@"  document.body.style.fontSize = parseFloat(document.body.style.fontSize) - 1.0 + \"pt\";\n"];
    [strHtmlHead appendString:@"  return document.body.style.fontSize;\n"];
    [strHtmlHead appendString:@"}\nfunction getCurrentRecordId()\n"
                                "    {\n"
     "        w = window.innerWidth() / 2;\n"
     "        h = window.innerHeight() / 2;\n"
     "        el = document.elementFromPoint(w,h);\n"
     "        return el.tagName;\n"
     "    }\n"];*/
    [strHtmlHead appendString:@"</script>\n"];
    [strHtmlHead appendString:@"<style>\n"];
    [strHtmlHead appendString:@"<!--\n"];
    [strHtmlHead appendString:@".FolioFoundText { background-color:#ccccff;}\n-->\n"];
    [strHtmlHead appendFormat:@"TD { font-size: %lupt; font-family:'%@';}\n", (unsigned long)self.bodyFontSize, self.bodyFontFamily];
    [strHtmlHead appendString:@"</style>\n</head>\n"];

	//NSString * strHtmlHead2 = @"\n";
	NSString * strHtmlTail = @"</body></html>";
    


    [strHtmlHead appendFormat:@"<body id=\"body\" style='%@' background=\"%@\">\n", [self bodyStyleString], self.bodyBackgroundImage];

    [result appendData:[strHtmlHead dataUsingEncoding:NSUTF8StringEncoding]];
    //[strHtmlHead release];
	//[result appendData:stylec];
	//[result appendData:[strHtmlHead2 dataUsingEncoding:NSUTF8StringEncoding]];
    

	if (R1 > 0)
	{
		/*NSString * str = [NSString stringWithFormat:@"<p style='text-align:center;font-family:Helvetica;font-size:14pt;'>"
						  "<a href=\"vbase://files/%d#rec%d\" style='color:#888888;text-decoration:none'>&lt; Show Previous &lt;</a></p><hr width=1>\n",
						  MAKE_GLOBAL_REC_ID(storeID, (R1 - 1)), 
                          MAKE_GLOBAL_REC_ID(storeID, R1-1)];
		NSString * str = [NSString stringWithFormat:@"<p align=center><input type=\"button\" "
                          "name=\"b1\" value=\"&lt; Show Previous &lt;\" "
						  "onclick=\"location.href='vbase://files/%lu#rec%lu'\" "
                          "style=\"font-size:12pt;\"></p>\n",
						  MAKE_GLOBAL_REC_ID(storeID, (R1 - 1)),
                          MAKE_GLOBAL_REC_ID(storeID, R1-1)];*/
        NSString * str = @"";
		[result appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
    [result appendData:[@"<div id='pageBody'>\n" dataUsingEncoding:NSASCIIStringEncoding]];
	int max = recCount - 1;
	for(NSUInteger i = 0; i < max; i++)
	{
        //NSString * recordData = [self.storage readText:R1 + i forKey:@"html"];
        NSString * recordData = [self text:(R1 + i)];
        @try {
            recordData = [self text:(R1 + i)];
        }
        @catch (NSException *exception) {
            recordData = [NSString stringWithFormat:@"Record %lu failed to load.", (unsigned long)i];
            NSLog(@"%@", recordData);
        }
        @finally {
        }
        if (recordData != nil)
        {
            [result appendData:[recordData dataUsingEncoding:NSUTF8StringEncoding]];
        }
	}
    [result appendData:[@"</div>\n" dataUsingEncoding:NSASCIIStringEncoding]];
	
	if (R2 != [storage textCount])
	{
		NSString * str = @"";/*[NSString stringWithFormat:@"<p align=center><input type=\"button\" "
                          "name=\"b1\" value=\"&gt; Show Next &gt;\" "
						  "onclick=\"location.href='vbase://files/%lu#rec%lu'\" "
                          "style=\"font-size:12pt;\"></p>\n",
						  MAKE_GLOBAL_REC_ID(storeID, (R1+max)),
                          MAKE_GLOBAL_REC_ID(storeID, R1+max-3)];
		NSString * str = [NSString stringWithFormat:@"<hr width=1><p style='text-align:center;font-family:Helvetica;font-size:14pt;'>"
						  "<a href=\"vbase://files/%d#rec%d\" style='color:#888888;text-decoration:none'>&gt; Show Next &gt;</a></p>\n",
						  MAKE_GLOBAL_REC_ID(storeID, (R1+max)), 
                          MAKE_GLOBAL_REC_ID(storeID, (R1+max-3))];*/
		[result appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
    
	[result appendData:[strHtmlTail dataUsingEncoding:NSUTF8StringEncoding]];
	//[poss release];
	
#if (TARGET_IPHONE_SIMULATOR)
	[result writeToFile:@"/Users/gopalapriya/Projects/iFolio/iPadCurrentPage.html" atomically:YES];
#endif
    
	return result;
}

//
// get HTML data for range of records around given record
//
-(NSString *)htmlTextForPopup:(NSString *)noteID
{
	NSDictionary * plainText = [self.firstStorage findPopupText:noteID];
    
	if (plainText == nil)
	{
		NSLog(@"No MFNote data found for %@.\n", noteID);
		return @"";
	}
		
    FlatFileString * flat = [[FlatFileString alloc] init];
    [flat setString:[plainText objectForKey:@"plain"]];
    HtmlStylesCollection * styles = [[HtmlStylesCollection alloc] init];

    HtmlString * htmlStr = [flat htmlStringWithStyles:styles
                                            forRecord:[NSDictionary dictionaryWithObjectsAndKeys:noteID, @"NamedPopup", [plainText objectForKey:@"className"], @"levelName", nil]];

    return [self envelopeHtmlInBody:[htmlStr string]];
}

-(NSString *)htmlTextForRecordText:(NSString *)text recordId:(int)recId
{
    if ([text rangeOfString:@"&"].location != NSNotFound)
    {
        text = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    }
    if ([text rangeOfString:@"<"].location != NSNotFound)
    {
        text = [text stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    }
    if ([text rangeOfString:@">"].location != NSNotFound)
    {
        text = [text stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    }
    //text = [NSString stringWithFormat:@"<p>%@</p><p align=right><a style='text-weight:bold' href=\"vbase://editnote/%d\">[EDIT]</a></p>", text, recId];
    text = [NSString stringWithFormat:@"<p>%@</p>", text];
    return [self envelopeHtmlInBody:text];
}

-(NSString *)htmlTextForNoteRecord:(int)recId
{
    VBRecordNotes * recNote = [self recordNotesForRecord:recId];
    if (recNote)
    {
        return [self  htmlTextForRecordText:recNote.noteText recordId:recId];
    }
    return @"";
}

//
// get HTML data for range of records around given record
//
-(NSString *)htmlTextForPopup:(NSString *)noteID forPopupNumber:(NSInteger)pwCount
{
	NSDictionary * plainText;
    
    plainText = [self.firstStorage findPopupText:noteID];
    
	if (plainText == nil)
	{
		NSLog(@"No MFNote data found for %@.\n", noteID);
		return @"";
	}
    
    FlatFileString * flat = [[FlatFileString alloc] init];
    [flat setString:[plainText objectForKey:@"plain"]];
    [flat setCatchPwCounter:(int)pwCount];
    HtmlStylesCollection * styles = [[HtmlStylesCollection alloc] init];
    
    HtmlString * htmlStr = [flat htmlStringWithStyles:styles
                                            forRecord:[NSDictionary dictionaryWithObjectsAndKeys:noteID, @"NamedPopup", [plainText objectForKey:@"className"], @"levelName", nil]];
    
    return [self envelopeHtmlInBody:[htmlStr string]];
}

-(BOOL)textWithinLoadedRange:(NSUInteger)textID
{
	if ((loadedRangeStart + 5 < textID) && (loadedRangeEnd > 21) && (textID < loadedRangeEnd - 20))
		return YES;
	return NO;
}

-(NSUInteger)lastRequestedText
{
	return loadedRangeHit;
}

-(void)clearStylesCache
{
    self.stylesCache = nil;
}

-(NSData *)stylesDataCSS
{
    if (self.stylesCache == nil)
    {
        NSData * stylesData = nil;
        
        stylesData = [VBMainServant textForName:@"styles.css"];
        if (!stylesData)
        {
            NSString * styles = [self.firstStorage stylesObject];
            if (styles && [styles length] > 0)
            {
                stylesData = [styles dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            }
        }
        if (!stylesData)
            stylesData = [self findObject:@"styles.css"];
        if (stylesData) {
            self.stylesCache = stylesData;
#if (TARGET_IPHONE_SIMULATOR)
            [stylesData writeToFile:@"/Users/gopalapriya/Projects/iFolio/iPadStyles.css" atomically:YES];
#endif
        }
    }
    return self.stylesCache;
}

-(NSString *)findDocumentPath:(uint32_t)gTextID
{
    return [[self firstStorage] findDocumentPath:gTextID];
}

-(id)findObject:(NSString *)strName;
{
    NSData * stylesData = nil;
    stylesData = [self.firstStorage findObject:strName];
    return nil;
}

-(NSInteger)searchFirstRecord:(NSString *)queryText
{
    return [self.firstStorage searchFirstRecord:queryText];
}

-(int32_t)findJumpDestination:(NSString *)targetJump
{
    return [self.firstStorage findJumpDestination:targetJump];
}

-(void)search:(NSString *)queryText resultArray:(NSMutableArray *)results quotesArray:(VBHighlightedPhraseSet *)quotes ignoreSelection:(BOOL)ignoreSel queryArray:(NSMutableArray *)queries
{
    [self.firstStorage search:queryText
                  resultArray:results
                  quotesArray:quotes
             ignoreSelection:ignoreSel
                   queryArray:queries];
}


BOOL isWantedWord(NSArray * quotes, NSString * str)
{
    for (NSArray * words in quotes) 
    {
        for(NSString * s in words)
        {
            if ([s compare:str options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch] == NSOrderedSame)
                return YES;
        }
    }
	
	return NO;
}

void highlightSearchWordAction1(NSArray * words, NSMutableString * strTemp, NSMutableData * target, 
								const char * pHighlightBefore, const char * pHighlightAfter, NSMutableString * strOrig)
{
	if ([strTemp length] > 0)
	{
		if (isWantedWord(words, strTemp))
		{
			// vlozi span zaciatok
			[target appendBytes:pHighlightBefore length:strlen(pHighlightBefore)];
			[target appendData:[strOrig dataUsingEncoding:NSASCIIStringEncoding]];
			// vlozi span koniec
			[target appendBytes:pHighlightAfter length:strlen(pHighlightAfter)];
		}
		else
		{
			//NSLog(@"%s\n", szOrig);
			[target appendData:[strOrig dataUsingEncoding:NSASCIIStringEncoding]];
		}
		[strTemp setString:@""];
		[strOrig setString:@""];
	}
}

-(NSData *)highlightSearchWords:(NSData *)srcFile words:(NSArray *)arrWords
{
	if ([arrWords count] == 0)
		return srcFile;
	int rdIndex = 0;
	NSInteger rdMax = [srcFile length];
	const char * rdChars = [srcFile bytes]; 
	NSMutableData * target = [[NSMutableData alloc] initWithCapacity:(rdMax+100)];
	
	//srcFile = fopen([srcFileName UTF8String], "r");
	//destFile = fopen([destFileName UTF8String], "w");
	const char * pHighlightBefore = "<span class=\'FolioFoundText\'>"; 
	const char * pHighlightAfter = "</span>";
	
	char rdc;
	//char tempc;
	//char oemChar;
	NSMutableString * strTemp = [[NSMutableString alloc] initWithCapacity:128];
	NSMutableString * strOrig = [[NSMutableString alloc] initWithCapacity:128];
	NSMutableString * strChar = [[NSMutableString alloc] initWithCapacity:32];
	//int nState = 0;
	//int nAction = 0;
	int nCharCode = 0;
	//int nTempCharLen = 0;
	int startIndex = 0;
	
	[target setLength:0];
	
	while(rdIndex < rdMax)
	{
		rdc = rdChars[rdIndex];
		//NSLog(@"rdIndex = %d\n", rdIndex);
		if (rdChars[rdIndex] == '<')
		{
			// action 1
			highlightSearchWordAction1(arrWords, strTemp, target, pHighlightBefore, pHighlightAfter, strOrig);
			// end action 1
			startIndex = rdIndex;
			while (rdIndex < rdMax && rdChars[rdIndex] != '>') { rdIndex++; }
			if (rdChars[rdIndex] == '>') { rdIndex++; }
			[target appendBytes:(rdChars + startIndex) length:(rdIndex - startIndex)];
		}
		else if (rdChars[rdIndex] == '&')
		{
			rdIndex++;
			if (rdChars[rdIndex] == '#')
			{
				[strOrig appendFormat:@"&#"];
				rdIndex++;
				nCharCode = 0;
				while (rdChars[rdIndex] != ';') {
					[strOrig appendFormat:@"%c", rdChars[rdIndex]];
					nCharCode = nCharCode * 10 + (rdChars[rdIndex] - '0');
					rdIndex++;
				}
				if (rdChars[rdIndex] == ';')
				{
					[strOrig appendFormat:@";"];
					rdIndex++;
				}
				[strTemp appendFormat:@"%C", (unichar)nCharCode];
			}
			else {
				[strChar setString:@"&"];
				while (rdIndex < rdMax && rdChars[rdIndex] != ';') {
					[strChar appendFormat:@"%c", rdChars[rdIndex]];
					rdIndex++;
				}
				if (rdChars[rdIndex] == ';')
				{
					rdIndex ++;
					[strChar appendFormat:@";"];
					//[strOrig appendFormat:@";"];
				}
				if ([strChar isEqual:@"&nbsp;"])
				{
					// action 1
					highlightSearchWordAction1(arrWords, strTemp, target, pHighlightBefore, pHighlightAfter, strOrig);
				}
				else {
					[strOrig appendFormat:@"%@", strChar];
				}
				
			}
		}
		else if (rdc==' ' || rdc=='\n' || rdc == '\r' || rdc == '\t' || rdc == ',' || rdc == ';')
		{
			// action 1
			if ([strTemp hasSuffix:@"."])
			{
				NSRange rang2;
				rang2.location = [strTemp length] - 1;
				rang2.length = 1;
				[strTemp deleteCharactersInRange:rang2];
			}
			highlightSearchWordAction1(arrWords, strTemp, target, pHighlightBefore, pHighlightAfter, strOrig);
			[target appendBytes:(rdChars + rdIndex) length:1];
			rdIndex ++;
		}
		else
		{
			[strTemp appendFormat:@"%c", rdc];
			[strOrig appendFormat:@"%c", rdc];
			rdIndex++;
		}
	}
	
	//[strTemp release];
	//[strChar release];
	//[strOrig release];
	return target;
}


#pragma mark -
#pragma mark Persistence of shadow data

-(NSString *)shadowFilePath
{
    NSString * fileName = @"vedabase.sdw";
    return [self.documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)correctShadowRecordsWithMapping:(VBFolioRecordMapping *)mapping
{
    VBFolioStorage * store = self.firstStorage;
    
    for (VBRecordNotes * note in store.p_recordNotes)
    {
        note.recordId = [mapping correctionForRecord:note.recordId];
    }
    for (VBBookmark * bkmk in store.p_bookmarks)
    {
        bkmk.recordId = [mapping correctionForRecord:bkmk.recordId];
    }
}

- (void)load2014Shadow:(NSFileManager *)fm mapFile:(VBFolioRecordMapping *)pMapFile
{
    NSString * vb2014shadowFileName = [self.documentsDirectory stringByAppendingPathComponent:@"Untitled.sdw"];
    if ([fm fileExistsAtPath:vb2014shadowFileName])
    {
        NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithFile:vb2014shadowFileName];
        NSArray * array = [data valueForKey:@"storages"];
        for (NSDictionary * dict in array)
        {
            [self.firstStorage setDictionaryObject:dict];
        }
        
        //[self setDictionaryObject:data];
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"vb2014diff" ofType:@"txt"];
        if (path != nil && [fm fileExistsAtPath:path])
        {
            VBFolioRecordMapping * mapping = pMapFile;
            
            [self correctShadowRecordsWithMapping:mapping];
            
            [fm removeItemAtPath:vb2014shadowFileName error:NULL];
            
            [self saveShadow];
        }
        
        NSInteger current = 1;
        for (VBBookmark * bk in self.firstStorage.p_bookmarks)
        {
            bk.parentId = -1;
            bk.ID = current;
            
            current++;
        }
        
        current = 1;
        
        for (VBRecordNotes * rn in self.firstStorage.p_recordNotes)
        {
            rn.ID = current;
            rn.parentId = -1;
            
            current ++;
        }
    }
}


-(void)loadShadow
{
    NSFileManager * fm = [NSFileManager defaultManager];
    VBFolioRecordMapping * pMapFile = nil;
    NSString * pathMap = [[NSBundle mainBundle] pathForResource:@"vb2014diff" ofType:@"txt"];
    if (pathMap != nil && [fm fileExistsAtPath:pathMap])
    {
        pMapFile = [VBFolioRecordMapping new];
        [pMapFile readFile:pathMap];
    }

    NSString * currentShadowFileName = [self shadowFilePath];
    if ([fm fileExistsAtPath:currentShadowFileName])
    {
        [self loadShadowFromFile:currentShadowFileName];
    }
    else
    {
        [self load2014Shadow:fm mapFile:pMapFile];
    }
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    VBFolioStorage * storage = self.firstStorage;
    BOOL defaultBookmarks = [ud boolForKey:@"default_bookmarks_init"];
    if (defaultBookmarks == NO || (defaultBookmarks == YES && storage.p_bookmarks.count == 0))
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"bookmarks2016" ofType:@"txt"];
        NSString * strBookmarks = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSArray * lines = [strBookmarks componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for(NSString * line in lines)
        {
            NSArray * p = [line componentsSeparatedByString:@"\t"];
            if (p.count == 4)
            {
                VBBookmark * b = [VBBookmark new];
                b.ID = [(NSString *)p[0] integerValue];
                b.parentId = [(NSString *)p[1] integerValue];
                
                // we need to do correction, because default bookmraks are valid for folio 2014
                b.recordId = [(NSString *)p[2] intValue];
                b.name = p[3];
                
                [storage.p_bookmarks addObject:b];
            }
        }
        [self saveShadow];
        
        [ud setBool:YES forKey:@"default_bookmarks_init"];
        [ud synchronize];
    }
    
    pMapFile = nil;
}

-(BOOL)saveShadow
{
    return [self saveShadowToFile:[self shadowFilePath]];
}

-(void)loadShadowFromFile:(NSString *)fileName
{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:fileName])
    {
        NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        [self setDictionaryObject:data];
    }
}

-(BOOL)saveShadowToFile:(NSString *)fileName
{
    NSLog(@"saveShadowFile");
    NSDictionary * data = [self dictionaryObject];
    return [NSKeyedArchiver archiveRootObject:data toFile:fileName];
}

-(NSDictionary *)dictionaryObject
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [dict setValue:array forKey:@"storages"];
    //[array release];
    
    [array addObject:[self.firstStorage dictionaryObject]];
    
    array = [[NSMutableArray alloc] init];
    [dict setValue:array forKey:@"queries"];
    //[array release];
    for(VBUserQuery * query in self.queryHistory)
    {
        [array addObject:[query dictionaryObject]];
    }
    
    return dict;
}

-(void)setDictionaryObject:(NSDictionary *)obj
{
    NSArray * array = [obj valueForKey:@"storages"];
    for (NSDictionary * dict in array)
    {
        VBFolioStorage * storage = self.firstStorage;
        if (storage)
        {
            [storage setDictionaryObject:dict];
            
            for(VBBookmark * bk in storage.p_bookmarks)
            {
                if (bk.ID < 0)
                    bk.ID = [self getNextBookmarkId];
            }
            
            for(VBRecordNotes * rn in storage.p_recordNotes)
            {
                if (rn.ID < 0)
                    rn.ID = [self getNextNoteId];
            }
        }
    }
    
    @try {
        [self.queryHistory removeAllObjects];
        array = [obj valueForKey:@"queries"];
        if (array != nil)
        {
            for (NSDictionary * q in array)
            {
                VBUserQuery * uq = [[VBUserQuery alloc] init];
                [uq setDictionaryObject:q];
                [self.queryHistory addObject:uq];
                //[uq release];
            }
        }
    }
    @catch (NSException * E) {
        
    }
}


-(NSMutableArray *)queryHistory
{
    return queryHistory;
}

#pragma mark -
#pragma mark Bookmarks functions


-(void)removeBookmarkWithId:(NSInteger)index
{
    @try {
        VBBookmark * vb = [self bookmarkWithId:index];
        NSMutableArray * arr = [NSMutableArray new];
        if (vb) [arr addObject:vb];
        [self getAllBookmarkChildren:index array:arr];
        if (arr.count)
        {
            [self.firstStorage.p_bookmarks removeObjectsInArray:arr];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

-(void)getAllBookmarkChildren:(NSInteger)bid array:(NSMutableArray *)arr
{
    for(VBBookmark * bk in arr)
    {
        if (bk.ID == bid)
            return;
    }
    
    for(VBBookmark * bk in self.firstStorage.p_bookmarks)
    {
        if (bk.parentId == bid)
        {
            [arr addObject:bk];
            [self getAllBookmarkChildren:bk.ID array:arr];
        }
    }
}

-(VBBookmark *)bookmarkWithId:(NSInteger)bid
{
    for (VBBookmark * vb in self.firstStorage.p_bookmarks)
    {
        if (vb.ID == bid)
            return vb;
    }
    
    return nil;
}

-(NSInteger)bookmarksCountForParent:(NSInteger)bid
{
    NSInteger count = 0;
    
    for (VBBookmark * vb in self.firstStorage.p_bookmarks)
    {
        if (vb.parentId == bid)
            return vb;
    }
    
    return count;
}

-(void)addBookmark:(VBBookmark *)bk toFolder:(NSInteger)folder
{
    bk.ID = [self getNextBookmarkId];
    bk.parentId = folder;
    
    [self.firstStorage.p_bookmarks addObject:bk];
}


-(BOOL)bookmarkExists:(NSString *)bkmkName
{
    return [self.firstStorage bookmarkExists:bkmkName];
}

-(void)saveBookmark:(NSString *)bkmkName recordId:(uint32_t)recId
{
    VBBookmark * vbb = [[VBBookmark alloc] init];
    vbb.name = bkmkName;
    vbb.ID = [self getNextBookmarkId];
    vbb.recordId = recId;
    vbb.createDate  = [NSDate date];
    [self.firstStorage.p_bookmarks addObject:vbb];
}

-(void)removeBookmarkWithName:(NSString *)name
{
    [self.firstStorage removeBookmarkWithName:name];
}

-(NSArray *)bookmarksForParent:(NSInteger)parentId
{
    NSMutableArray * list = [NSMutableArray new];
    for (VBBookmark * bk in self.firstStorage.p_bookmarks)
    {
        if (bk.parentId == parentId)
            [list addObject:bk];
    }
    return list;
}

-(VBBookmark *)bookmarkWithName:(NSString *)name
{
    VBBookmark * bk = nil;
    
    bk = [self.firstStorage bookmarkWithName:name];
    if (bk != nil)
        return bk;
    
    return bk;
}


-(NSInteger)getNextBookmarkId
{
    NSInteger count = 0;
    
    for (VBBookmark * vb in self.firstStorage.p_bookmarks)
    {
        if (vb.ID >= count)
            count = vb.ID + 1;
    }
    
    return count;
}


#pragma mark -
#pragma mark Shared RecordNote & Hightext functions

-(void)removeNote:(VBRecordNotes *)note
{
    [self.firstStorage removeNote:note];
}


-(VBRecordNotes *)recordNotesForRecord:(uint32_t)recId
{
    VBFolioStorage * storage = [self firstStorage];
    if (storage)
    {
        return [storage recordNotesForRecord:recId];
    }
    return nil;
}

-(VBRecordNotes *)createNoteForRecord:(uint32_t)recId
{
    VBFolioStorage * storage = [self firstStorage];
    if (storage)
    {
        VBRecordNotes * rn = [storage createNoteForRecord:recId];
        if (rn.ID <= 0)
            rn.ID = [self getNextNoteId];
    }
    return nil;
}


-(void)addRecordNote:(VBRecordNotes *)rn toFolder:(NSInteger)folder
{
    rn.ID = [self getNextNoteId];
    rn.parentId = folder;
    
    [self.firstStorage.p_recordNotes addObject:rn];
}



-(NSInteger)getNextNoteId
{
    NSInteger count = 0;
    
    for (VBRecordNotes * vb in self.firstStorage.p_recordNotes)
    {
        if (vb.ID >= count)
            count = vb.ID + 1;
    }
    
    return count;
}

#pragma mark -
#pragma mark RecordNote functions



-(NSArray *)notesList
{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [arr addObjectsFromArray:[self.firstStorage notesList]];
    return arr;
}

-(NSArray *)notesListForParent:(NSInteger)bid
{
    NSMutableArray * array = [NSMutableArray new];
    for (VBRecordNotes * item in self.firstStorage.p_recordNotes)
    {
        if (item.noteParentID == bid && [item.noteText length] > 0)
        {
            [array addObject:item];
        }
    }
    return array;
}

-(void)getAllNotesChildren:(NSInteger)bid array:(NSMutableArray *)arr
{
    for(VBRecordNotes * rn in arr)
    {
        if (rn.ID == bid)
            return;
    }
    
    for(VBRecordNotes * bk in self.firstStorage.p_recordNotes)
    {
        if (bk.noteParentID == bid)
        {
            [arr addObject:bk];
            [self getAllNotesChildren:bk.ID array:arr];
        }
    }
}

-(void)removeUnusedRecordNotes
{
    NSMutableArray * arr = [NSMutableArray new];
    [arr removeAllObjects];
    for (VBRecordNotes * nt in self.firstStorage.p_recordNotes)
    {
        if (nt.noteText.length == 0 && nt.highlightedText.length == 0)
            [arr addObject:nt];
    }
    [self.firstStorage.p_recordNotes removeObjectsInArray:arr];
}

#pragma mark -
#pragma mark Hightext functions


-(void)setHighlighter:(int)highlighterId forRecord:(uint32_t)recId startChar:(int)startIndex endChar:(int)endIndex
{
    VBFolioStorage * radha = [self firstStorage];
    if (radha)
    {
        VBRecordNotes * recs = [radha setHighlighter:highlighterId forRecord:recId startChar:startIndex endChar:endIndex];
        if (recs.ID <= 0)
            recs.ID = [self getNextNoteId];
        if (recs)
        {
            recs.recordPath = [self findDocumentPath:recId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyHighlightersListChanged object:self];
        }
    }
}

-(NSArray *)highlightersList
{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (VBRecordNotes * item in self.firstStorage.p_recordNotes)
    {
        if ([item.anchors count] > 0 || item.highlightedText.length > 0)
        {
            [arr addObject:item];
        }
    }
    
    return arr;
}

-(VBRecordNotes *)hightextForId:(NSInteger)bid
{
    for(VBRecordNotes * rn in self.firstStorage.p_recordNotes)
    {
        if (rn.ID == bid)
            return rn;
    }
    
    return nil;
}

-(NSArray *)highlightersListForParent:(NSInteger)bid
{
    NSMutableArray * arr = [NSMutableArray new];
    for(VBRecordNotes * rn in self.firstStorage.p_recordNotes)
    {
        if (rn.parentId == bid && (rn.anchorsCount > 0 || rn.highlightedText.length > 0))
        {
            [arr addObject:rn];
        }
    }
    
    return arr;
}


-(void)getAllHightextChildren:(NSInteger)bid array:(NSMutableArray *)arr
{
    for(VBRecordNotes * rn in arr)
    {
        if (rn.ID == bid)
            return;
    }
    
    for(VBRecordNotes * bk in self.firstStorage.p_recordNotes)
    {
        if (bk.parentId == bid)
        {
            [arr addObject:bk];
            [self getAllHightextChildren:bk.ID array:arr];
        }
    }
}

-(UIImage *)imageForContentRecord:(NSInteger)recordId
{
    if (self.mapContentRecordToObjectName == nil)
    {
        self.mapContentRecordToObjectName = [self.firstStorage readObjectNamesForContentRecords];
        self.mapContentRecordToImage = [NSMutableDictionary new];
    }
    
    if (self.mapContentRecordToObjectName != nil)
    {
        NSData * data = nil;
        UIImage * image = nil;
        NSNumber * recordNumber = [NSNumber numberWithInteger:recordId];

        image = [self.mapContentRecordToImage objectForKey:recordNumber];
        if (image != nil)
            return image;
        
        NSString * objectName = [self.mapContentRecordToObjectName objectForKey:recordNumber];
        //NSLog(@"Iconname %@ for recordnum %@", objectName, recordNumber);
        if (objectName != nil) {
            data = [self.firstStorage findObject:objectName];
        }
        if (data != nil) {
            image = [[UIImage alloc] initWithData:data];
        }
        if (image != nil) {
            [self.mapContentRecordToImage setObject:image forKey:recordNumber];
        }
        return image;
    }
    
    return nil;
}

-(VBFolioContentItem *)findContentItemWithId:(int)recordId
{
    VBFolioContentItem * child = nil;
    SQLiteCommand * command = [self.firstStorage commandForKey:@"find_content_item"];
    if (command) {
        [command bindInteger:(int)recordId toVariable:1];
        if ([command execute] == SQLITE_ROW) {
            VBFolioContentItem * item = [[VBFolioContentItem alloc] initWithStorage:self.firstStorage];
            item.text = [command stringValue:0];
            item.recordId = recordId;
            item.parentId = [command intValue:2];
            item.level = [command intValue:3];
            item.simpleText = [command stringValue:4];
            item.subtext = [command stringValue:5];
            item.isLeaf = [command intValue:6];
            item.nodeCode = [command stringValue:7];
            item.nodeType = [command intValue:8];
            item.nextSibling = [command intValue:9];
            
            child = item;
        }
        
    }
    
    return child;
}

-(NSArray *)findContentItemsWithParentId:(int)parentId
{
    NSMutableArray * array = [NSMutableArray new];
    
    SQLiteCommand * command = [self.firstStorage commandForKey:@"read_content_items"];
    if (command) {
        [command bindInteger:(int)parentId toVariable:1];
        while ([command execute] == SQLITE_ROW) {
            VBFolioContentItem * item = [[VBFolioContentItem alloc] initWithStorage:self.firstStorage];
            item.text = [command stringValue:0];
            item.recordId = [command intValue:1];
            item.parentId = parentId;
            item.level = [command intValue:3];
            item.simpleText = [command stringValue:4];
            item.subtext = [command stringValue:5];
            item.isLeaf = [command intValue:6];
            item.nodeCode = [command stringValue:7];
            item.nodeType = [command intValue:8];
            item.nextSibling = [command intValue:9];
            
            [array addObject:item];
        }
        
    }
    
    return array;
}

-(VBFolioContentItem *)findContentRangeForRecordId:(int)parentId nodeType:(int)nodeType
{
    SQLiteCommand * command = [self.firstStorage commandForKey:@"find_content_range"];
    if (command) {
        [command bindInteger:(int)parentId toVariable:1];
        [command bindInteger:nodeType toVariable:2];
        if ([command execute] == SQLITE_ROW) {
            VBFolioContentItem * item = [[VBFolioContentItem alloc] initWithStorage:self.firstStorage];
            item.text = [command stringValue:0];
            item.recordId = [command intValue:1];
            item.parentId = parentId;
            item.level = [command intValue:3];
            item.simpleText = [command stringValue:4];
            item.subtext = [command stringValue:5];
            item.isLeaf = [command intValue:6];
            item.nodeCode = [command stringValue:7];
            item.nodeType = [command intValue:8];
            item.nextSibling = [command intValue:9];
            
            return item;
        }
        
    }

    return nil;
}


@end
