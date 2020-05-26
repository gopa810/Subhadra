//
//  VCContent.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "ContentTableController.h"
#import "CIBase.h"
#import "CIModel.h"
#import "VBFolioStorage.h"
#import "VBMainServant.h"
#import "CIBookmarks.h"
#import "VBContentManager.h"
#import "ContentTableCell.h"
#import "ContentTableItemView.h"
#import "CIPlaylist.h"
#import "CIViewsRecord.h"
#import "GetUserStringDialog.h"
#import "SelectUserStringDialog.h"

int g_uimenu_visible = 0;

@implementation ContentTableController

#pragma mark -
#pragma mark View lifecycle

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyFolioOpen
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyBookmarksListChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyNotesListChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyHighlightersListChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:UIMenuControllerDidHideMenuNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:UIMenuControllerDidShowMenuNotification
                                                   object:nil];
        
        VBFolio * folio = [[VBMainServant instance] currentFolio];
        itemBookmarks = [[CIBookmarks alloc] init];
        itemBookmarks.folio = folio;
        itemHighlighters = [[CIHighlights alloc] init];
        itemHighlighters.folio = folio;
        itemNotes = [[CINotes alloc] init];
        itemNotes.folio = folio;
        lastContentDecoratorsToken = 1000;
        
        self.startingRecord = 0;
        self.editMenuActionsData = [[NSMutableDictionary alloc] init];
        self.pagePositions = [NSMutableDictionary new];
        self.lastPageLoaded = @"root";

    }
    
    return self;
}

-(void)viewDidLoad {
    
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: NSSelectorFromString(@"handleLongPress:")];
    
    [self.view addGestureRecognizer:self.longPressRecognizer];
}


-(void)reloadItems
{
    [self loadItems:self.lastPageLoaded];
}

#pragma mark -
#pragma mark content management


-(void)refreshHighlightersContentList:(BOOL)updateShadow
{
    if ([self.lastPageLoaded isEqualToString:@"highlighters"])
    {
        [self loadItems:self.lastPageLoaded];
    }
    if (updateShadow)
        [[[VBMainServant instance] currentFolio] saveShadow];
}

-(void)refreshNotesContentList:(BOOL)updateShadow
{
    if ([self.lastPageLoaded isEqualToString:@"notes"])
    {
        [self loadItems:self.lastPageLoaded];
    }
    if (updateShadow)
        [[[VBMainServant instance] currentFolio] saveShadow];

}

-(void)notificationReceived:(NSNotification *)aNote
{
    if ([aNote.name isEqualToString:kNotifyFolioOpen])
    {
        [self setFolio:[aNote.userInfo objectForKey:@"folio"]];
    }
    else if ([aNote.name isEqualToString:kNotifyHighlightersListChanged])
    {
        [self refreshHighlightersContentList:YES];
    }
    else if ([aNote.name isEqualToString:kNotifyNotesListChanged])
    {
        [self refreshNotesContentList:YES];
    }
    else if ([aNote.name isEqualToString:kNotifyBookmarksListChanged])
    {
        if ([self.lastPageLoaded isEqualToString:@"bookmarks"])
        {
            [self reloadItems];
        }
        [[[VBMainServant instance] currentFolio] saveShadow];
    }
    else if ([aNote.name isEqualToString:UIMenuControllerDidShowMenuNotification])
    {
        g_uimenu_visible = 1;
    }
    else if ([aNote.name isEqualToString:UIMenuControllerDidHideMenuNotification])
    {
        g_uimenu_visible = 0;
        //NSLog(@"UIMenuControllerDidHideMenuNotification");
    }

}

+(BOOL)isEditmenuVisible
{
    return (g_uimenu_visible > 0);
}

-(void)setFolio:(VBFolio *)folio
{
    // find page for record self.startingRecord
    NSString * startPage = [self.contentManager findPageForRecord:self.startingRecord];
    [self loadItems:startPage];

    [self performSelector:@selector(sendContentNotification:) withObject:nil afterDelay:0];
}

-(void)reloadStartPage
{
    // find page for record self.startingRecord
    NSString * startPage = [self.contentManager findPageForRecord:self.startingRecord];
    [self loadItems:startPage];
}

-(NSString *)normalizePageDesc:(NSString *)pageDesc
{
    if ([pageDesc isEqualToString:@"root"])
        return @"page:0";
    return pageDesc;
}

-(void)loadItems:(NSString *)pageDesc
{
    NSLog(@"LOAD ITEMS: %@", pageDesc);
    NSIndexPath * ip = [self.tableView indexPathForRowAtPoint:CGPointMake(self.tableView.frame.size.width/2, self.tableView.contentOffset.y + 1)];
    if (self.lastPageLoaded != nil)
    {
        [self.pagePositions setValue:[NSNumber numberWithInteger:ip.row] forKey:[self normalizePageDesc:self.lastPageLoaded]];
    }
    //NSLog(@"curr index path row %d, page %@", (int)ip.row, self.lastPageLoaded);
    
    self.lastPageLoaded = pageDesc;
    contItems = [[NSMutableArray alloc] initWithArray:[self.contentManager itemsForContentPage:pageDesc onlyContent:NO]];

    [self.tableView reloadData];
    
    NSNumber * n = [self.pagePositions valueForKey:[self normalizePageDesc:pageDesc]];
    //NSLog(@"restore path row %d, page %@", (int)[n intValue], self.lastPageLoaded);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[n integerValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)resetScrollPosition
{
    if (contItems.count > 0)
    {
        NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
        //[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [self.tableView scrollToRowAtIndexPath:path
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:TRUE];
    }
}

-(NSUInteger)currentContentDecoratorsToken
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    int bkmkPos;
    int notePos;
    int highPos;
    
    bkmkPos = [(NSString *)[userDefaults valueForKey:@"cont_bkmk_pos"] intValue];
    notePos = [(NSString *)[userDefaults valueForKey:@"cont_note_pos"] intValue];
    highPos = [(NSString *)[userDefaults valueForKey:@"cont_highs_pos"] intValue];
    
    return bkmkPos*3 + notePos*9 + highPos*27;
}

-(void)sendContentNotification:(id)sender
{
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [contItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	static NSString *CellIdentifier = @"ContCell";

	CIBase * cellData;
    
    cellData = (CIBase *)[contItems objectAtIndex:indexPath.row];

	ContentTableCell * tableCell = (ContentTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tableCell == nil)
    {
        tableCell = [[ContentTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier skinManager:self.userInterfaceManager.skinManager];
        
        tableCell.specView.skinManager = self.userInterfaceManager.skinManager;
        tableCell.specView.userInterfaceManager = self.userInterfaceManager;
        tableCell.specView.tableController = self;
    }

    tableCell.specView.indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
    tableCell.specView.itemIndex = indexPath.row;
    [tableCell.specView setNeedsDisplay];
    tableCell.data = cellData;
    cellData.cell = tableCell;
    
    if (cellData)
    {
        tableCell.backgroundColor = [cellData backgroundColor:self.userInterfaceManager.skinManager];
    }
    else
    {
        tableCell.backgroundColor = [VBMainServant colorForName:@"bodyBackground"];
    }

    return tableCell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CIBase * tableItem = [contItems objectAtIndex:indexPath.item];
    
    return [tableItem calculateHeightForWidth:(tableView.bounds.size.width * 5) / 6
                                     fontBook:[ContentTableItemView fontBook]];
    
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    itemNotes = nil;//[itemNotes release];
    itemHighlighters = nil;//[itemHighlighters release];
    itemBookmarks = nil;//[itemBookmarks release];
    
    //[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}



#pragma mark -
#pragma mark Content Interactions functions

-(void)contentTableCell:(ContentTableItemView *)cell touchedPart:(int)part
{
    if ([cell.data isKindOfClass:[CIModel class]])
    {
        switch(((CIModel *)cell.data).nodeType)
        {
            case 1: part = DP_GOTO; break;
            case 2: part = DP_EXPAND; break;
            default: part = DP_EXPAND; break;
        }
    }
    
    if (part == DP_CHECK)
    {
        NSInteger status = NSOffState;
        if (cell.data.selected != NSOnState)
            status = NSOnState;
        cell.data.selected = (int)status;
        cell.data.iconsValid = NO;
        //[cell.data determineIcons:self.userInterfaceManager.skinManager];
        //CHECK[cell.data.folioContentItem propagateNewStatusToParent:status];
        //CHECK[cell.data.folioContentItem propagateStatusToChildren:status];
//        [cell setNeedsDisplay];
        [self.tableView reloadData];
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:cell.indexPath]
//                              withRowAnimation:UITableViewRowAnimationFade];
        //NSLog(@"touched check, new status is %d", (int)cell.data.selected);
    }
    else if (part == DP_GOTO)
    {
        [self navigateToText:cell.data];
    }
    else if (part == DP_TEXT)
    {
        NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"cs_item_action"];

        if (action == 1)
        {
            if (cell.data.hasChild)
            {
                [self loadItems:cell.data.pageDesc];
            }
            else
            {
                [self navigateToText:cell.data];
            }
        }
    }
    else if (part == DP_EXPAND)
    {
        if (cell.data.hasChild)
        {
            [self loadItems:cell.data.pageDesc];
        }
    }
}

-(void)navigateToText:(CIBase *)item
{
    if ([item isKindOfClass:[CIBack class]])
    {
        [self loadItems:item.pageDesc];
    }
    else if ([item isKindOfClass:[CIModel class]])
    {
        CIModel * contentItem = (CIModel *)item;
        [self displayGlobalRecord:contentItem.recordId];
    }
    else if ([item isKindOfClass:[CIBookmarks class]])
    {
        CIBookmarks * A = (CIBookmarks *)item;
        [self displayGlobalRecord:A.bookmark.recordId];
    }
    else if ([item isKindOfClass:[CIHighlights class]])
    {
        CIHighlights * H = (CIHighlights *)item;
        [self displayGlobalRecord:H.notes.recordId];
    }
    else if ([item isKindOfClass:[CINotes class]])
    {
        CINotes * N = (CINotes *)item;
        [self displayGlobalRecord:N.notes.recordId];
    }
    else if ([item isKindOfClass:[CIPlaylist class]])
    {
        CIPlaylist * P = (CIPlaylist *)item;
        [self.userInterfaceManager playPlaylist:P.playlist];
    }
    else if ([item isKindOfClass:[CIViewsRecord class]])
    {
        CIViewsRecord * V = (CIViewsRecord *)item;
        [V.views loadRecords];
        [self.userInterfaceManager showViewRecords:V.views.records
                                             title:V.views.title];
    }
}

-(void)loadParentIfPossible
{
    for (CIBase * item in contItems) {
        if ([item isKindOfClass:[CIBack class]])
        {
            [self navigateToText:item];
            break;
        }
    }
}

-(void)displayGlobalRecord:(uint32_t)recordId
{
    [self.contentPageDelegate contentPage:self.parent showTextRecord:recordId];
    [self.contentPageDelegate contentPage:self.parent shouldHide:YES];
}




#pragma mark -
#pragma mark Edit Menu functionality

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        return ([self.editMenuActionsData valueForKey:@"copy"] != nil);
    }
    
    if (action == @selector(performEditMenuShow:))
    {
        return ([self.editMenuActionsData valueForKey:@"show"] != nil);
    }
    
    if (action == @selector(performEditMenuRemove:))
    {
        // we need just name of item (for alert dialog)
        // and that is in key "copy"
        return ([self.editMenuActionsData valueForKey:@"copy"] != nil);
    }
    
    if (action == @selector(performEditMenuExpand:))
        return ([self.editMenuActionsData valueForKey:@"pageDesc"] != nil);
    if (action == @selector(performEditMenuNavigateItem:))
        return ([self.editMenuActionsData valueForKey:@"navigateItem"] != nil);
    if (action == @selector(performEditMenuCreateFolder:))
        return ([self.editMenuActionsData valueForKey:@"folder_owner"] != nil);
    if (action == @selector(performEditMenuMoveTo:))
        return YES;
    
    return NO;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)performEditMenuShow:(id)sender
{
    NSNumber * data = [self.editMenuActionsData valueForKey:@"show"];
    [self displayGlobalRecord:[data intValue]];
}

-(void)performEditMenuNavigateItem:(id)sender
{
    CIViewsRecord * item = [self.editMenuActionsData valueForKey:@"navigateItem"];
    [self navigateToText:item];
}

-(void)performEditMenuExpand:(id)sender
{
    NSString * pageDesc = [self.editMenuActionsData valueForKey:@"pageDesc"];
    [self loadItems:pageDesc];
}

-(void)performEditMenuCreateFolder:(id)sender
{
    GetUserStringDialog * dlg = [[GetUserStringDialog alloc] initWithNibName:@"GetUserStringDialog" bundle:nil];
    
    dlg.delegate = self.userInterfaceManager;
    dlg.callbackDelegate = self;
    dlg.tag = @"NEW_FOLDER";
    [dlg setTitle:[self.editMenuActionsData valueForKey:@"dlgTitle"]
         subtitle:[self.editMenuActionsData valueForKey:@"dlgSubtitle"]];
    dlg.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self.editMenuActionsData valueForKey:@"folder_owner"], @"FOLDER_OWNER", [self.editMenuActionsData valueForKey:@"folder_type"], @"FOLDER_TYPE", nil];
    
    [dlg openDialog];
}

-(void)performEditMenuMoveTo:(id)sender
{
    SelectUserStringDialog * dlg = [[SelectUserStringDialog alloc] initWithNibName:@"SelectUserStringDialog" bundle:nil];
    dlg.delegate = self.userInterfaceManager;
    dlg.callbackDelegate = self;
    dlg.tag = @"MOVE_TO";

    VBFolio * folio = [[VBMainServant instance] currentFolio];
    NSInteger exceptFolder = -1;
    NSMutableArray * strings = [NSMutableArray new];
    NSString * folderType = [self.editMenuActionsData valueForKey:@"folder_type"];
    if ([folderType isEqualToString:@"bookmarks"])
    {
        CIBookmarks * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
        if (ci.bookmark && ci.bookmark.recordId == -1)
            exceptFolder = ci.bookmark.ID;
        NSArray * array = folio.firstStorage.p_bookmarks;
        VBBookmark * root = [VBBookmark new];
        root.ID = -1;
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"[general bookmarks]", @"TEXT", root, @"ITEM", [NSNumber numberWithInt:0], @"INDENT", nil];
        [strings addObject:dict];

        [self insertBookmarkDicts:strings indent:1 bookmarks:array parent:-1 except:exceptFolder];
    }
    else if ([folderType isEqualToString:@"highs"])
    {
        CIHighlights * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
        if (ci.notes && ci.notes.recordId == -1)
            exceptFolder = ci.notes.ID;
        NSArray * array = folio.firstStorage.p_recordNotes;
        VBRecordNotes * root = [VBRecordNotes new];
        root.ID = -1;
        root.highlightedText = @"[general notes]";
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:root.highlightedText, @"TEXT", root, @"ITEM", [NSNumber numberWithInt:0], @"INDENT", nil];
        [strings addObject:dict];
        [self insertHightextDicts:strings indent:1 notes:array parent:-1 except:exceptFolder];
    }
    else if ([folderType isEqualToString:@"notes"])
    {
        CINotes * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
        if (ci.notes && ci.notes.recordId == -1)
            exceptFolder = ci.notes.ID;
        NSArray * array = folio.firstStorage.p_recordNotes;
        VBRecordNotes * root = [VBRecordNotes new];
        root.ID = -1;
        root.highlightedText = @"[general notes]";
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:root.highlightedText, @"TEXT", root, @"ITEM", [NSNumber numberWithInt:0], @"INDENT", nil];
        [strings addObject:dict];
        [self insertNotesDicts:strings indent:1 notes:array parent:-1 except:exceptFolder];
    }
    dlg.strings = strings;
    dlg.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self.editMenuActionsData valueForKey:@"folder_owner"], @"FOLDER_OWNER", [self.editMenuActionsData valueForKey:@"folder_type"], @"FOLDER_TYPE", nil];
    
    [dlg openDialog];
    [dlg setDialogTitle:[self.editMenuActionsData valueForKey:@"dlgTitleMove"]];
}

-(void)insertBookmarkDicts:(NSMutableArray *)arr indent:(int)indentLevel bookmarks:(NSArray *)bkmks parent:(NSInteger)parentId except:(NSInteger)ef
{
    for(VBBookmark * vb in bkmks)
    {
        if (vb.parentId == parentId && vb.recordId == -1 && vb.ID != ef)
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:vb.name, @"TEXT", vb, @"ITEM", [NSNumber numberWithInt:indentLevel], @"INDENT", nil];
            [arr addObject:dict];
            [self insertBookmarkDicts:arr indent:indentLevel + 1 bookmarks:bkmks parent:vb.ID except:ef];
        }
    }
}

-(void)insertHightextDicts:(NSMutableArray *)arr indent:(int)indentLevel notes:(NSArray *)bkmks parent:(NSInteger)parentId except:(NSInteger)ef
{
    for(VBRecordNotes * vb in bkmks)
    {
        if (vb.parentId == parentId && vb.recordId == -1 && vb.ID != ef && vb.highlightedText.length > 0)
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:vb.highlightedText, @"TEXT", vb, @"ITEM", [NSNumber numberWithInt:indentLevel], @"INDENT", nil];
            [arr addObject:dict];
            [self insertHightextDicts:arr indent:indentLevel + 1 notes:bkmks parent:vb.ID except:ef];
        }
    }
}

-(void)insertNotesDicts:(NSMutableArray *)arr indent:(int)indentLevel notes:(NSArray *)bkmks parent:(NSInteger)parentId except:(NSInteger)ef
{
    for(VBRecordNotes * vb in bkmks)
    {
        if (vb.noteParentID == parentId && vb.recordId == -1 && vb.ID != ef && vb.noteText.length > 0)
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:vb.noteText, @"TEXT", vb, @"ITEM", [NSNumber numberWithInt:indentLevel], @"INDENT", nil];
            [arr addObject:dict];
            [self insertNotesDicts:arr indent:indentLevel + 1 notes:bkmks parent:vb.ID except:ef];
        }
    }
}

-(void)copy:(id)sender
{
    NSString * text = [self.editMenuActionsData valueForKey:@"copy"];
    NSData * data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSDictionary * newPasteboardContent = [NSDictionary dictionaryWithObject:data
                                                                      forKey:@"public.text"];
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
}

-(void)performEditMenuRemove:(id)sender
{
    NSString * name = [self.editMenuActionsData valueForKey:@"copy"];
    if ([name length] > 40) {
        name = [[name substringToIndex:39] stringByAppendingString:@"..."];
    }
    /*UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to remove item with name '%@'?", name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [alert show];*/
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to remove item with name '%@'?", name] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        CIBase * itemToRemove = [self.editMenuActionsData valueForKey:@"contentItemBase"];
        // remove
        if (itemToRemove != nil)
        {
            VBFolio * currentFolio = [VBMainServant.instance currentFolio];
            if ([itemToRemove class] == [CIHighlights class])
            {
                CIHighlights * highItem = (CIHighlights *)itemToRemove;
                if (highItem.notes != nil)
                {
                    [highItem.notes removeAllAnchors];
                    NSMutableArray * arr = [NSMutableArray new];
                    [currentFolio getAllHightextChildren:highItem.notes.ID array:arr];
                    for (VBRecordNotes * nt in arr)
                    {
                        [nt removeAllAnchors];
                    }
                    [currentFolio removeUnusedRecordNotes];
                    [self reloadItems];
                }
            }
            else if ([itemToRemove class] == [CINotes class])
            {
                CINotes * noteItem = (CINotes *)(itemToRemove);
                if (noteItem.notes != nil)
                {
                    noteItem.notes.noteText = @"";
                    NSMutableArray * arr = [NSMutableArray new];
                    [currentFolio getAllNotesChildren:noteItem.notes.ID array:arr];
                    for (VBRecordNotes * nt in arr)
                    {
                        [nt setNoteText:@""];
                    }
                    [currentFolio removeUnusedRecordNotes];
                    [self reloadItems];
                }
            }
            else if ([itemToRemove class] == [CIBookmarks class])
            {
                CIBookmarks * bookmarkItem = (CIBookmarks *)itemToRemove;
                if (bookmarkItem.bookmark != nil)
                {
                    [currentFolio removeBookmarkWithId:bookmarkItem.bookmark.ID];
                    [self reloadItems];
                }
            }
        }
        [alert dismissViewControllerAnimated:YES completion:^{ }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // just cancel
        [alert dismissViewControllerAnimated:YES completion:^{ }];
    }]];

    [self presentViewController:alert animated:YES completion:^{  }];
}

-(void)handleLongPressFromItem:(CIBase *)item
                    recognizer:(UILongPressGestureRecognizer *)recognizer
{
    NSMutableArray * menuItems = [[NSMutableArray alloc] init];
    CGPoint point = [recognizer locationInView:self.view];
    
    [self.editMenuActionsData removeAllObjects];
    [self.editMenuActionsData setValue:item forKey:@"contentItemBase"];
    
    if ([item isKindOfClass:[CIBack class]])
    {
    }
    else if ([item isKindOfClass:[CIModel class]])
    {
        // show record action
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Show" action:@selector(performEditMenuShow:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        
        CIModel * contentItem = (CIModel *)item;
        [self.editMenuActionsData setValue:[NSNumber numberWithInt:contentItem.recordId] forKey:@"show"];
        [self.editMenuActionsData setValue:contentItem.name forKey:@"copy"];
        if (contentItem.hasChild)
            [self.editMenuActionsData setValue:contentItem.pageDesc forKey:@"pageDesc"];
        
    }
    else if ([item isKindOfClass:[CIBookmarks class]])
    {
        CIBookmarks * A = (CIBookmarks *)item;
        if (A.iconGoto)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Show" action:@selector(performEditMenuShow:)]];
        if (A.iconExpand)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Move To" action:@selector(performEditMenuMoveTo:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Create Folder" action:@selector(performEditMenuCreateFolder:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(performEditMenuRemove:)]];
        
        if (A.bookmark != nil)
            [self.editMenuActionsData setValue:[NSNumber numberWithInt:A.bookmark.recordId] forKey:@"show"];
        [self.editMenuActionsData setValue:A.bookmark.name forKey:@"copy"];
        if (A.hasChild)
            [self.editMenuActionsData setValue:A.pageDesc forKey:@"pageDesc"];
        [self.editMenuActionsData setValue:[NSNumber numberWithInteger:A.bookmark.parentId] forKey:@"folder_owner"];
        [self.editMenuActionsData setValue:@"bookmarks" forKey:@"folder_type"];
        [self.editMenuActionsData setValue:@"Create Bookmarks Folder" forKey:@"dlgTitle"];
        [self.editMenuActionsData setValue:@"Enter title for new bookmarks folder" forKey:@"dlgSubtitle"];
        [self.editMenuActionsData setValue:@"Select Bookmarks Folder" forKey:@"dlgTitleMove"];
    }
    else if ([item isKindOfClass:[CIViewsRecord class]])
    {
        CIViewsRecord * A = (CIViewsRecord *)item;
        
        if (A.iconGoto)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Show" action:@selector(performEditMenuNavigateItem:)]];
        if (A.iconExpand)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        
        [self.editMenuActionsData setValue:A.views.title forKey:@"copy"];
        if (A.hasChild)
            [self.editMenuActionsData setValue:A.pageDesc forKey:@"pageDesc"];
        else
            [self.editMenuActionsData setValue:A forKey:@"navigateItem"];
        
    }
    else if ([item isKindOfClass:[CIPlaylist class]])
    {
        CIPlaylist * A = (CIPlaylist *)item;
        if (A.iconGoto)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Play" action:@selector(performEditMenuNavigateItem:)]];
        if (A.iconExpand)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        
        [self.editMenuActionsData setValue:A.playlist.title forKey:@"copy"];
        if (A.hasChild)
            [self.editMenuActionsData setValue:A.pageDesc forKey:@"pageDesc"];
        if (A.iconGoto)
            [self.editMenuActionsData setValue:A forKey:@"navigateItem"];
        
    }
    else if ([item isKindOfClass:[CIHighlights class]])
    {
        CIHighlights * H = (CIHighlights *)item;
        if (H.iconGoto)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Show" action:@selector(performEditMenuShow:)]];
        if (H.iconExpand)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Move To" action:@selector(performEditMenuMoveTo:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(performEditMenuRemove:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Create Folder" action:@selector(performEditMenuCreateFolder:)]];
        
        if (H.notes != nil && H.notes.recordId > 0)
            [self.editMenuActionsData setValue:[NSNumber numberWithInt:H.notes.recordId] forKey:@"show"];
        [self.editMenuActionsData setValue:H.notes.highlightedText forKey:@"copy"];
        if (H.hasChild)
            [self.editMenuActionsData setValue:H.pageDesc forKey:@"pageDesc"];
        [self.editMenuActionsData setValue:[NSNumber numberWithInteger:H.notes.parentId] forKey:@"folder_owner"];
        [self.editMenuActionsData setValue:@"highs" forKey:@"folder_type"];
        [self.editMenuActionsData setValue:@"Create Folder" forKey:@"dlgTitle"];
        [self.editMenuActionsData setValue:@"Enter title for new folder" forKey:@"dlgSubtitle"];
        [self.editMenuActionsData setValue:@"Select Folder" forKey:@"dlgTitleMove"];
    }
    else if ([item isKindOfClass:[CINotes class]])
    {
        CINotes * N = (CINotes *)item;
        if (N.iconGoto)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Show" action:@selector(performEditMenuShow:)]];
        if (N.iconExpand)
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Expand" action:@selector(performEditMenuExpand:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Move To" action:@selector(performEditMenuMoveTo:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Create Folder" action:@selector(performEditMenuCreateFolder:)]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(performEditMenuRemove:)]];
        
        if (N.notes != nil && N.notes.recordId > 0)
            [self.editMenuActionsData setValue:[NSNumber numberWithInt:N.notes.recordId] forKey:@"show"];
        [self.editMenuActionsData setValue:N.notes.noteText forKey:@"copy"];
        if (N.hasChild)
            [self.editMenuActionsData setValue:N.pageDesc forKey:@"pageDesc"];
        [self.editMenuActionsData setValue:[NSNumber numberWithInteger:N.notes.parentId] forKey:@"folder_owner"];
        [self.editMenuActionsData setValue:@"notes" forKey:@"folder_type"];
        [self.editMenuActionsData setValue:@"Create Folder" forKey:@"dlgTitle"];
        [self.editMenuActionsData setValue:@"Enter title for new folder" forKey:@"dlgSubtitle"];
        [self.editMenuActionsData setValue:@"Select Folder" forKey:@"dlgTitleMove"];
    }
    
    if (menuItems.count > 0)
    {
        [self becomeFirstResponder];
        UIMenuController * theMenu = [UIMenuController sharedMenuController];
        [theMenu setTargetRect:CGRectMake(point.x - 20, point.y - 20, 40, 40) inView:self.view];
        theMenu.menuItems = menuItems;
        [theMenu setMenuVisible:YES animated:YES];
    }
}

//
// simulates clicking on text area
// and activating either action "go to text" or "expand item"
//
-(void)activateCellAtPoint:(CGPoint)point
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath)
    {
        if (indexPath.row >= 0 && indexPath.row < contItems.count)
        {
            ContentTableCell * cell = (ContentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//            CIBase * cell = [contItems objectAtIndex:indexPath.row];
            if (cell.data.hasChild)
            {
                [self loadItems:cell.data.pageDesc];
            }
            else
            {
                [self navigateToText:cell.data];
            }
        }
    }
}

-(void)userHasEnteredString:(NSString *)str inDialog:(NSString *)tag userInfo:(NSDictionary *)userInfo
{
    if ([tag isEqualToString:@"NEW_FOLDER"])
    {
        NSString * folderType = [userInfo valueForKey:@"FOLDER_TYPE"];
        NSNumber * folderOwner = [userInfo valueForKey:@"FOLDER_OWNER"];
        NSString * folderName = str;
        
        VBFolio * folio = [[VBMainServant instance] currentFolio];
        if ([folderType isEqualToString:@"bookmarks"])
        {
            VBBookmark * vb = [VBBookmark new];
            vb.name = folderName;
            vb.recordId = -1;
            
            [folio addBookmark:vb toFolder:[folderOwner integerValue]];
            
            [folio saveShadow];
            
            [self reloadItems];
        }
        else if ([folderType isEqualToString:@"highs"])
        {
            VBRecordNotes * rn = [VBRecordNotes new];
            rn.highlightedText = folderName;
            rn.recordId = -1;
            
            [folio addRecordNote:rn toFolder:[folderOwner integerValue]];
            [folio saveShadow];

            [self reloadItems];
        }
        else if ([folderType isEqualToString:@"notes"])
        {
            VBRecordNotes * rn = [VBRecordNotes new];
            rn.noteText = folderName;
            rn.recordId = -1;
            
            [folio addRecordNote:rn toFolder:[folderOwner integerValue]];
            [folio saveShadow];
            
            [self reloadItems];
        }
    }
}

-(void)userHasSelectedItem:(NSDictionary *)item inDialog:(NSString *)tag userInfo:(NSDictionary *)userInfo
{
    if ([tag isEqualToString:@"MOVE_TO"])
    {
        NSString * folderType = [userInfo valueForKey:@"FOLDER_TYPE"];

        VBFolio * folio = [[VBMainServant instance] currentFolio];
        if ([folderType isEqualToString:@"bookmarks"])
        {
            CIBookmarks * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
            
            VBBookmark * selectedFolder = [item valueForKey:@"ITEM"];
            ci.bookmark.parentId = selectedFolder.ID;
            
            [folio saveShadow];
            
            [self reloadItems];
        }
        else if ([folderType isEqualToString:@"highs"])
        {
            CIHighlights * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
            VBRecordNotes * selectedFodler = [item valueForKey:@"ITEM"];
            ci.notes.parentId = selectedFodler.ID;
            
            [folio saveShadow];
            
            [self reloadItems];
        }
        else if ([folderType isEqualToString:@"notes"])
        {
            CINotes * ci = [self.editMenuActionsData valueForKey:@"contentItemBase"];
            VBRecordNotes * selectedFodler = [item valueForKey:@"ITEM"];
            ci.notes.noteParentID = selectedFodler.ID;
            
            [folio saveShadow];
            
            [self reloadItems];
        }
    }
}

-(NSString *)substringFrom:(NSString *)source UpTo:(NSString *)sep
{
    NSRange index = [source rangeOfString:sep];
    if (index.location == NSNotFound)
        return source;
    
    return [source substringToIndex:index.location];
}

-(NSString *)substringFrom:(NSString *)source after:(NSString *)sep
{
    NSRange index = [source rangeOfString:sep];
    if (index.location == NSNotFound)
        return source;
    
    return [source substringFromIndex:(index.location + index.length)];
}



-(void)executeAction:(NSString *)text
{
    NSLog(@"Executing Action in ContentTableController:");
    NSLog(@"ACTION = %@", text);
    NSString * rem = text, *cmd = nil;
    
    cmd = [self substringFrom:rem UpTo:@" "];
    rem = [self substringFrom:rem after:@" "];
    
    if ([cmd isEqualToString:@"load"])
    {
        cmd = [self substringFrom:rem UpTo:@" "];
        rem = [self substringFrom:rem after:@" "];

        [self loadItems:cmd];
    }
    else if ([cmd isEqualToString:@"show"])
    {
        cmd = [self substringFrom:rem UpTo:@" "];
        rem = [self substringFrom:rem after:@" "];
        
        if ([cmd isEqualToString:@"appmap"])
        {
            [self loadItems:cmd];
        }
        else if ([cmd isEqualToString:@"mwdict"])
        {
            [self.userInterfaceManager showDictionary];
        }
        else if ([cmd isEqualToString:@"text"])
        {
            if (self.contentPageDelegate && [self.contentPageDelegate respondsToSelector:@selector(contentPage:shouldHide:)])
            {
                [self.contentPageDelegate contentPage:self.userInterfaceManager.contentBarController
                                           shouldHide:YES];
            }
        }
        else if ([cmd isEqualToString:@"search"])
        {
            [self.userInterfaceManager showSearch];
        }
    }
}


@end

