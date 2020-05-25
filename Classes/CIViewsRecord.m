//
//  ContentItemViewRecord.m
//  VedabaseB
//
//  Created by Peter Kollath on 25/10/14.
//
//

#import "CIViewsRecord.h"
#import "CIText.h"
#import "CIModel.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"

@implementation CIViewsRecord


-(id)init
{
    self = [super init];
    if (self) {
        self.childrenFound = -1;
    }
    return self;
}

-(BOOL)canNavigate
{
    return self.views != nil;
}

-(BOOL)hasChild
{
    if (self.childrenFound >= 0)
        return self.childrenFound;
    if (self.views == nil)
    {
        self.childrenFound = 1;
        return YES;
    }
    
    BOOL b = [self.views hasChild];
    self.childrenFound = (b ? 1 : 0);
    return b;
}

-(NSString *)name
{
    if (self.views)
    {
        return self.views.title;
    }
    
    return @"Views";
}

+(void)getChildren:(NSInteger)viewId array:(NSMutableArray *)arr folio:(VBFolio *)folio
{
    VBViewRecord * vr;
    VBViewRecord * vrpar;
    
    vr = [[VBViewRecord alloc] initWithStorage:folio.firstStorage];
    vrpar = [[VBViewRecord alloc] initWithStorage:folio.firstStorage];
    vr.ID = viewId;
    [vr load];
    if (vr.loaded)
    {
        vrpar.ID = vr.parentID;
        [vrpar load];
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
    [iconList addImage:@"cont_playlist_open" itemName:@"Playlists" action:@"load playlists"];
    [iconList addImage:@"app_map" itemName:@"App Map" action:@"show appmap"];
    [arr addObject:iconList];
    
    // separator
    //
    [arr addObject:[CIHorizontalLine new]];
    
    // title
    //
    CITitle * cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.text = (vr.loaded ? vr.title : @"Views");
    [arr addObject:cit];

    // separator
    //
    [arr addObject:[CIHorizontalLine new]];
    

    // parent
    //
    if (viewId != -1)
    {
        CIBack * rl = [[CIBack alloc] init];
        rl.pageDesc = [NSString stringWithFormat:@"view:%ld", (long)vrpar.ID];
        rl.text = [NSString stringWithFormat:@"Return to %@", (vrpar.loaded ? vrpar.title : @"Views")];
        [arr addObject:rl];
    }

    // items
    //
    NSArray * highs = [vr children];
    if (highs.count > 0)
    {
        for(VBViewRecord * item in highs)
        {
            CIViewsRecord * cont = [[CIViewsRecord alloc] init];
            cont.views = item;
            cont.pageDesc = [NSString stringWithFormat:@"view:%ld", (long)item.ID];
            [arr addObject:cont];
            //[cont release];
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No views"];
        [arr addObject:item];
        //[item release];
    }
    
}


-(NSMutableArray *)getChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    [CIViewsRecord getChildren:(self.views ? self.views.ID : -1) array:array folio:self.folio];
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
    if (self.views == nil || self.hasChild)
        return DL_CHECK_TEXT_EXPAND;
    else
        return DL_CHECK_TEXT_GOTO;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    [self drawText:self.name rect:rect skinManager:skinManager fontBook:fontBook];
}


-(void)determineIcons:(VBSkinManager *)skinManager
{
    self.iconCheck = [skinManager imageForName:@"cont_views_open"];
    self.iconExpand = [skinManager imageForName:@"cont_expand_icon"];
    self.iconGoto = [skinManager imageForName:@"cont_goto_icon"];
    
    [self releaseIconsForLayout:[self determineLayout]];
    
}

@end
