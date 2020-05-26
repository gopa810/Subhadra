//
//  VBContentManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import "VBContentManager.h"
#import "VBFolio.h"
#import "VBFolioStorage.h"
#import "VBFolioStorageObjects.h"
#import "CIBase.h"
#import "CIModel.h"
#import "CINotes.h"
#import "CIHighlights.h"
#import "CIBookmarks.h"
#import "CIPlaylist.h"
#import "CIViewsRecord.h"
#import "CIText.h"
#import "CIIconList.h"
#import "CITitle.h"
#import "CIHorizontalLine.h"

BOOL gbExpandedExtras = YES;

@implementation VBContentManager


-(id)init
{
    self = [super init];
    if (self) {
        self.itemBookmarks = [[CIBookmarks alloc] init];
        self.itemBookmarks.pageDesc = @"bookmarks";
        self.itemHighlighters = [[CIHighlights alloc] init];
        self.itemHighlighters.pageDesc = @"highlighters";
        self.itemNotes = [[CINotes alloc] init];
        self.itemNotes.pageDesc = @"notes";
        self.itemPlaylists = [[CIPlaylist alloc] init];
        self.itemPlaylists.pageDesc = @"playlists";
        self.itemViews = [[CIViewsRecord alloc] init];
        self.itemViews.pageDesc = @"views";
        self.lastPageType = @"";
    }
    return self;

}

-(void)setFolio:(VBFolio *)folio
{
    self->_folio = folio;
    
    VBFolioStorage * storage = folio.firstStorage;
    [storage initContentObject];
    self.folioContent = storage.content;

    self.itemBookmarks.folio = folio;
    self.itemHighlighters.folio = folio;
    self.itemNotes.folio = folio;
    self.itemViews.folio = folio;
    self.itemPlaylists.folio = folio;
    
    NSNotification * no = [NSNotification notificationWithName:@"VBContentManager_changedFolio" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:no];

}

-(NSArray *)itemsForContentPage:(NSString *)page onlyContent:(BOOL)bOnlyContent
{
    self.lastPageType = page;
    
    if ([page isEqualToString:@"root"])
    {
        self.lastPageType = @"contents";
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [CIModel getChildren:0 array:arr folio:self.folio];
        return arr;
    }
    else if ([page isEqualToString:@"bookmarks"])
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        [CIBookmarks getChildren:-1 folio:self.folio array:array];
        return array;
    }
    else if ([page isEqualToString:@"highlighters"])
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        [CIHighlights getChildren:-1 toArray:array folio:self.folio];
        return array;
    }
    else if ([page isEqualToString:@"notes"])
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        [CINotes getChildren:-1 folio:self.folio array:array];
        return array;
    }
    else if ([page isEqualToString:self.itemPlaylists.pageDesc])
    {
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [self addContentItems:arr fromNode:self.itemPlaylists isTop:NO];
        return arr;
    }
    else if ([page isEqualToString:self.itemViews.pageDesc])
    {
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [self addContentItems:arr fromNode:self.itemViews isTop:NO];
        return arr;
    }
    else if ([page hasPrefix:@"page:"])
    {
        self.lastPageType = @"contents";
        int pageNo = [[page substringFromIndex:5] intValue];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [CIModel getChildren:pageNo array:arr folio:self.folio];
        return arr;
    }
    else if ([page hasPrefix:@"playlist:"])
    {
        self.lastPageType = @"playlists";
        int playId = [[page substringFromIndex:9] intValue];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [CIPlaylist getChildren:playId array:arr folio:self.folio];
        return arr;
        
    }
    else if ([page hasPrefix:@"view:"])
    {
        self.lastPageType = @"views";
        int viewId = [[page substringFromIndex:5] intValue];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [CIViewsRecord getChildren:viewId array:arr folio:self.folio];
        return arr;
    }
    else if ([page hasPrefix:@"bookmarks:"])
    {
        self.lastPageType = @"bookmarks";
        int bid = [[page substringFromIndex:10] intValue];
        NSMutableArray * arr = [NSMutableArray new];
        [CIBookmarks getChildren:bid folio:self.folio array:arr];
        return arr;
    }
    else if ([page hasPrefix:@"hightexts:"])
    {
        self.lastPageType = @"highlighters";
        int bid = [[page substringFromIndex:10] intValue];
        NSMutableArray * arr = [NSMutableArray new];
        [CIHighlights getChildren:bid toArray:arr folio:self.folio];
        return arr;
    }
    else if ([page hasPrefix:@"notes:"])
    {
        self.lastPageType = @"notes";
        int bid = [[page substringFromIndex:6] intValue];
        NSMutableArray * arr = [NSMutableArray new];
        [CINotes getChildren:bid folio:self.folio array:arr];
        return arr;
    }
    else if ([page isEqualToString:@"appmap"])
    {
        return [self itemsForAppMap];
    }
    
    return nil;
}

-(NSArray *)itemsForAppMap
{
    NSMutableArray * arr = [NSMutableArray new];
    
    // navigation section
    CITitle * cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.paddingTop = 32;
    cit.text = @"Navigation";
    cit.textAlign = 1;
    [arr addObject:cit];
    
    [arr addObject:[CIHorizontalLine new]];

    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 3;
    iconList.fontSizeIndex = 3;
    iconList.iconAlign = 1;
    iconList.iconSpacing = 18;
    [iconList addImage:@"content_icon_dir" itemName:@"Contents" action:@"load root"];
    [iconList addImage:@"content_bkmk" itemName:@"Bookmarks" action:@"load bookmarks"];
    [iconList addImage:@"content_notes" itemName:@"Notes" action:@"load notes"];
    [iconList addImage:@"content_hightext" itemName:@"Highlights" action:@"load highlighters"];
    [iconList addImage:@"cont_playlist_open" itemName:@"Playlists" action:@"load playlists"];
    [iconList addImage:@"cont_views_open" itemName:@"Views" action:@"load views"];
    [arr addObject:iconList];
    

    // navigation section
    cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.paddingTop = 32;
    cit.text = @"Reading";
    cit.textAlign = 1;
    [arr addObject:cit];
    
    [arr addObject:[CIHorizontalLine new]];
    
    // top menu
    //
    iconList = [CIIconList new];
    iconList.iconSizeIndex = 3;
    iconList.fontSizeIndex = 3;
    iconList.iconAlign = 1;
    iconList.iconSpacing = 18;
    [iconList addImage:@"content_icon_text" itemName:@"Texts" action:@"show text"];
    [iconList addImage:@"search_icon" itemName:@"Search" action:@"show search"];
    [iconList addImage:@"content_icon_book" itemName:@"Sanskrit\nDictionary" action:@"show mwdict"];
    [arr addObject:iconList];
    

    // navigation section
    cit = [CITitle new];
    cit.pageDesc = @"";
    cit.paddingTop = 32;
    cit.text = @"Extras";
    cit.textAlign = 1;
    [arr addObject:cit];
    
    [arr addObject:[CIHorizontalLine new]];
    
    // top menu
    //
    iconList = [CIIconList new];
    iconList.iconSizeIndex = 3;
    iconList.fontSizeIndex = 3;
    iconList.iconAlign = 1;
    iconList.iconSpacing = 18;
    [iconList addImage:@"web_icon" itemName:@"Online Support"
                action:@"show web http://vedabase.home.sk/ios"];
    [iconList addImage:@"web_icon" itemName:@"Bhaktivedanta\nArchives"
                action:@"show web http://prabhupada.com"];
    [iconList addImage:@"web_icon" itemName:@"Bhaktivedanta\nBook Trust"
                action:@"show web http://bbti.org"];
    [arr addObject:iconList];
    
    

    
    return arr;
}


-(NSArray *)itemsForRootPage:(BOOL)bOnlyContent
{
    NSMutableArray * contItems = [[NSMutableArray alloc] init];
    
    /*NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger bkmkPos;
    NSInteger notePos;
    NSInteger highPos, viewPos, playPos;
    
    bkmkPos = [userDefaults integerForKey:@"cont_bkmk_pos"];
    notePos = [userDefaults integerForKey:@"cont_note_pos"];
    highPos = [userDefaults integerForKey:@"cont_highs_pos"];
    viewPos = [userDefaults integerForKey:@"cont_view_pos"];
    playPos = [userDefaults integerForKey:@"cont_play_pos"];*/

    /*if (!bOnlyContent)
    {
        [contItems addObject:self.itemBookmarks];
        
        [contItems addObject:self.itemNotes];
    
        [contItems addObject:self.itemHighlighters];
    
        [contItems addObject:self.itemViews];
    
        [contItems addObject:self.itemPlaylists];
    }
    else
    {*/
        [self addContentItems:contItems fromContentItem:self.folioContent onlyContent:bOnlyContent];
    //}

    return contItems;
}


-(void)addContentItems:(NSMutableArray *)contItems fromNode:(CIBase *)startItem isTop:(BOOL)bIsTop
{
    NSMutableArray * origChildren = [startItem getChildren];
    
	for(CIBase * elem in origChildren)
	{
        // for TOP items we exclude "< back" item
        if ([elem isKindOfClass:[CIBack class]] && bIsTop)
            continue;
        
		//ContentItemModel * cellData = [[[ContentItemModel alloc] init] autorelease];
		//cellData.item = elem;
		elem.level = 0;
		elem.expanded = NO;
        elem.cell = nil;
        if (startItem.selected != NSMixedState)
        {
            elem.selected = startItem.selected;
        }
		[contItems addObject:elem];
	}
}

-(void)addContentItems:(NSMutableArray *)contItems fromContentItem:(VBFolioContentItem *)item onlyContent:(BOOL)bOnlyContent
{
    if ([item child] != nil)
    {
        VBFolioContentItem * child = [item child];
        
        VBFolioContentItem * parent = item.parent;
        if (parent)
        {
            //NSLog(@"parent item text: %@", parent.text);
            //NSLog(@"parent item record: %ld", (unsigned long)parent.recordId);
            CIBack * ciret = [[CIBack alloc] init];
            ciret.text = [NSString stringWithFormat:@"Return to %@", ((parent.text == nil) ? @"Root Content" : parent.text)];
            ciret.pageDesc = [NSString stringWithFormat:@"page:%ld", (unsigned long)parent.recordId];
            [contItems addObject:ciret];

            /*ContentItemModel * ciret = [[ContentItemModel alloc] init];
            ciret.text = [NSString stringWithFormat:@"Return to %@", ((parent.text == nil) ? @"Root Content" : parent.text)];
            ciret.pageDesc = [NSString stringWithFormat:@"page:%ld", (unsigned long)parent.recordId];
            [contItems addObject:ciret];*/
        }

        if (!bOnlyContent)
        {
            if (item.recordId > 0)
            {
                //NSLog(@"current item text: %@", item.text);
                //NSLog(@"current item record: %ld", (unsigned long)item.recordId);
                CITitle * cititle = [[CITitle alloc] init];
                cititle.text = ((item.text == nil) ? @"Root Content" : item.text);
                cititle.pageDesc = [NSString stringWithFormat:@"page:%ld", (unsigned long)item.recordId];
                [contItems addObject:cititle];
            }
        }
        
        while(child)
        {
            CIModel * ci = [CIModel contentItem:child];
            ci.level = 0;
            ci.expanded = NO;
            ci.cell = nil;
            ci.pageDesc = [NSString stringWithFormat:@"page:%d", ci.recordId];
            if (item.selected != NSMixedState)
            {
//                ci.selected = item.selected;
            }
            [contItems addObject:ci];
            child = [child next];
        }
    }
    
}

-(NSString *)findPageForRecord:(int)recId
{
    if (recId < 1)
        return @"root";
    
    VBFolioContentItem * ci = [self.folioContent findRecordPath:(NSUInteger)recId];
    if (ci != nil)
    {
        if (ci.childValid && ci.child == nil)
        {
            if (ci.parent != nil)
                return [NSString stringWithFormat:@"page:%ld", (unsigned long)ci.parent.recordId];
        }
        else
        {
            return [NSString stringWithFormat:@"page:%ld", (unsigned long)ci.parent.recordId];
        }
    }
    
    return @"root";
}

-(void)fillPath:(NSMutableArray *)path forRecord:(int)recId
{
    if (recId < 1)
        return;
    
    VBFolioContentItem * ci = [self.folioContent findRecordPath:(NSUInteger)recId];
    if (ci != nil)
    {
        if (ci.childValid && ci.child == nil)
        {
            if (ci.parent != nil)
                ci = ci.parent;
        }
    }
    
    NSMutableArray * arr = [NSMutableArray new];
    
    
    while(ci != nil)
    {
        if (ci.text) {
            [arr insertObject:ci.text atIndex:0];
        }
        ci = ci.parent;
    }
    
    [path addObjectsFromArray:arr];
    
    return;
}

-(NSString *)findViewFromPath:(NSArray *)arr
{
    VBViewRecord * vr = [[VBViewRecord alloc] initWithStorage:self.folio.firstStorage];
    
    return [NSString stringWithFormat:@"view:%ld", (long)[vr findViewAtPath:arr]];
}

@end
