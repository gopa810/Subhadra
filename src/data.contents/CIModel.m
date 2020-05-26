//
//  VBContentItem.m
//  VedabaseA
//
//  Created by Gopal on 25.5.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CIModel.h"
#import "CIText.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"
#import "VBFolio.h"

@implementation CIModel

//@synthesize folioContentItem;
@synthesize hits;

-(id)init
{
	if ((self = [super init]) != nil)
	{
		self.selected = NSOffState;
		self.hits = nil;
		children = nil;
		self.expanded = NO;
	}
	return self;
}

-(void)dealloc
{
	children = nil;//[children release];
	//[super dealloc];
}

+(CIModel *)contentItem:(VBFolioContentItem *)s
{
	CIModel * ni = [[CIModel alloc] init];
//	ni.folioContentItem = s;
    ni.name = s.text;
    ni.recordId = s.recordId;
	return ni;
}


-(void)clearHits
{
	self.hits = nil;
	if (children != nil)
	{
		for(CIModel * item in children)
		{
			[item clearHits];
		}
	}
}

-(void)incrementHits
{
	if (self.hits == nil)
	{
		self.hits = [NSNumber numberWithInt:1];
		return;
	}
	
	self.hits = [NSNumber numberWithInt:([self.hits intValue] + 1)];
}

+(void)getChildren:(int)recordId array:(NSMutableArray *)arr folio:(VBFolio *)folio
{
    NSArray * highs;
    
    VBFolioContentItem * pl = nil;
    
    if (recordId >= 0)
    {
        pl = [folio findContentItemWithId:recordId];
    }

    
    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 5;
    iconList.fontSizeIndex = 5;
    iconList.iconAlign = 2;
    [iconList addImage:@"content_bkmk" itemName:@"Bookmarks" action:@"load bookmarks"];
    [iconList addImage:@"content_notes" itemName:@"Notes" action:@"load notes"];
    [iconList addImage:@"content_hightext" itemName:@"Highlights" action:@"load highlighters"];
    [iconList addImage:@"cont_playlist_open" itemName:@"Playlists" action:@"load playlists"];
    [iconList addImage:@"cont_views_open" itemName:@"Views" action:@"load views"];
    [iconList addImage:@"app_map" itemName:@"App Map" action:@"show appmap"];
    [arr addObject:iconList];
    
    // separator
    //
    [arr addObject:[CIHorizontalLine new]];
    
    // title (if parent item is present)
    //
    if (pl != nil)
    {
        CITitle * cit = [[CITitle alloc] init];
        cit.pageDesc = @"";
        cit.text = (recordId < 0 ? @"Contents" : pl.text);
        [arr addObject:cit];
        
        [arr addObject:[CIHorizontalLine new]];
        
    }
    
    // looking for parent item
    //
    if (pl != nil) {
        VBFolioContentItem * parentItem = [folio findContentItemWithId:pl.parentId];
        CIModel * rl = [[CIModel alloc] init];
        rl.pageDesc = [NSString stringWithFormat:@"page:%d", pl.parentId];
        rl.name = [NSString stringWithFormat:@"Return to %@", (parentItem == nil ? @"Contents" : parentItem.text)];
        rl.recordId = pl.parentId;
        rl.parentId = 0;
        rl.hasChild = YES;
        rl.iconName = @"hdr_back_2";
        [arr addObject:rl];
    }
    
    
    highs = [folio findContentItemsWithParentId:recordId];
    
    if (highs.count > 0)
    {
        for(VBFolioContentItem * item in highs)
        {
            CIModel * cont = [[CIModel alloc] init];
            cont.recordId = item.recordId;
            cont.parentId = item.parentId;
            cont.name = item.text;
            cont.nodeType = item.nodeType;
            cont.nodeCode = item.nodeCode;
            cont.hasChild = (item.isLeaf > 0);
            cont.pageDesc = [NSString stringWithFormat:@"page:%d", item.recordId];
            if (!cont.hasChild)
                cont.nodeType = 1;
            if (item.nodeType == 1)
                cont.iconName = @"content_icon_text";
            else if (item.nodeType == 2)
                cont.iconName = @"content_icon_book";
            else
                cont.iconName = @"content_icon_dir";
            [arr addObject:cont];
            //[cont release];
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No items"];
        [arr addObject:item];
        //[item release];
    }
    
    return;
}


-(BOOL)canSelect
{
    return YES;
}

-(BOOL)canNavigate
{
    return self.recordId > 0;
}

/*-(NSInteger)selected
{
    return [folioContentItem selected];
}

-(void)setSelected:(NSInteger)aSelected
{
    if (self.folioContentItem == nil) {
        self.folioContentItem = [[VBFolioContentItem alloc] initWithStorage:nil];
    }
    [folioContentItem setSelected:aSelected];

    [super setSelected:aSelected];
}
*/
-(NSString *)listOfSelectedItems
{
    NSMutableString * str = [[NSMutableString alloc] initWithCapacity:10];
    /*
    for (ContentItemModel * cim in children) {
        if (cim.folioContentItem != nil && cim.folioContentItem.selected != 0) {
            if ([str length] > 0) {
                [str appendString:@", "];
            }
            [str appendFormat:@"%@", cim.folioContentItem.text];
        }
    }*/
    return str;//[str autorelease];
}

-(NSString *)expandedImageName
{
    if (self.hasChild)
    {
        return @"cont_book_open";
    }
    return @"cont_text";
}

-(NSString *)collapsedImageName
{
    if (self.hasChild)
    {
        return @"cont_book_closed";
    }
    return @"cont_text";
}


#pragma mark -
#pragma mark Drawing Layout

-(NSArray *)convertTextToRich:(NSString *)plainCont fontBook:(NSDictionary *)fontBook
{
    NSMutableString * text = [[NSMutableString alloc] init];
    NSMutableString * tag = [[NSMutableString alloc] init];
    NSInteger mode = 0;
    NSString * plain = plainCont;
    NSInteger len = [plain length];
    NSDictionary * nextFormat = [fontBook valueForKey:@"styleM"];
    NSMutableArray * arrFormat = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < len; i++)
    {
        unichar uc = [plain characterAtIndex:i];
        if (mode == 0)
        {
            if (uc == '<')
            {
                mode = 1;
                [tag setString:@""];
            }
            else
            {
                [text appendFormat:@"%C", uc];
            }
        }
        else if (mode == 1)
        {
            if (uc == '>')
            {
                mode = 0;
                if ([tag hasPrefix:@"STP:"])
                {
                    if ([text length] > 0 && nextFormat != nil)
                    {
                        NSMutableDictionary * md = [[NSMutableDictionary alloc] init];
                        [md setObject:[NSString stringWithString:text] forKey:@"text"];
                        [md setObject:nextFormat forKey:@"format"];
                        [arrFormat addObject:md];
                    }
                    [text setString:@""];
                    nextFormat = [self determineFormat:[tag substringFromIndex:4] fontBook:fontBook];
                }
            }
            else
            {
                [tag appendFormat:@"%C", uc];
            }
        }
    }
    
    if ([text length] > 0 && nextFormat != nil)
    {
        NSMutableDictionary * md = [[NSMutableDictionary alloc] init];
        [md setObject:[NSString stringWithString:text] forKey:@"text"];
        [md setObject:nextFormat forKey:@"format"];
        [arrFormat addObject:md];
    }
    
    return arrFormat;
}

-(NSDictionary *)determineFormat:(NSString *)fmt fontBook:(NSDictionary *)fontBook
{
    NSDictionary * dict = [fontBook valueForKey:[NSString stringWithFormat:@"style%@", fmt]];
    if (dict)
        return dict;
    
    return [fontBook valueForKey:@"styleM"];
}

-(CGSize)textSizeForWidth:(CGFloat)widthText fontBook:(NSDictionary *)fontBook
{
    CGSize maxSize = CGSizeMake(widthText, 100);
    CGSize estimatedTextSize,estimatedText2Size;
    if (self.richText == nil)
    {
        NSString * plainText = self.name;
        self.richText = [self convertTextToRich:plainText fontBook:fontBook];
    }
    
    
    estimatedTextSize = CGSizeMake(widthText, 0);
    for (NSMutableDictionary * dict in self.richText)
    {
        NSDictionary * format = [dict objectForKey:@"format"];
        NSString * text = [dict objectForKey:@"text"];
        CGRect rect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:[format valueForKey:NSFontAttributeName]}
                                         context:nil];
        estimatedText2Size = rect.size;
        estimatedTextSize.height += estimatedText2Size.height;
        [dict setObject:[NSNumber numberWithDouble:estimatedText2Size.height] forKey:@"height"];
        [dict setObject:[NSNumber numberWithDouble:widthText] forKey:@"width"];
    }
    
    return estimatedTextSize;
}

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    CGFloat height = 0;
    CGFloat widthText = width;
    CGSize estimatedTextSize;
    height = MAX(height, CHECK_MARK_AREA_WIDTH);
    
    widthText -= CHECK_MARK_AREA_WIDTH;
    
    estimatedTextSize = [self textSizeForWidth:widthText
                              fontBook:fontBook];

    height = MAX(height, estimatedTextSize.height + 2*AREA_INSET);
    height = MAX(height, GOTO_MARK_AREA_WIDTH / 3  * 4);

    return height;
}

-(int)determineLayout
{
    return DL_CHECK_TEXT;
}

-(void)determineIcons:(VBSkinManager *)skinManager
{
    if (self.iconsValid)
        return;

    self.iconImage = [skinManager imageForName:self.iconName];

    self.drawingLayout = DL_CHECK_TEXT;
    
    self.iconsValid = YES;
}



-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    //UIImage * greyLine = [skinManager imageForName:@"gray_line"];
    UIImage * image = [skinManager imageForName:@"lite_papyrus"];
    
    CGRect checkMarkArea = CGRectMake(0, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
    if (self.drawingPartTouched == DP_CHECK) {
        [image drawInRect:checkMarkArea];
    }
    CGRect checkMarkAreaIcon = CGRectInset(checkMarkArea, AREA_INSET, AREA_INSET);
    
    
    CGRect textArea = CGRectMake(CHECK_MARK_AREA_WIDTH, 0, rect.size.width - CHECK_MARK_AREA_WIDTH, rect.size.height);

    
    [self.iconImage drawInRect:checkMarkAreaIcon];
    
    if (self.drawingPartTouched == DP_TEXT)
    {
        [image drawInRect:textArea];
    }
    textArea = CGRectInset(textArea, 0, AREA_INSET);

    [self drawTextInRect:textArea];

    
    [self drawBottomLine:skinManager rect:rect];
//    [self drawGradientSeparator:greyLine inRect:rect];
}

-(void)drawTextInRect:(CGRect)textArea
{
    for (NSDictionary * dict in self.richText)
    {
        NSDictionary * format = [dict objectForKey:@"format"];
        NSString * text = [dict objectForKey:@"text"];
        NSNumber * height = [dict objectForKey:@"height"];
        NSNumber * width = [dict objectForKey:@"width"];
        //NSLog(@"Calculated width: %f, currentwidth: %f", width.doubleValue, textArea.size.width);
        textArea.size.width = width.doubleValue;
        [text drawInRect:textArea withAttributes:format];
        textArea.origin.y += [height doubleValue];
    }
}

@end


















