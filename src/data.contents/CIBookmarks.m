//
//  CIBookmarks.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIBookmarks.h"
#import "CIText.h"
#import "CIModel.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"

@implementation CIBookmarks


-(BOOL)canNavigate
{
    return ![self hasChild];
}

-(BOOL)hasChild
{
    if (self.bookmark == nil)
        return YES;
    
    if (self.bookmark.recordId < 0)
        return YES;
    
    return [self.folio bookmarksCountForParent:self.bookmark.ID] > 0;
}

-(NSString *)name
{
    if (self.bookmark)
    {
        return self.bookmark.name;
    }
    
    return @"Bookmarks";
}

+(void)getChildren:(NSInteger)bid folio:(VBFolio *)folio array:(NSMutableArray *)array
{
    VBBookmark * bookmark = [folio bookmarkWithId:bid];
    NSInteger currentId = bookmark ? bookmark.ID : -1;
    NSArray * highs = [folio bookmarksForParent:currentId];

    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 5;
    iconList.fontSizeIndex = 5;
    iconList.iconAlign = 2;
    [iconList addImage:@"content_icon_dir" itemName:@"Contents" action:@"load root"];
    [iconList addImage:@"content_notes" itemName:@"Notes" action:@"load notes"];
    [iconList addImage:@"content_hightext" itemName:@"Highlights" action:@"load highlighters"];
    [iconList addImage:@"cont_playlist_open" itemName:@"Playlists" action:@"load playlists"];
    [iconList addImage:@"cont_views_open" itemName:@"Views" action:@"load views"];
    [iconList addImage:@"app_map" itemName:@"App Map" action:@"show appmap"];
    [array addObject:iconList];
    
    // separator
    //
    [array addObject:[CIHorizontalLine new]];

    // title
    //
    CITitle * cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.text = (bookmark ? bookmark.name : @"Bookmarks");
    [array addObject:cit];

    // separator
    //
    [array addObject:[CIHorizontalLine new]];

    // return line
    //
    if (currentId >= 0) {
        CIBack * rl = [[CIBack alloc] init];
        VBBookmark * parent = [folio bookmarkWithId:bookmark.parentId];
        if (parent) {
            rl.pageDesc = [NSString stringWithFormat:@"bookmarks:%ld", (long)parent.ID];
            rl.text = [NSString stringWithFormat:@"Return to %@", parent.name];
        } else {
            rl.pageDesc = [NSString stringWithFormat:@"bookmarks:-1"];
            rl.text = [NSString stringWithFormat:@"Return to Bookmarks"];
        }
        [array addObject:rl];
    }
    
    // items
    //
    if (highs.count > 0)
    {
        for(VBBookmark * item in highs)
        {
            if (item.recordId == -1)
            {
                CIBookmarks * cont = [[CIBookmarks alloc] init];
                cont.bookmark = item;
                cont.pageDesc = [NSString stringWithFormat:@"bookmarks:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
        for(VBBookmark * item in highs)
        {
            if (item.recordId != -1)
            {
                CIBookmarks * cont = [[CIBookmarks alloc] init];
                cont.bookmark = item;
                cont.pageDesc = [NSString stringWithFormat:@"bookmarks:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No bookmarks"];
        [array addObject:item];
        //[item release];
    }
}

-(NSMutableArray *)getChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    [CIBookmarks getChildren:(self.bookmark ? self.bookmark.ID : -1)
                                folio:self.folio array:array];
    
    return array;
}

-(NSString *)expandedImageName
{
    if (self.bookmark == nil)
        return @"cont_bkmk_open";
    return [super expandedImageName];
}

-(NSString *)collapsedImageName
{
    if (self.bookmark == nil)
        return @"cont_bkmk_closed";
    return [super collapsedImageName];
}


#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    CGFloat wc = [self correctWidth:width forLayout:[self determineLayout]];
    return [self
            calculateHeightForText:[self name]
            font:[fontBook valueForKey:@"regular"] width:wc];
}

-(int)determineLayout
{
    if (self.hasChild) return DL_CHECK_TEXT_EXPAND;
    return DL_CHECK_TEXT_GOTO;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    [self drawText:self.name rect:rect skinManager:skinManager fontBook:fontBook];
}


-(void)determineIcons:(VBSkinManager *)skinManager
{
    if (self.bookmark && self.bookmark.recordId > 0)
        self.iconCheck = [skinManager imageForName:@"cont_bkmk_open"];
    else if (self.bookmark)
        self.iconCheck = [skinManager imageForName:@"cont_folder"];
    else
        self.iconCheck = [skinManager imageForName:@"cont_bkmk_closed"];
    
    self.iconExpand = [skinManager imageForName:@"cont_expand_icon"];
    self.iconGoto = [skinManager imageForName:@"cont_goto_icon"];
    
    [self releaseIconsForLayout:[self determineLayout]];
}




@end
