//
//  FlatParagraph.m
//  VedabaseB
//
//  Created by Peter Kollath on 03/08/14.
//
//

#import "FlatParagraph.h"
#import "FDRecordBase.h"
#import "FolioTextRecord.h"
#import "FDTextFormat.h"
#import "FDCharFormat.h"
#import "FDParaFormat.h"
#import "VBRecordNotes.h"
#import "VBHighlighterAnchor.h"
#import "FlatFolioValidator.h"
#import "FlatFileUtils.h"
#import "FDParagraph.h"
#import "VBFolio.h"
#import "FDPartString.h"
#import "FDPartSpace.h"
#import "FDLink.h"
#import "FDPartImage.h"
#import "FDSideFloats.h"
#import "FDSideIntegers.h"
#import "FDTable.h"
#import "FDTableRow.h"
#import "FDTableCell.h"
#import "FDTypeface.h"
#import "FDCharFormatStack.h"

NSMutableDictionary * charFormattingMap;
NSMutableDictionary * charTypefaceMap;
NSMutableDictionary * g_predefinedBitmaps;


@implementation FlatParagraph


#pragma mark -
#pragma mark static members

+(void)initialize
{
    charTypefaceMap = [[NSMutableDictionary alloc] init];
    charFormattingMap = [[NSMutableDictionary alloc] init];
    g_predefinedBitmaps = [[NSMutableDictionary alloc] init];
}

+(int)ACTION_NONE
{
    return 0;
}

+(int)ACTION_CR
{
    return 1;
}

+(int)ACTION_HR
{
    return 2;
}

+(int)ACTION_HS
{
    return 3;
}

+(int)ACTION_IGNOREREC
{
    return 4;
}


#pragma mark -
#pragma mark instance members

-(id)init
{
    self = [super init];
    if (self)
    {
        self.dataObjectName = @"";
        self.wordBuilder = [[NSMutableString alloc] init];
        self.alternativeFormats = [[NSMutableDictionary alloc] init];
        self.pwLevel = [[NSMutableArray alloc] init];
        self.pwParaStart = [[NSMutableArray alloc] init];
        self.pwLinkStyle = [[NSMutableArray alloc] init];
        //self.charStyleStack = [[NSMutableArray alloc] init];
        //self.origCharStyleStack = [[NSMutableArray alloc] init];
    }
    return self;
}


-(id)initWithFolio:(VBFolioStorage *)source
{
    self = [self init];
    if (self) {
        self.folio = source;
    }
    return self;
}


-(void)refresh:(FDRecordBase *)recDict
{

    //self.charFormatting = [[FDCharFormat alloc] init];
    self.cfStack = [[FDCharFormatStack alloc] init];
    self.paraStyle = [[FDParaFormat alloc] init];
    
    // FIXME enable try - catch in htmlStringWithStyes
    // try {
    NSCharacterSet * whiteSpaceCharSet = [NSCharacterSet whitespaceCharacterSet];
    NSCharacterSet * wordSeparatorCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\u2013\u2014"];
    NSCharacterSet * wordPartSeparatorCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    int charCounter = 0;
    VBRecordNotes * recNotes = nil;
    VBHighlighterAnchor * highAnch = nil;
    int globalRecordId = -1;

    if (recDict.recordId != 0)
        globalRecordId = 0xffffff & recDict.recordId;

    if (globalRecordId >= 0)
    {
        recNotes = [self.folio recordNotesForRecord:globalRecordId];
    }

    highAnch = [recNotes anchorAtIndex:0];
    
    NSString * text = recDict.plainText;
    int status = 0;
    int start = 0;
    int end = 0;
    int tagIdentified = 0;
    int returnAction = 0;
    
    self.dataObjectName = @"";
    FlatFileTagString * tag = [[FlatFileTagString alloc] init];
    self.paraStyleRead = self.paraStyle;
    
    if (self.catchPwCounter == 0 && self.catchNtCounter == 0)
        self.acceptText = true;
    
    if (recNotes != nil && [recNotes hasText] && globalRecordId >= 0) {
        self.target.noteIcon = true;
    }
    
    if (recDict.levelName != nil
        && recDict.levelName.length > 0) {
        [self setStyleName:recDict.levelName paraStyle:self.paraStyle tag:@"LV"];
    }
    
    int charLength = (int)[text length];
    unichar * charArray = malloc(sizeof(unichar) * charLength);
    [text getCharacters:charArray];
    
    for (int i = 0; i < charLength; i++) {
        if (status == 0) {
            if (charArray[i] == '<') {
                status = 1;
            }
        } else if (status == 1) {
            if (charArray[i] == '<') {
                status = 0;
            } else {
                start = i - 1;
                status = 2;
            }
        } else if (status == 2) {
            if (charArray[i] == '>') {
                end = i;
                tagIdentified = 1;
                status = 0;
            } else if (charArray[i] == '"') {
                status = 3;
            }
        } else if (status == 3) {
            if (charArray[i] == '"') {
                status = 4;
            }
        } else if (status == 4) {
            if (charArray[i] == '"') {
                status = 3;
            } else if (charArray[i] == '>') {
                end = i;
                tagIdentified = 1;
                status = 0;
            }
        }
        
        if (tagIdentified == 1) {
            tagIdentified = 0;
            [tag clear];
            @try {
                [tag appendString:[text substringWithRange:NSMakeRange(start, end + 1 - start)]];
            } @catch (NSException * exception) {
                NSLog(@"Invalid range: %d, %d in string %@", start, end
                      - start + 1, text);
            } @finally {
            }

            returnAction = [self processTag:tag record:recDict];
            if (returnAction == [FlatParagraph ACTION_HR]) {
                [self.target setParaFormatting:self.paraStyle];
                FDParagraph * newPara = [[FDParagraph alloc] init];
                [self.target.parts addObject:newPara];
                self.paraStyle = [[FDParaFormat alloc] init];
            } else if (returnAction == FlatParagraph.ACTION_IGNOREREC) {
                self.acceptText = false;
                [self.target.parts removeAllObjects];
                break;
            }
        } else if (status == 0) {
            /*while (highAnch != nil && highAnch.startChar == charCounter) {
                if (highAnch.highlighterId == 0)
                {
                    [self.cfStack removeKey:@"HL"];
                }
                else
                {
                    [self.cfStack setValue:[NSNumber numberWithInt:[VBHighlighterAnchor getColor:highAnch.highlighterId]]
                                    forKey:@"HL"];
                }
                recHighlightersIndex++;
                highAnch = [recNotes anchorAtIndex:recHighlightersIndex];
            }*/
            
            if (self.acceptText) {
                if ([whiteSpaceCharSet characterIsMember:charArray[i]]) {
                    [self processWord:self.wordBuilder];
                    [self processSpace:false];
                } else if ([wordPartSeparatorCharSet characterIsMember:charArray[i]]) {
                    [self.wordBuilder appendFormat:@"%C", charArray[i]];
                    [self processWord:self.wordBuilder];
                } else if ([wordSeparatorCharSet characterIsMember:charArray[i]]) {
                    [self processWord:self.wordBuilder];
                    [self.wordBuilder appendFormat:@"%C", charArray[i]];
                    [self processWord:self.wordBuilder];
                } else {
                    [self.wordBuilder appendFormat:@"%C", charArray[i]];
                }
            }
            charCounter++;
        }
    }
    
    free(charArray);
    
    // copy of para formatting into last paragraph
    // because we know the paragraph formatting only at the end of paragraph
    // because para formatting tags can be wherever in the text
    [self.target setParaFormatting:self.paraStyle];
    
    if (self.acceptText) {
        [self processWord:self.wordBuilder];
    }
    
    /*
     * } catch (Exception exception) { Log.e("exception",
     * exception.getMessage()); target.clear();
     * target.appendString(String.format("<p>Fail to load record %d",
     * recDict.getRecord())); }
     */
    
    self.target.loading = false;

}

-(FDRecordBase *)convertToRaw:(FolioTextRecord *)recDict
{
    
    self.target = [[FDRecordBase alloc] init];
    self.target.recordId = recDict.recordId;
    self.target.plainText = recDict.plainText;
    self.target.levelName = recDict.levelName;
    self.target.namedPopup = recDict.getNamedPopup;
    
    [self refresh:self.target];
    
    return self.target;
    
}

-(void)processSpace:(BOOL)breakLine {
    FDPartSpace * sp = [[FDPartSpace alloc] init];
    sp.desiredWidth = -1;
    sp.format = [self getCurrentFormat];
    sp.typeface = [self getCurrentTypeface];
    //sp.formatSelection = null;
    sp.link = [self getCurrentLink];
    sp.breakLine = breakLine;
    sp.backgroundColor = [self getCurrentBackground];
    
    [self.target addElement:sp];
}

-(void)processWord:(NSMutableString *)string {
    
    if (string.length > 0) {
        FDPartString * ps = [[FDPartString alloc] init];
        ps.format = [self getCurrentFormat];
        ps.typeface = [self getCurrentTypeface];
        ps.link = [self getCurrentLink];
        ps.text = string;
        ps.backgroundColor = [self getCurrentBackground];
        ps.hidden = self.cfStack.hidden;
        
        [self.target addElement:ps];
        //NSLog(@"     - add word %@", string);
        [string setString:@""];
    }
}

-(void)setStyleName:(NSString *)levelName paraStyle:(FDParaFormat *)paraStyles tag:(NSString *)tag
{
    //if ([levelName isEqualToString:@"PA_DevaNagariQ"]) {
    //    NSLog(@"SetStyleName style name: %@", levelName);
    //}
    
    FDTextFormat * tf = nil;
    if (self.folio != nil) {
        tf = [self.folio getRawStyle:levelName];
    } else if (self.alternativeFormats != nil) {
        tf = [self.alternativeFormats objectForKey:levelName];
    }
    
    if (tf != nil) {
        [paraStyles copyFrom:tf.paraFormat];
        //[charStyles copyFrom:tf.textFormat];
        [self.cfStack setValue:tf.textFormat.dictionary forKey:tag];
        //NSLog(@"style name: %@", levelName);
    }
}

-(int)getCurrentBackground {
    if (self.cfStack.backgroundColor != 0) {
        return self.cfStack.backgroundColor;
    }
    return self.paraStyle.backgroundColor;
}


-(FDLink *)getCurrentLink {
    return self.currLink;
}


-(NSMutableDictionary *)getCurrentFormat {
    
    NSString * hash = [self.cfStack getHash];
    NSMutableDictionary * paint = [charFormattingMap objectForKey:hash];
    if (paint)
        return paint;
    
    NSMutableDictionary * pt = [self.cfStack getDictionary];
    [charFormattingMap setObject:pt forKey:hash];
    return pt;
}

-(FDTypeface *)getCurrentTypeface
{
    NSString * hash = [self.cfStack getTypefaceHash];
    //NSLog(@"typeface hash %@", hash);
    FDTypeface * paint = [charTypefaceMap objectForKey:hash];
    if (paint)
        return paint;
    
    FDTypeface * pt = [self.cfStack getTypeface];
    [charTypefaceMap setObject:pt forKey:hash];
    return pt;
}


-(void)popCharStyle
{
/*    if (self.charStyleStack.count > 0) {
        FDCharFormat * fes = self.charStyleStack.lastObject;
        [self.charStyleStack removeLastObject];
        //self.charFormatting = fes;
        [self.charFormatting copyFrom:fes];
    }
    
    if (self.origCharStyleStack.count > 0) {
        FDCharFormat * oes = self.origCharStyleStack.lastObject;
        [self.origCharStyleStack removeLastObject];
        //self.origCharFormatting = oes;
        [self.cfStack copyFrom:oes];
    }*/
}

-(void)pushCharStyle:(NSString *)stringToSafe key:(NSString *)key
{

    //[self.charStyleStack addObject:[self.charFormatting clone]];
    //[self.origCharStyleStack addObject:[self.cfStack clone]];
    
    FDTextFormat * tf = nil;
    if (self.folio != nil) {
        tf = [self.folio getRawStyle:stringToSafe];
    } else if (self.alternativeFormats != nil) {
        tf = [self.alternativeFormats objectForKey:stringToSafe];
    }
    if (tf != nil && tf.textFormat != nil) {
//        [self.charFormatting overloadFrom:tf.textFormat];
        [self.cfStack setValue:tf.textFormat.dictionary
                        forKey:key];
    }
}


- (void)readTableFormatting:(NSArray *)tagArr table:(FDTable *)table
{
    int count = (int)tagArr.count;
    int curr = 1;
    int mode = 0;
    while (curr < count)
    {
        NSString * p = tagArr[curr];
        if (mode == 0)
        {
            if ([p isEqualToString:@":"])
            {
                mode = 1;
            }
        }
        else if (mode == 1)
        {
            if ([p isEqualToString:@";"])
            {
                if ([table.columnWidths count] > 0)
                {
                    [table.columnWidths removeObjectAtIndex:0];
                }
                self.startIndex = curr + 1;
                break;
            }
            else if ([p isEqualToString:@","])
            {
            }
            else
            {
                NSNumber * num = [NSNumber numberWithDouble:(double)[self inchToPoints:p]];
                [table.columnWidths addObject:num];
            }
        }
        else if (mode == 2)
        {
        }
        curr++;
    }
}

-(int)processTag:(FlatFileTagString *)tag record:(FDRecordBase *)recordDict
{
    NSArray * tagArr = [tag createArray];
    NSString * str = tagArr[0];
    //FDCharFormat * charStyle = self.charFormatting;
    
    int returnAction = FlatParagraph.ACTION_NONE;
    
    //
    // first processing is for taga, which can influence levels of text
    //
    if ([str isEqualToString:@"PW"]) {
        
        [self processWord:self.wordBuilder];
        
        self.hcPwCounter++;
        [self.pwLevel addObject:[NSNumber numberWithInt:self.hcPwCounter]];
        [self.pwParaStart addObject:[NSNumber numberWithBool:self.hcParaStarted]];
        self.hcParaStarted = false;
        self.acceptText = (self.hcPwCounter == self.catchPwCounter);
        [self.pwLinkStyle addObject:(tagArr.count > 2 ? tagArr[2] : @"")];
    } else if ([str isEqualToString:@"LT"]) {
        
        [self processWord:self.wordBuilder];
        
        int restCount = 0;
        if (self.pwLevel.count > 0)
            [self.pwLevel removeLastObject];
        if (self.pwLevel.count > 0) {
            restCount = [(NSNumber *)[self.pwLevel lastObject] intValue];
            [self.pwLevel removeLastObject];
        } else
            restCount = 0;
        if (self.pwParaStart.count > 0) {
            self.hcParaStarted = [(NSNumber *)[self.pwParaStart lastObject] intValue];
            [self.pwParaStart removeLastObject];
        }
        NSString * classFormat = @"Popup";
        if (self.pwLinkStyle.count > 0) {
            classFormat = [self.pwLinkStyle lastObject];
        }
        self.acceptText = (restCount == self.catchPwCounter);
        //checkParagraphStart(target, paraStyle);
        
        if (recordDict.namedPopup != nil) {
            
            self.currLink = [[FDLink alloc] init];
            self.currLink.type = @"DP";
            self.currLink.link = [NSString stringWithFormat:@"%@/%d", recordDict.namedPopup, self.hcPwCounter];
            [self pushCharStyle:[@"LK_" stringByAppendingString:classFormat] key:@"LK"];
            /*target.appendString(String.format("<a class=\"LK_%s\" href=\"vbase://inlinepopup/DP/%s/%d\">",
             classFormat, FlatFileUtils.encodeLinkSafeString(recordDict
             .getNamedPopup()), hcPwCounter));*/
        } else {
            self.currLink = [[FDLink alloc] init];
            self.currLink.type = @"PW";
            self.currLink.link = [NSString stringWithFormat:@"%d/%d", recordDict.recordId, self.hcPwCounter];
            [self pushCharStyle:[@"LK_" stringByAppendingString:classFormat] key:@"LK"];
            /*target.appendString(String
             .format("<a class=\"LK_%s\" href=\"vbase://inlinepopup/RD/%d/%d\">",
             classFormat, recordDict.getRecord(),
             hcPwCounter));*/
        }
        if (self.pwLinkStyle.count > 0) {
            [self.pwLinkStyle removeLastObject];
        }
    } else if ([str isEqualToString:@"NT"]) {
        [self processWord:self.wordBuilder];
        self.hcNtCounter++;
        self.acceptText = (self.hcNtCounter == self.catchNtCounter);
    } else if ([str isEqualToString:@"/NT"]) {
        [self processWord:self.wordBuilder];
        _hcNtCounter--;
        _acceptText = (_hcNtCounter == _catchNtCounter);
    }
    
    //
    // if text is not accepted, then also tags are rejected to write
    //
    if (!_acceptText) {
        return FlatParagraph.ACTION_NONE;
    }
    
    if ([str isEqualToString:@"ETH"]) {
        // TODO eth bude ignorovany cely
        // namiesto toho bude len link do contents na dany record
        // ignoruje vsetko ostatne z tohoto recordu
        return FlatParagraph.ACTION_IGNOREREC;
    }
    
    if ([str isEqualToString:@"AUDIO"]) {
        FDPartImage * img = [[FDPartImage alloc] init];
        [self.target addElement:img];
        
        UIImage * bmp = [self getPredefinedBitmap:IMAGE_AUDIO];
        if (bmp != nil) {
            img.bitmap = bmp;
            img.desiredWidth = bmp.size.width;
            img.desiredHeight = bmp.size.height;
        }
        
        img.link = [[FDLink alloc] init];
        img.link.type = @"DL";
        img.link.link = tagArr[2];
        
    }
    // extended para styles
    if ([str isEqualToString:@"PS"]) {
        NSString * safeString = [FlatFileString stringToSafe:tagArr[2]  tag:@"PA"];
        [self setStyleName:safeString paraStyle:self.paraStyle tag:@"PS"];
        self.paraStyle.styleName = safeString;
    } else if ([str isEqualToString:@"LV"]) {
        NSString * safeString = [FlatFileString stringToSafe:tagArr[2] tag:@"LE"];
        [self setStyleName:safeString paraStyle:self.paraStyle tag:@"LV"];
        self.paraStyle.levelName = safeString;
    }
    
    // reading paragraph styles
    if ([str isEqualToString:@"AP"]) {
        [self.paraStyle.margins setSide:SIDE_BOTTOM value:[self inchToPoints:tagArr[2]]];
    } else if ([str isEqualToString:@"BP"]) {
        [self.paraStyle.margins setSide:SIDE_TOP value:[self inchToPoints:tagArr[2]]];
    } else if ([str isEqualToString:@"BR"]) {
        self.startIndex = 2;
        [self readBorders:tagArr style:self.paraStyle];
    } else if ([str isEqualToString:@"JU"]) {
        self.paraStyle.align = [self alignFromString:tagArr[2]];
    } else if ([str isEqualToString:@"LH"]) {
        @try {
            double v = [tagArr[2] doubleValue];
            self.paraStyle.lineHeight = (float)v;
        } @catch (NSException * e) {
        }
    } else if ([str isEqualToString:@"IN"]) {
        self.startIndex = 2;
        [self readIndentFormating:tagArr style:self.paraStyle];
    } else if ([str isEqualToString:@"SD"]) {
        /*if (tagArr.size() == 1 || tagArr[2].equals("false")) {
         paraStyle.setValueForKey("background-color-x", "");
         } else {
         startIndex = 2;
         readColor(tagArr, "background-color-x", paraStyle);
         }*/
    } else if ([str isEqualToString:@"TS"]) {
    } else if ([str isEqualToString:@"DECOR"]) {
        [self readDecorations:tagArr style:self.paraStyle];
    }
    
    if ([str isEqualToString:@"BC"]) {
        
    } else if ([str isEqualToString:@"BD-"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:NO] forKey:@"BD"];
        //charStyle.bold = false;
        //[(FDCharFormat *)[self.charStyleStack lastObject] setBold:charStyle.bold];
        //NSLog(@"  - BD- bold value is %@", (charStyle.bold ? @"YES" : @"NO"));
    } else if ([str isEqualToString:@"BD"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"BD"];
//        charStyle.bold = self.cfStack.bold;
//        [(FDCharFormat *)[self.charStyleStack lastObject] setBold:charStyle.bold];
        //NSLog(@"  - BD bold value is %@", (charStyle.bold ? @"YES" : @"NO"));
    } else if ([str isEqualToString:@"BD+"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"BD"];
        //self.cfStack.bold = charStyle.bold;
        //charStyle.bold = true;
        //[(FDCharFormat *)[self.charStyleStack lastObject] setBold:charStyle.bold];
        //NSLog(@"  - BD+ bold value is %@", (charStyle.bold ? @"YES" : @"NO"));
    } else if ([str isEqualToString:@"UN-"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:NO] forKey:@"UN"];
        //self.cfStack.underline = charStyle.underline;
        //			prevCfUnderline = charStyle.isUnderline();
        //charStyle.underline = (false);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setUnderline:charStyle.underline];
    } else if ([str isEqualToString:@"UN"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"UN"];
        //charStyle.underline = self.cfStack.underline;
        //[(FDCharFormat *)[self.charStyleStack lastObject] setUnderline:charStyle.underline];
    } else if ([str isEqualToString:@"UN+"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"UN"];
        //self.cfStack.underline = charStyle.underline;
        //			prevCfUnderline = charStyle.isUnderline();
        //charStyle.underline = (true);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setUnderline:charStyle.underline];
    } else if ([str isEqualToString:@"SO-"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:NO] forKey:@"SO"];
        //self.cfStack.strikeOut = charStyle.strikeOut;
        //prevCfStrikeOut = charStyle.isStrikeOut();
        //charStyle.strikeOut = (false);
    } else if ([str isEqualToString:@"SO"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"SO"];
        //charStyle.strikeOut = self.cfStack.strikeOut;
    } else if ([str isEqualToString:@"SO+"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"SO"];
        //self.cfStack.strikeOut = charStyle.strikeOut;
        //prevCfStrikeOut = charStyle.isStrikeOut();
        //charStyle.strikeOut = (true);
    } else if ([str isEqualToString:@"HD-"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:NO] forKey:@"HD"];
        //self.cfStack.hidden = charStyle.hidden;
        //prevCfHidden = charStyle.isHidden();
        //charStyle.hidden = (false);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setHidden:charStyle.hidden];
    } else if ([str isEqualToString:@"HD"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"HD"];
        //charStyle.hidden = self.cfStack.hidden;
        //[(FDCharFormat *)[self.charStyleStack lastObject] setHidden:charStyle.hidden];
    } else if ([str isEqualToString:@"HD+"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"HD"];
        //self.cfStack.hidden = charStyle.hidden;
        //prevCfHidden = charStyle.isHidden();
        //charStyle.hidden = (true);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setHidden:charStyle.hidden];
    } else if ([str isEqualToString:@"CS"]) {
        [self processWord:self.wordBuilder];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"CS"] key:@"CS"];
    } else if ([str isEqualToString:@"/CS"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"CS"];
    } else if ([str isEqualToString:@"FC"]) {
        [self processWord:self.wordBuilder];
        if (tagArr.count == 1 || [tagArr[2] isEqualToString:@"DC"])
        {
            [self.cfStack removeKey:@"FC"];
            //charStyle.foregroundColor = self.cfStack.foregroundColor;
        } else {
            self.startIndex = 2;
            //prevCfForeColor = charStyle.getForegroundColor();
            //charStyle.foregroundColor = [self readColor:tagArr];
            [self.cfStack setValue:[NSNumber numberWithInt:[self readColor:tagArr]] forKey:@"FC"];
        }
        //[(FDCharFormat *)[self.charStyleStack lastObject] setForegroundColor:charStyle.foregroundColor];
    } else if ([str isEqualToString:@"FT"]) {
        [self processWord:self.wordBuilder];
        if (tagArr.count == 1) {
            //charStyle.fontName = self.cfStack.fontName;
            [self.cfStack removeKey:@"FT"];
        } else {
            [self.cfStack setValue:[tagArr objectAtIndex:2] forKey:@"FT"];
            //NSString * fontName = tagArr[2];
            //prevCfFontName = charStyle.getFontName();
            //charStyle.fontName = fontName;
        }
        //[(FDCharFormat *)[self.charStyleStack lastObject] setFontName:charStyle.fontName];
    } else if ([str isEqualToString:@"IT-"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:NO] forKey:@"IT"];
        //self.cfStack.italic = charStyle.italic;
        //prevCfItalic = charStyle.isItalic();
        //charStyle.italic = (false);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setItalic:charStyle.italic];
    } else if ([str isEqualToString:@"IT"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"IT"];
        //charStyle.italic = self.cfStack.italic;
        //[(FDCharFormat *)[self.charStyleStack lastObject] setItalic:charStyle.italic];
    } else if ([str isEqualToString:@"IT+"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"IT"];
        //self.cfStack.italic = charStyle.italic;
        //prevCfItalic = charStyle.isItalic();
        //charStyle.italic = (true);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setItalic:charStyle.italic];
    } else if ([str isEqualToString:@"PN"]) {
        [self processWord:self.wordBuilder];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"PD"] key:@"PD"];
    } else if ([str isEqualToString:@"/PN"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"PD"];
    } else if ([str isEqualToString:@"PT"]) {
        [self processWord:self.wordBuilder];
        if (tagArr.count == 1) {
            [self.cfStack removeKey:@"PT"];
            //charStyle.textSize = self.cfStack.textSize;
        } else {
            NSString * ptSizeDescr = tagArr[2];
            if ([ptSizeDescr hasSuffix:@"pt"])
                ptSizeDescr = [ptSizeDescr substringWithRange:NSMakeRange(0, ptSizeDescr.length - 2)];
            int ptSize = [ptSizeDescr intValue];
            [self.cfStack setValue:[NSNumber numberWithFloat:(float)ptSize] forKey:@"PT"];
            //charStyle.textSize = ptSize;
            if ([ptSizeDescr intValue] == 14) {
                if (self.paraStyle.lineHeight < 1) {
                    self.paraStyle.lineHeight = (float)1.2;
                }
            }
        }
        //[(FDCharFormat *)[self.charStyleStack lastObject] setTextSize:charStyle.textSize];
    } else if ([str isEqualToString:@"SP"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"SP"];
        //charStyle.superScript = (true);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setSuperScript:charStyle.superScript];
    } else if ([str isEqualToString:@"SB"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack setValue:[NSNumber numberWithBool:YES] forKey:@"SB"];
        //charStyle.subScript = (true);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setSubScript:charStyle.subScript];
    } else if ([str isEqualToString:@"/SS"]) {
        [self processWord:self.wordBuilder];
        [self.cfStack removeKey:@"SP"];
        [self.cfStack removeKey:@"SB"];
        //charStyle.subScript = (false);
        //charStyle.superScript = (false);
        //[(FDCharFormat *)[self.charStyleStack lastObject] setSuperScript:charStyle.superScript];
        //[(FDCharFormat *)[self.charStyleStack lastObject] setSubScript:charStyle.subScript];
    }
    
    //
    // tag for controlling
    //
    
    if ([str isEqualToString:@"CR"]) {
        [self processWord:self.wordBuilder];
        [self processSpace:true];
    } else if ([str isEqualToString:@"HR"]) {
        [self processWord:self.wordBuilder];
        returnAction = FlatParagraph.ACTION_HR;
    } else if ([str isEqualToString:@"HS"]) {
        [self.wordBuilder appendString:@" "];
    } else if ([str isEqualToString:@"OB"]) {
        
        [self processWord:self.wordBuilder];
        
        //String ob_type = tagArr[2];
        NSString * ob_name = tagArr[4];
        NSString * ob_width = @"";
        NSString * ob_height = @"";
        if (tagArr.count > 6)
            ob_width = tagArr[6];
        if (tagArr.count > 8)
            ob_height = tagArr[8];
        // NSMutableDictionary * form = [[NSMutableDictionary alloc]
        // initWithCapacity:10];
        //StringBuilder s = new StringBuilder();
        NSString * objectType = [FlatFileUtils normalizeFileType:tagArr[2]];
        if (objectType == nil) {
            objectType = [FlatFileUtils getMimeType:[ob_name pathExtension]];
        }
        if (self.folio != nil) {
            if ([FlatFileUtils isImageMimeType:objectType]) {
                FDPartImage * img = [[FDPartImage alloc] init];
                img.imageName = ob_name;
                img.desiredWidth = [self inchToPoints:ob_width];
                img.desiredHeight = [self inchToPoints:ob_height];
                [self.target addElement:img];
                
                NSData * ob = [self.folio findObject:ob_name];
                if (ob != nil) {
                    UIImage * bmp = [[UIImage alloc] initWithData:ob];
                    if (bmp != nil) {
                        img.bitmap = bmp;
                        img.desiredWidth = bmp.size.width;
                        img.desiredHeight = bmp.size.height;
                    }
                }
                //Log.i("drawq", "bitmap with name " + ob_name + " height: " + img.desiredHeight);
            }
        }
    } else if ([str isEqualToString:@"QL"] || [str isEqualToString:@"EN"]) {
        [self processWord:self.wordBuilder];
        NSString * query = tagArr[4];
        
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = query;
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"PX"] || [str isEqualToString:@"REL"]) {
        
        [self processWord:self.wordBuilder];
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = tagArr[4];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"DL"] || [str isEqualToString:@"ML"] || [str isEqualToString:@"PL"]) {
        
        [self processWord:self.wordBuilder];
        self.dataObjectName = tagArr[4];
        
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = tagArr[4];
        self.currLink.completeTag = tagArr;
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"WW"]) {
        
        [self processWord:self.wordBuilder];
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = tagArr[4];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"/DL"] || [str isEqualToString:@"/ML"] || [str isEqualToString:@"EL"]
               || [str isEqualToString:@"/EN"] || [str isEqualToString:@"/JL"] || [str isEqualToString:@"/PX"]
               || [str isEqualToString:@"/OL"] || [str isEqualToString:@"/PL"] || [str isEqualToString:@"/QL"]
               || [str isEqualToString:@"/PW"] || [str isEqualToString:@"/WW"] || [str isEqualToString:@"/RL"]) {
        
        if (self.currLink != nil) {
            //NSLog(@"type: %@ link: %@ ", self.currLink.type, self.currLink.link);
        }
        [self processWord:self.wordBuilder];
        self.currLink = nil;
        [self.cfStack removeKey:@"LK"];
        
    } else if ([str isEqualToString:@"JL"]) {
        
        [self processWord:self.wordBuilder];
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = tagArr[4];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"RL"]) {
        
        [self processWord:self.wordBuilder];
        self.currLink = [[FDLink alloc] init];
        self.currLink.type = str;
        self.currLink.link = tagArr[4];
        [self pushCharStyle:[FlatFileString stringToSafe:tagArr[2] tag:@"LK"] key:@"LK"];
        
    } else if ([str isEqualToString:@"RO"]) {
        [self processWord:self.wordBuilder];
        FDTable * table = [self getLastSafeTable];
        FDTableRow * row = [[FDTableRow alloc] init];
        [table addRow:row];
        
    } else if ([str isEqualToString:@"TB"]) {
        
        [self processWord:self.wordBuilder];
        FDPartSpace * sp = [[FDPartSpace alloc] init];
        sp.link = [self getCurrentLink];
        sp.format = [self getCurrentFormat];
        sp.typeface = [self getCurrentTypeface];
        sp.tab = true;
        sp.backgroundColor = [self getCurrentBackground];
        [self.target addElement:sp];
        
    } else if ([str isEqualToString:@"TA"]) {
        
        [self processWord:self.wordBuilder];
        FDTable * table = [[FDTable alloc] init];
        [self.target.parts addObject:table];
        [self readTableFormatting:tagArr table:table];
        [self readParaFormating:tagArr style:table.paraFormat];
        
    } else if ([str isEqualToString:@"CE"]) {
        
        [self processWord:self.wordBuilder];
        FDTable * table = [self getLastSafeTable];
        FDTableCell * cell = [[FDTableCell alloc] init];
        [table addCell:cell];
        
    } else if ([str isEqualToString:@"/CE"]) {
        [self processWord:self.wordBuilder];
        FDTableCell * cell = [self getLastTableCell];
        if (cell != nil) {
            cell.closed = true;
        }
    } else if ([str isEqualToString:@"/TA"]) {
        [self processWord:self.wordBuilder];
        FDTable * table = [self getLastTable];
        if (table)
            table.closed = true;
    }
    
    
    return returnAction;
}


-(UIImage *)getPredefinedBitmap:(int)imageId {
    
    NSNumber * key = [NSNumber numberWithInt:imageId];
    UIImage * bmp = [g_predefinedBitmaps objectForKey:key];
    if (bmp != nil)
        return bmp;
    
    switch(imageId) {
		case IMAGE_AUDIO:
            {
                NSString * resourceFileName = [[NSBundle mainBundle] pathForResource:@"speaker40" ofType:@"png"];
                bmp = [[UIImage alloc] initWithContentsOfFile:resourceFileName];
            }
			break;
    }
    
    if (bmp != nil) {
        [g_predefinedBitmaps setObject:bmp forKey:key];
    }
    return bmp;
}


-(float)percentValue:(NSString *)value {
    float d = (float)[value doubleValue];
    if (d < 0.3) {
        d = 1;
    }
    return d;
}

-(void)readParaFormating:(NSArray *)arrTag style:(FDParaFormat *)paraStyle {
    
    int oldi = self.startIndex;
    for (int i = self.startIndex; i < arrTag.count; i++) {
        NSString * tag = arrTag[i];
        if ([tag isEqualToString:@"AP"]) {
            [paraStyle.margins setSide:SIDE_BOTTOM value:[self inchToPoints:arrTag[i + 2]]];
            i += 2;
        } else if ([tag isEqualToString:@"BP"]) {
            [paraStyle.margins setSide:SIDE_TOP value:[self inchToPoints:arrTag[i + 2]]];
            i += 2;
        } else if ([tag isEqualToString:@"JU"]) {
            paraStyle.align = [self alignFromString:arrTag[i + 2]];
            i += 2;
        } else if ([tag isEqualToString:@"SD"]) {
            i += 2;
            paraStyle.backgroundColor = [self readColor:arrTag];
        } else if ([tag isEqualToString:@"LH"]) {
            paraStyle.lineHeight = [self inchToPoints:arrTag[i + 2]] / 14.0f;
            i += 2;
        } else if ([tag isEqualToString:@"LS"]) {
            paraStyle.lineHeight = [self percentValue:arrTag[i + 2]];
            i += 2;
        } else if ([tag isEqualToString:@"IN"]) {
            i += 2;
            self.startIndex = i;
            [self readIndentFormating:arrTag style:paraStyle];
            i = self.startIndex;
            self.startIndex = oldi;
        } else if ([tag isEqualToString:@"BR"]) {
            i += 2;
            self.startIndex = i;
            [self readBorders:arrTag style:paraStyle];
            i = self.startIndex;
            self.startIndex = oldi;
        } else {
            while (i < arrTag.count && [arrTag[i] isEqualToString:@";"] == NO) {
                i++;
            }
        }
        
    }
    
}


-(FDTableCell *)getLastTableCell
{
    FDTable * table = [self getLastTable];
    FDTableCell * cell = nil;
    if (table != nil) {
        cell = [table getLastCell];
    }
    return cell;
}


-(FDTable *)getLastTable {
    FDTable * table;
    if (self.target.parts.count == 0) {
        return nil;
    } else {
        if ([[self.target getLastPart] isKindOfClass:[FDTable class]]) {
            table = (FDTable *)[self.target getLastPart];
            if (table.closed)
                return nil;
        } else {
            return nil;
        }
    }
    return table;
}


-(FDTable *)getLastSafeTable
{
    FDTable * table = [self getLastTable];
    if (table == nil) {
        table = [[FDTable alloc] init];
        [self.target.parts addObject:table];
    }
    return table;
}

-(int)sideIndexFromAbbr:(NSString *)side
{
    if ([side isEqualToString:@"AL"])
        return SIDE_ALL;
    if ([side isEqualToString:@"LF"])
        return SIDE_LEFT;
    if ([side isEqualToString:@"RT"])
        return SIDE_RIGHT;
    if ([side isEqualToString:@"BT"])
        return SIDE_BOTTOM;
    if ([side isEqualToString:@"TP"])
        return SIDE_TOP;
    if ([side isEqualToString:@"VT"])
        return SIDE_LEFTRIGHT;
    if ([side isEqualToString:@"HZ"])
        return SIDE_TOPBOTTOM;
    return SIDE_UNDEF;
}

-(float)inchToPoints:(NSString *)value {
	
    BOOL isPt = NO;
    BOOL isPerc = NO;
    double d = 0.0;
    if ([value hasSuffix:@"pt"]) {
        value = [value substringToIndex:value.length - 2];
        isPt = true;
    } else if ([value hasSuffix:@"%"]) {
        value = [value substringToIndex:value.length - 1];
        isPerc = true;
    }
    d = [value doubleValue];
    if (isPt) {
        
    } else if (isPerc) {
        d = d * 14.0 / 100.0;
    } else {
        d = d * 72.0;
    }
 
    return (float)d;
}

-(void)readBorders:(NSArray *)arrTag style:(FDParaFormat *)paraStyle
{
    NSString * side;
    int postfix = 0;
    float value;
    
    float strWidth = 0;
    int strColor = 0;
    
    while (self.startIndex < arrTag.count) {
        strWidth = 0;
        strColor = 0;
        side = arrTag[self.startIndex];
        postfix = [self sideIndexFromAbbr:side];
        if (postfix == SIDE_UNDEF)
        {
            self.startIndex--;
            return;
        }
        
        // NSLog("postifx: %@\n", postfix);
        self.startIndex += 2;
        if (self.startIndex >= arrTag.count)
        {
            self.startIndex--;
            return;
        }
        strWidth = [self inchToPoints:arrTag[self.startIndex]];
        self.startIndex += 2;
        if (self.startIndex >= arrTag.count)
        {
            self.startIndex--;
            return;
        }
        value = [self inchToPoints:arrTag[self.startIndex]];
        [paraStyle.padding setSide:postfix value:value];
        self.startIndex += 1;
        if (self.startIndex >= arrTag.count)
        {
            self.startIndex--;
            return;
        }
        self.startIndex += 1;
        if (self.startIndex >= arrTag.count)
        {
            self.startIndex--;
            return;
        }
        side = arrTag[self.startIndex];
        if ([side isEqualToString:@"FC"]) {
            self.startIndex += 2;
            strColor = [self readColor:arrTag];
            self.startIndex += 1;
        } else {
            strColor = 0;
        }
        [paraStyle.borderColor setSide:postfix value:strColor];
        [paraStyle.borderWidth setSide:postfix value:strWidth];
    }
    
}

-(void)readDecorations:(NSArray *)arrTag style:(FDParaFormat *)paraStyle
{
    NSString * side;
    int idx = 2;
    
    while (idx < arrTag.count) {

        side = arrTag[idx];
        if ([side isEqualToString:@"BI"] && (idx + 2 < arrTag.count))
        {
            paraStyle.imageBefore = arrTag[idx+2];
            idx += 4;
        }
        else if ([side isEqualToString:@"BIW"] && (idx + 2 < arrTag.count))
        {
            paraStyle.imageBeforeWidth = [self inchToPoints:arrTag[idx+2]];
            idx += 4;
        }
        else if ([side isEqualToString:@"AI"] && (idx + 2 < arrTag.count))
        {
            paraStyle.imageAfter = arrTag[idx+2];
            idx += 4;
        }
        else if ([side isEqualToString:@"AIW"] && (idx + 2 < arrTag.count))
        {
            paraStyle.imageAfterWidth = [self inchToPoints:arrTag[idx+2]];
            idx += 4;
        }
        else if ([side isEqualToString:@"NOA"])
        {
            paraStyle.imageAfterHide = YES;
            idx += 2;
        }
        else if ([side isEqualToString:@"NOB"])
        {
            paraStyle.imageBeforeHide = YES;
            idx += 2;
        }
        else if ([side isEqualToString:@"NO"])
        {
            paraStyle.imageAfterHide = YES;
            paraStyle.imageBeforeHide = YES;
            idx += 2;
        }
        else
        {
            idx += 2;
        }
    }
    
}

-(int)readColor:(NSArray *)tagArr
{
    int vr, vg, vb;
    NSString * str;
    int strColor = 0;
    
    if (self.startIndex < tagArr.count) {
        str = tagArr[self.startIndex];
        if ([str isEqualToString:@"DC"] || [str isEqualToString:@"NO"])
        {
            self.startIndex += 1;
            return 0;
        }
        vr = [str intValue];
        self.startIndex += 2;
        vg = [(NSString *)(tagArr[self.startIndex]) intValue];
        self.startIndex += 2;
        vb = [(NSString *)(tagArr[self.startIndex]) intValue];
        
        strColor = (vr << 16) | (vg << 8) | vb | 0xff000000;
        self.startIndex += 2;
        
        if (self.startIndex >= tagArr.count)
            return strColor;
        if ([tagArr[self.startIndex] isEqualToString:@"DC"]) {
            self.startIndex += 1;
        } else {
            self.startIndex -= 1;
        }
    }
    return strColor;
}

-(int)alignFromString:(NSString *)str
{
    int a = ALIGN_JUST;
    if ([str isEqualToString:@"CN"])
        a = ALIGN_CENTER;
    if ([str isEqualToString:@"RT"])
        a = ALIGN_RIGHT;
    if ([str isEqualToString:@"FL"])
        a = ALIGN_JUST;
    if ([str isEqualToString:@"CA"])
        a = ALIGN_LEFT;
    return a;
}

-(void)readIndentFormating:(NSArray *)arrTag style:(FDParaFormat *)paraStyles
{
    NSString * str;
    NSString * paramName = @"ml";
    float f;
    
    f = [self inchToPoints:arrTag[self.startIndex]];
    if (f == 0) {
        if (arrTag.count <= self.startIndex
            || [arrTag[self.startIndex] isEqualToString:@";"])
        {
            return;
        }
        while (arrTag.count > self.startIndex) {
            str = arrTag[self.startIndex];
            paramName = str;
            
            self.startIndex += 2;
            if (arrTag.count <= self.startIndex
                || [arrTag[self.startIndex] isEqualToString:@";"]) {
                return;
            }
            f = [self inchToPoints:arrTag[self.startIndex]];
            if ([paramName isEqualToString:@"LF"]) {
                [paraStyles.margins setSide:SIDE_LEFT value:f];
            } else if ([paramName isEqualToString:@"RT"]) {
                [paraStyles.margins setSide:SIDE_RIGHT value:f];
            } else if ([paramName isEqualToString:@"FI"]) {
                paraStyles.firstIndent = f;
            }
            self.startIndex += 1;
            if (arrTag.count <= self.startIndex
                || [arrTag[self.startIndex] isEqualToString:@";"])
            {
                return;
            }
            self.startIndex += 1;
        }
    } else {
        [paraStyles.margins setSide:SIDE_LEFT value:f];
        self.startIndex += 1;
        if (arrTag.count <= self.startIndex
            || [arrTag[self.startIndex] isEqualToString:@";"]) {
            return;
        }
        self.startIndex += 1;
        f = [self inchToPoints:arrTag[self.startIndex]];
        [paraStyles.margins setSide:SIDE_RIGHT value:f];
        self.startIndex += 1;
        if (arrTag.count <= self.startIndex
            || [arrTag[self.startIndex] isEqualToString:@";"]) {
            return;
        }
        self.startIndex += 1;
        f = [self inchToPoints:arrTag[self.startIndex]];
        paraStyles.firstIndent = f;
        return;
    }
    
    return;
}

+(void)setDefaultFont:(NSString *)fontName
{
    [FDTypeface setDefaultFontName:fontName];
    for (NSString * str in [charTypefaceMap keyEnumerator])
    {
        FDTypeface * tf = [charTypefaceMap objectForKey:str];
        if (tf.isGeneralFont) {
            tf.familyName = fontName;
        }
    }
}

+(NSString *)getDefaultFont
{
    return FDTypeface.defaultFontName;
}



@end
