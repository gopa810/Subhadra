//
//  CIHighlights.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIHighlights.h"
#import "CIText.h"
#import "CIModel.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"

@implementation CIHighlights


-(BOOL)canNavigate
{
    return self.notes != nil;
}

-(NSString *)name
{
    if (self.notes)
    {
        return self.notes.highlightedText;
    }
    
    return @"Highlighted Texts";
}

-(int)titleLinesCount
{
    if (self.notes)
        return 2;
    return 1;
}

-(NSString *)subtitleText
{
    if (self.notes)
    {
        return self.notes.recordPath;
    }
    return @"";
}

-(BOOL)hasChild
{
    if (self.notes == nil)
        return YES;
    
    if (self.notes.recordId == -1)
        return YES;
    
    return NO;
}

+(void)getChildren:(NSInteger)bid toArray:(NSMutableArray *)array folio:(VBFolio *)folio
{
    NSArray * highs = [folio highlightersListForParent:bid];

    VBRecordNotes * current = [folio hightextForId:bid];
    VBRecordNotes * parent = nil;
    
    if (current != nil && current.ID != -1)
        parent = [folio hightextForId:current.parentId];

    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 5;
    iconList.fontSizeIndex = 5;
    iconList.iconAlign = 2;
    [iconList addImage:@"content_icon_dir" itemName:@"Contents" action:@"load root"];
    [iconList addImage:@"content_bkmk" itemName:@"Bookmarks" action:@"load bookmarks"];
    [iconList addImage:@"content_notes" itemName:@"Notes" action:@"load notes"];
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
    if (current)
        cit.text = current.highlightedText;
    else
        cit.text = @"Highlighted Texts";
    [array addObject:cit];

    // separator
    //
    [array addObject:[CIHorizontalLine new]];
    
    
    // parent
    //
    if (bid != -1)
    {
        CIBack * rl = [[CIBack alloc] init];
        parent = [folio hightextForId:current.parentId];
        if (parent)
        {
            rl.pageDesc = [NSString stringWithFormat:@"hightexts:%ld", (long)parent.ID];
            rl.text = [NSString stringWithFormat:@"Return to %@", parent.highlightedText];
        }
        else
        {
            rl.pageDesc = [NSString stringWithFormat:@"hightexts:-1"];
            rl.text = [NSString stringWithFormat:@"Return to Highlighted Texts"];
        }
        [array addObject:rl];
    }
    
    
    if (highs.count > 0)
    {
        for(VBRecordNotes * item in highs)
        {
            if (item.recordId == -1)
            {
                CIHighlights * cont = [[CIHighlights alloc] init];
                cont.notes = item;
                cont.pageDesc = [NSString stringWithFormat:@"hightexts:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
        for(VBRecordNotes * item in highs)
        {
            if (item.recordId != -1)
            {
                CIHighlights * cont = [[CIHighlights alloc] init];
                cont.notes = item;
                cont.pageDesc = [NSString stringWithFormat:@"hightexts:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No highlighted texts"];
        [array addObject:item];
        //[item release];
    }
}

-(NSMutableArray *)getChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [CIHighlights getChildren:-1 toArray:array folio:self.folio];
    return array;
}


-(NSString *)expandedImageName
{
    if (self.notes == nil)
        return @"cont_high_open";
    return @"cont_remove";
}

-(NSString *)collapsedImageName
{
    if (self.notes == nil)
        return @"cont_high_closed";
    return @"cont_remove";
}

-(NSString *)expandOperation
{
    return (self.notes == nil ? @"default" : @"remove");
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
    if (self.notes && self.notes.recordId != -1) return DL_CHECK_TEXT_GOTO;
    return DL_CHECK_TEXT_EXPAND;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    [self drawText:self.name rect:rect skinManager:skinManager fontBook:fontBook];
}


-(void)determineIcons:(VBSkinManager *)skinManager
{
    if (self.notes)
    {
        if (self.hasChild)
            self.iconCheck = [skinManager imageForName:@"cont_folder"];
        else
            self.iconCheck = [skinManager imageForName:@"cont_high_open"];
    }
    else
    {
        self.iconCheck = [skinManager imageForName:@"cont_high_closed"];
    }
    self.iconExpand = [skinManager imageForName:@"cont_expand_icon"];
    self.iconGoto = [skinManager imageForName:@"cont_goto_icon"];
    
    [self releaseIconsForLayout:[self determineLayout]];
}


@end
