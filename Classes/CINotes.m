//
//  CINotes.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CINotes.h"
#import "CIText.h"
#import "CIModel.h"
#import "CIHorizontalLine.h"
#import "CIIconList.h"

@implementation CINotes


-(BOOL)canNavigate
{
    return self.notes != nil;
}

-(NSString *)name
{
    if (self.notes)
    {
        return self.notes.noteText;
    }
    
    return @"Notes";
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
    return (self.notes == nil || self.notes.recordId == -1);
}

+(void)getChildren:(NSInteger)bid folio:(VBFolio *)folio array:(NSMutableArray *)array
{
    NSArray * highs = [folio notesListForParent:bid];
    
    VBRecordNotes * current = [folio hightextForId:bid];
    NSInteger currentId = -1;
    if (current) currentId = current.ID;
    VBRecordNotes * parent;
    
    
    // top menu
    //
    CIIconList * iconList = [CIIconList new];
    iconList.iconSizeIndex = 5;
    iconList.fontSizeIndex = 5;
    iconList.iconAlign = 2;
    [iconList addImage:@"content_icon_dir" itemName:@"Contents" action:@"load root"];
    [iconList addImage:@"content_bkmk" itemName:@"Bookmarks" action:@"load bookmarks"];
    [iconList addImage:@"content_hightext" itemName:@"Highlights" action:@"load highlighters"];
    [iconList addImage:@"cont_playlist_open" itemName:@"Playlists" action:@"load playlists"];
    [iconList addImage:@"cont_views_open" itemName:@"Views" action:@"load views"];
    [iconList addImage:@"app_map" itemName:@"App Map" action:@"show appmap"];
    [array addObject:iconList];
    
    // separator
    //
    [array addObject:[CIHorizontalLine new]];
    
    
    // title
    CITitle * cit = [[CITitle alloc] init];
    cit.pageDesc = @"";
    cit.text = (current != nil ? current.noteText : @"Notes");
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
            rl.pageDesc = [NSString stringWithFormat:@"notes:%ld", (long)parent.ID];
            rl.text = [NSString stringWithFormat:@"Return to %@", parent.highlightedText];
        }
        else
        {
            rl.pageDesc = [NSString stringWithFormat:@"notes:-1"];
            rl.text = [NSString stringWithFormat:@"Return to Notes"];
        }
        [array addObject:rl];
    }

    // items
    //
    if (highs.count > 0)
    {
        for(VBRecordNotes * item in highs)
        {
            if (item.recordId == -1)
            {
                CINotes * cont = [[CINotes alloc] init];
                cont.notes = item;
                cont.pageDesc = [NSString stringWithFormat:@"notes:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
        for(VBRecordNotes * item in highs)
        {
            if (item.recordId != -1)
            {
                CINotes * cont = [[CINotes alloc] init];
                cont.notes = item;
                cont.pageDesc = [NSString stringWithFormat:@"notes:%ld", (long)item.ID];
                [array addObject:cont];
            }
        }
    }
    else
    {
        CIText * item = [[CIText alloc] init];
        [item setName:@"No notes"];
        [array addObject:item];
    }
}

-(NSMutableArray *)getChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    [CINotes getChildren:(self.notes ? self.notes.ID : -1) folio:self.folio array:array];
    
    return array;
}

-(NSString *)expandedImageName
{
    if (self.notes == nil)
        return @"cont_note_open";
    return @"cont_remove";
}

-(NSString *)collapsedImageName
{
    if (self.notes == nil)
        return @"cont_note_closed";
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
    if (self.notes && self.notes.recordId > -1) return DL_CHECK_TEXT_GOTO;
    return DL_CHECK_TEXT_EXPAND;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
    [self drawText:self.name rect:rect skinManager:skinManager fontBook:fontBook];
}


-(void)determineIcons:(VBSkinManager *)skinManager
{
    if (self.notes == nil)
        self.iconCheck = [skinManager imageForName:@"cont_note_closed"];
    else if (self.hasChild)
        self.iconCheck = [skinManager imageForName:@"cont_folder"];
    else
        self.iconCheck = [skinManager imageForName:@"cont_note_open"];
    self.iconExpand = [skinManager imageForName:@"cont_expand_icon"];
    self.iconGoto = [skinManager imageForName:@"cont_goto_icon"];
    
    [self releaseIconsForLayout:[self determineLayout]];
}


@end
