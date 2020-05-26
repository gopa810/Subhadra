//
//  ContentItemPlaylist.m
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import "CIPlaylist.h"
#import "CIText.h"
#import "CIModel.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"


@implementation CIPlaylist

-(id)init
{
    self = [super init];
    if (self) {
        self->_child = -1;
    }
    return self;
}

-(BOOL)canNavigate
{
    return self.playlist != nil;
}

-(BOOL)hasChild
{
    if (self->_child >= 0)
    {
        return self->_child;
    }
    
    // this is for case, when playlist is not instantiated
    // in that case we provide list of playlists with parent = -1
    if (self.playlist == nil)
    {
        self->_child = 1;
        return YES;
    }
    
    //NSLog(@"ContentItemPlaylist::hasChild playlist id = %ld", (long)self.playlist.ID);
    
    BOOL b = [self.playlist hasChild];
    self->_child = (b ? 1 : 0);
    return b;
}

-(NSString *)name
{
    if (self.playlist)
    {
        if (self.playlist.title == nil)
            return @"PLAYII";
        return self.playlist.title;
    }
    
    return @"Playlists";
}

+(void)getChildren:(NSInteger)playId array:(NSMutableArray *)arr folio:(VBFolio *)folio
{
    NSArray * highs;
    
    VBPlaylist * pl = nil;
    VBPlaylist * plpar = nil;
    
    if (playId >= 0)
    {
        pl = [[VBPlaylist alloc] initWithStorage:folio.firstStorage];
        pl.ID = playId;
        [pl load];
    }

    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 5;
    iconList.fontSizeIndex = 5;
    iconList.iconAlign = 2;
    [iconList addImage:@"content_icon_dir" itemName:@"Contents" action:@"load root"];
    [iconList addImage:@"content_bkmk" itemName:@"Bookmarks" action:@"load bookmarks"];
    [iconList addImage:@"content_notes" itemName:@"Notes" action:@"load notes"];
    [iconList addImage:@"content_hightext" itemName:@"Highlights" action:@"load highlighters"];
    [iconList addImage:@"cont_views_open" itemName:@"Views" action:@"load views"];
    [iconList addImage:@"app_map" itemName:@"App Map" action:@"show appmap"];
    [arr addObject:iconList];
    
    // separator
    //
    [arr addObject:[CIHorizontalLine new]];

    // title
    //
    CITitle * cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.text = (playId < 0 ? @"Playlists" : pl.title);
    [arr addObject:cit];
    
    // separator
    //
    [arr addObject:[CIHorizontalLine new]];
    

    // parent
    //
    if (playId >= 0) {
        CIBack * rl = [[CIBack alloc] init];
        rl.pageDesc = [NSString stringWithFormat:@"playlist:%ld", (long)pl.parentID];
        plpar = [[VBPlaylist alloc] initWithStorage:folio.firstStorage];
        plpar.ID = pl.parentID;
        [plpar load];
        rl.text = [NSString stringWithFormat:@"Return to %@", (plpar.ID == -1 ? @"Playlists" : plpar.title)];
        [arr addObject:rl];
    }
    
    if (pl == nil)
    {
        pl = [[VBPlaylist alloc] initWithStorage:folio.firstStorage];
        pl.ID = -1;
    }
    highs = [pl children];
    
    if (highs.count > 0)
    {
        for(VBPlaylist * item in highs)
        {
            CIPlaylist * cont = [[CIPlaylist alloc] init];
            cont.playlist = item;
            cont.pageDesc = [NSString stringWithFormat:@"playlist:%ld", (long)item.ID];
            [arr addObject:cont];
            //[cont release];
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No playlists"];
        [arr addObject:item];
        //[item release];
    }
    
    return;
}

-(NSMutableArray *)getChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    [CIPlaylist getChildren:(self.playlist ? self.playlist.ID : -1)
                               array:array folio:self.folio];
    return array;
}


#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    CGFloat wc = [self correctWidth:width forLayout:[self determineLayout]];
    return [self
            calculateHeightForText:self.name
            font:[fontBook valueForKey:@"regular"] width:wc];
}

-(int)determineLayout
{
    if (self.playlist == nil) return DL_CHECK_TEXT_EXPAND;
    if (self.hasChild) return DL_CHECK_TEXT_EXPAND_GOTO;
    return DL_CHECK_TEXT_GOTO;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    [self drawText:self.name rect:rect skinManager:skinManager fontBook:fontBook];
}


-(void)determineIcons:(VBSkinManager *)skinManager
{
    self.iconCheck = [skinManager imageForName:@"cont_playlist_open"];
    self.iconExpand = [skinManager imageForName:@"cont_expand_icon"];
    self.iconGoto = [skinManager imageForName:@"cont_playlist_play"];
    
    [self releaseIconsForLayout:[self determineLayout]];
}

@end
