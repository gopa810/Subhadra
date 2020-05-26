//
//  VBUserInterfaceManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 14/07/14.
//
//

#import "VBUserInterfaceManager.h"
#import "TGTabController.h"
#import "ContentPageController.h"
#import "VCText.h"
#import "VCHits2.h"
//#import "StoreViewController.h"
#import "VBMainServant.h"
#import "BottomBarViewController.h"
#import "BottomBarItem.h"
#import "ContentPageController.h"
#import "VCHits2.h"
#import "BookmarksEditorDialog.h"
#import "EndlessTextView.h"
#import "VBTextHistoryManager.h"
#import "TextStyleViewController.h"
#import "EditNoteDialogController.h"
#import "GetUserStringDialog.h"
#import "HighlighterSelectionDialog.h"
#import "VBSearchManager.h"
#import "VBContentManager.h"
#import "ShowViewRecordsController.h"
#import "VBPlaylist.h"
#import "VBAudioControllerDialog.h"
#import "DictionaryViewController.h"
#import "VCHelpMainViewController.h"
#import "EndlessScrollView.h"
#import "VBEditMenu.h"
#import "ContentTableItemView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VBUserInterfaceManager

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"---here-- ");
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateUserInterface:nil];
    [super viewWillAppear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInterface:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

-(void)bottomBar:(BottomBarViewController *)controller selectedItem:(BottomBarItem *)item
{
}

-(void)updateUserInterface:(NSNotification *)aNotification
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSInteger opacity = [ud integerForKey:@"ts_bit"];
    
    opacity = [ud integerForKey:@"ts_pudit"];
    if (opacity == 0)
    {
        self.pageDownButton.hidden = YES;
        self.pageUpButton.hidden = YES;
    }
    else
    {
        self.pageDownButton.alpha = opacity / 100.0;
        self.pageUpButton.alpha = opacity / 100.0;
        self.pageDownButton.hidden = NO;
        self.pageUpButton.hidden = NO;
    }
    [self.pageDownButton setNeedsDisplay];
    [self.pageUpButton setNeedsDisplay];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


-(void)createAdditionalTestViews:(id)sender
{
    //[self showBottomBar];
    //[self showContent];
    NSLog(@"-- create Additional views");
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];

    if ([ud integerForKey:@"welcomeHelpVersionShowed"] != 6)
    {
        VCHelpMainViewController * help = [[VCHelpMainViewController alloc] initWithNibName:@"VCHelpMainViewController" bundle:nil];
        
        help.delegate = self;
        [help openDialog];
     
        [ud setInteger:6 forKey:@"welcomeHelpVersionShowed"];
        [ud synchronize];
    }
    
}

-(void)validateHistoryButtons
{
    BOOL value = ! [self.textView2 canGoBack];
	self.leftHistoryArrow.hidden = value;
    //self.leftHistoryUnderShadow.hidden = value;
    
    value = ! [self.textView2 canGoForward];
	self.rightHistoryArrow.hidden = value;
    //self.rightHistoryUnderShadow.hidden = value;
}

-(void)setNeedsDisplayText
{
    [self.folioSource.folio.firstStorage invalidateRecordWidths];
    [self.textView2 rearrangeForOrientation];
}

#pragma mark -
#pragma mark Callbacks from side views

-(void)showWindowForKey:(NSString *)item
{
    if ([item isEqualToString:@"content"]) {
        [self showContent];
    } else if ([item isEqualToString:@"search"]) {
        [self showSearch];
    } else if ([item isEqualToString:@"bookmarks"]) {
        [self showBookmarks];
    } else if ([item isEqualToString:@"textsettings"]) {
        [self showTextSettings];
    } else if ([item isEqualToString:@"dictionary"]) {
        [self showDictionary];
    } else if ([item isEqualToString:@"hightext"]) {
        [self showHightexts];
    } else if ([item isEqualToString:@"notes"]) {
        [self showNotes];
    }
}

-(void)hitsBar:(VCHits2 *)controller shouldHide:(BOOL)hide
{
    [self removeViewController:controller toSide:CGSizeMake(-50, 0) name:@"DissappearSearchBar"];
}

-(void)contentPage:(ContentPageController *)controller shouldHide:(BOOL)hide
{
    [self removeViewController:controller toSide:CGSizeMake(50, 0) name:@"DissappearContentBar"];
}

-(void)contentPage:(ContentPageController *)controller showTextRecord:(int)recordId
{
    [self loadRecord:recordId useHighlighting:NO];
    [self validateHistoryButtons];
}

-(void)onTabButtonPressed:(id)sender
{
    TGTouchArea * area = (TGTouchArea *)sender;
    if ([area.touchCommand isEqualToString:@"textHistoryForward"])
    {
        area.backgroundColor = [UIColor lightGrayColor];
    }
    else if ([area.touchCommand isEqualToString:@"textHistoryBackward"])
    {
        area.backgroundColor = [UIColor lightGrayColor];
    }
    else if ([area.touchCommand isEqualToString:@"pageDown"])
    {
        [self.textView2 pageDown:self.textView2.frame.size.height-15];
    }
    else if ([area.touchCommand isEqualToString:@"pageUp"])
    {
        [self.textView2 pageUp:self.textView2.frame.size.height-15];
    }
    else if ([area.touchCommand isEqualToString:@"hitPrev"])
    {
        [self.searchBarController navigateToPrevRecord];
    }
    else if ([area.touchCommand isEqualToString:@"hitNext"])
    {
        [self.searchBarController navigateToNextRecord];
    }
}

-(void)onTabButtonReleased:(id)sender
{
    TGTouchArea * area = (TGTouchArea *)sender;
    if ([area.touchCommand isEqualToString:@"textHistoryForward"])
    {
        [self onGoForward:self];
    }
    else if ([area.touchCommand isEqualToString:@"textHistoryBackward"])
    {
        [self onGoBack:self];
    }
    area.backgroundColor = [UIColor clearColor];
}

-(void)onTabButtonReleasedOut:(id)sender
{
    TGTouchArea * area = (TGTouchArea *)sender;
    area.backgroundColor = [UIColor clearColor];
}

-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData
{
    if ([command isEqualToString:@"closeBookmarkView"])
    {
        [self removeViewController:self.bookmarksController toSide:CGSizeMake(0,50) name:command];
    }
    else if ([command isEqualToString:@"refreshRecord"])
    {
        NSNumber * n = [aData valueForKey:@"record"];
        [self.textView2 setNeedsDisplayRecord:[n intValue]];
    }
    else if ([command isEqualToString:@"editNote"])
    {
        NSNumber * recordNum = [aData objectForKey:@"record"];
        self.userInteractedRecordId = [recordNum intValue];
        [self endlessEditNote:self];
    }
    else if ([command isEqualToString:@"highlightText"])
    {
        if ([aData valueForKey:@"highlighterId"])
        {
            NSNumber * highlighterId = [aData valueForKey:@"highlighterId"];
            [self highlightText:[highlighterId intValue]];
            [self.textView2 clearSelection];
        }
    }
}

-(int)currentRecordId
{
    return self.textView2.position.recordId;
}

-(void)highlightText:(int)highlighterId
{
    int iFromCharIndex;
    int iToCharIndex;
    int fromGlobRecId;
    int toGlobRecId;
    
    if ([self.textView2.selection getSelectedRangeOfTextStartRec:&fromGlobRecId
                                  startIndex:&iFromCharIndex
                                      endRec:&toGlobRecId
                                    endIndex:&iToCharIndex])
    {
        NSLog(@"HIGHLIGHTED TEXT\n  FROM RECID: %d\n  FROM CHAR: %d\n  TO RECID: %d\n  TO CHAR: %d",
              fromGlobRecId, iFromCharIndex, toGlobRecId, iToCharIndex);
        VBFolio * currentFolio = [[VBMainServant instance] currentFolio];
        if (fromGlobRecId < toGlobRecId)
        {
            [currentFolio setHighlighter:highlighterId forRecord:fromGlobRecId
                               startChar:iFromCharIndex endChar:10000];
            for(int i = fromGlobRecId + 1; i < toGlobRecId; i++)
            {
                [currentFolio setHighlighter:highlighterId forRecord:i
                                   startChar:0 endChar:10000];
            }
            [currentFolio setHighlighter:highlighterId forRecord:toGlobRecId
                               startChar:0 endChar:iToCharIndex];
        }
        else if (fromGlobRecId == toGlobRecId)
        {
            [currentFolio setHighlighter:highlighterId forRecord:fromGlobRecId
                               startChar:iFromCharIndex endChar:iToCharIndex];
        }
        
        for(int i = fromGlobRecId; i <= toGlobRecId; i++)
        {
            FDRecordBase * rec = [self.folioSource getRawRecord:i];
            [rec setNeedsRecalculate];
        }
    }
    
}

- (void)swipeRightAction:(id)ignored
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSInteger action = [ud integerForKey:@"ts_swipelr_action"];
    if (action == 1) {
        [self showContent];
    } else if (action == 2) {
        [self showBookmarks];
    } else if (action == 3) {
        [self showSearch];
    }
}

- (void)swipeLeftAction:(id)ignored
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSInteger action = [ud integerForKey:@"ts_swiperl_action"];
    if (action == 1) {
        [self showContent];
    } else if (action == 2) {
        [self showBookmarks];
    } else if (action == 3) {
        [self showSearch];
    }
}

#pragma mark -
#pragma mark Creating UI

-(void)showBottomBar
{
    if (self.bottomBarController == nil)
    {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        //-----------------------
        // creating bottom bar
        self.bottomBarController = [[BottomBarViewController alloc] initWithNibName:@"BottomBarViewController" bundle:nil];
        
        self.bottomBarController.backgroundImage = [VBMainServant imageForName:@"dark_papyrus"];
        self.bottomBarController.delegate = self;
        
        BottomBarItem * bbi = [[BottomBarItem alloc] init];
        bbi.icon = [VBMainServant imageForName:@"tab_cont_white"];
        bbi.text = @"Content";
        bbi.tag = @"content";
        [self.bottomBarController addItem:bbi];
        
        bbi = [[BottomBarItem alloc] init];
        bbi.icon = [VBMainServant imageForName:@"tab_search_white"];
        bbi.text = @"Search";
        bbi.tag = @"search";
        [self.bottomBarController addItem:bbi];
        
        if ([userDefaults integerForKey:@"cont_bkmk_pos"] == 3)
        {
            bbi = [[BottomBarItem alloc] init];
            bbi.icon = [VBMainServant imageForName:@"tab_bookmark_white"];
            bbi.text = @"Bookmarks";
            bbi.tag = @"bookmarks";
            [self.bottomBarController addItem:bbi];
        }

        if ([userDefaults integerForKey:@"cont_highs_pos"] == 3)
        {
            bbi = [[BottomBarItem alloc] init];
            bbi.icon = [VBMainServant imageForName:@"tab_hightext_white"];
            bbi.text = @"Highlighted";
            bbi.tag = @"hightext";
            [self.bottomBarController addItem:bbi];
        }

        if ([userDefaults integerForKey:@"cont_note_pos"] == 3)
        {
            bbi = [[BottomBarItem alloc] init];
            bbi.icon = [VBMainServant imageForName:@"tab_note_white"];
            bbi.text = @"Notes";
            bbi.tag = @"notes";
            [self.bottomBarController addItem:bbi];
        }

        bbi = [[BottomBarItem alloc] init];
        bbi.icon = [VBMainServant imageForName:@"tab_dictionary"];
        bbi.text = @"Dictionary";
        bbi.tag = @"dictionary";
        [self.bottomBarController addItem:bbi];
        
        
        bbi = [[BottomBarItem alloc] init];
        bbi.icon = [VBMainServant imageForName:@"tab_textsettings_white"];
        bbi.text = @"Text Settings";
        bbi.tag = @"textsettings";
        [self.bottomBarController addItem:bbi];
        
        // end creating bottom bar
        //------------------------
    }

    [self.textView2 saveCurrentPos];
    NSString * str = [[[VBMainServant instance] currentFolio] findDocumentPath: self.textView2.position.recordId];
    NSLog(@"Current Path Title: %@", str);
    self.bottomBarController.titleBarText = str;
    self.bottomBarController.textHeaderLabel.text = str;
    [self insertViewController:self.bottomBarController withDiff:0];
}

-(void)endlessTextView:(UIView *)textView topRecordChanged:(int)recordId
{
    static int prevrecordId = -1;
    
    if (prevrecordId != recordId)
    {
        prevrecordId = recordId;
        [self actionUpdatePathText:self];
    }
}

-(IBAction)actionUpdatePathText:(id)sender
{
    VBFolio * currentFolio = [[VBMainServant instance] currentFolio];
    self.titlePathLabel.text = [currentFolio findDocumentPath: self.textView2.position.recordId];
}

-(IBAction)actionShowContent:(id)sender
{
    [self showContent];
}

-(IBAction)actionShowSearch:(id)sender
{
    [self showSearch];
}

-(IBAction)actionShowDictionary:(id)sender
{
    ContentPageController * subc1 = [self getContentPage];
    // TODO: not working
    [subc1.tableController executeAction:@"load appmap"];
    [self insertViewController:subc1 fromSide:CGSizeMake(0,0)];
    //[self showDictionary];
}

-(IBAction)actionShowtextlayout:(id)sender
{
    [self showTextSettings];
}

-(ContentPageController *)getContentPage
{
    if (self.contentBarController == nil)
    {
        ContentPageController * subc1 = nil;
        subc1 = [[ContentPageController alloc] initWithNibName:@"ContentPageController" bundle:nil];
        subc1.delegate = self;
        subc1.contentManager = self.contentManager;
        subc1.userInterfaceManager = self;
        [subc1 setFolio:self.mainServant.currentFolio];
        self.contentBarController = subc1;
    }
    
    return self.contentBarController;
}

-(void)showContent
{
    ContentPageController * subc1 = [self getContentPage];

    // test if content is loaded
    // if not, then load content page 0
    if (![subc1.contentManager.lastPageType isEqualToString:@"contents"])
        [subc1.tableController loadItems:@"page:0"];
   
    [self insertViewController:self.contentBarController fromSide:CGSizeMake(0,0)];
}

-(void)showSearch
{
    if (self.searchBarController == nil)
    {
        VCHits2 * subc3 = [[VCHits2 alloc] initWithNibName:@"VCHits2" bundle:nil];
        subc3.delegate = self;
        subc3.userInterfaceManager = self;
        subc3.skinManager = self.skinManager;
        subc3.searchManager = self.searchManager;
        [subc3 setFolio: self.mainServant.currentFolio];
        self.searchBarController = subc3;
    }

    [self insertViewController:self.searchBarController fromSide:CGSizeMake(0,0)];
}

-(void)showBookmarks
{
    ContentPageController * subc1 = [self getContentPage];
    [subc1.tableController loadItems:@"bookmarks"];
    [self insertViewController:subc1 fromSide:CGSizeMake(0,0)];
    
}

-(void)showHightexts
{
    ContentPageController * subc1 = [self getContentPage];
    [subc1.tableController loadItems:@"highlighters"];
    [self insertViewController:subc1 fromSide:CGSizeMake(0,0)];
}

-(void)showNotes
{
    ContentPageController * subc1 = [self getContentPage];
    [subc1.tableController loadItems:@"notes"];
    [self insertViewController:subc1 fromSide:CGSizeMake(0,0)];
    
}

-(void)showTextSettings
{
    if (self.textSettingsController == nil)
    {
        TextStyleViewController * viewController = [[TextStyleViewController alloc] initWithNibName:@"TextStyleViewController" bundle:nil];
        viewController.userInterfaceManager = self;
        
        self.textSettingsController = viewController;
    }
    
    [self insertViewController:self.textSettingsController fromSide:CGSizeMake(0, 0)];
}

-(void)showViewRecords:(NSArray *)recs title:(NSString *)title
{
    ShowViewRecordsController * dlg = [[ShowViewRecordsController alloc] initWithNibName:@"ShowViewRecordsController" bundle:nil delegate:self];
    
    ETVRecords * source = [[ETVRecords alloc] init];
    source.records = recs;
    source.folio = [[VBMainServant instance] currentFolio];
    dlg.source = source;
    
    [dlg openDialog];
    [dlg showDialog];
    
    dlg.titleLabel.text = title;
    [dlg setCurrentRecord:0];
    
}

-(void)showDictionary
{
    if (self.dictionaryViewController == nil)
    {
        self.dictionaryViewController = [[DictionaryViewController alloc] initWithNibName:@"DictionaryViewController" bundle:nil];
        
        self.dictionaryViewController.delegate = self;
        self.dictionaryViewController.skinManager = self.skinManager;

        [self.dictionaryViewController openDialog];
    }
}

-(void)playPlaylist:(VBPlaylist *)playlist
{

    self.currentPlaylist = playlist;

    [self runSound];
}

-(void)stopSound
{
    [self.currentPlaylist gotoEnd];
    [self runSound];
}

-(void)runSoundPrevious
{
    [self.currentPlaylist back];
    [self.currentPlaylist back];
    [self runSound];
}

-(void)runSound
{
    NSLog(@"audiPlayer before %p", self.audioPlayer);
    if (self.audioPlayer != nil)
    {
        [self.audioPlayer stop];
    }

    NSData * data = nil;
    NSString * object = [self.currentPlaylist nextObject];
    if (object != nil)
    {
        data = [self.folioSource findObject:object];
    }

    if (data != nil)
    {
        self.currentPlayObject = object;
        AVAudioPlayer * new_player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
        self.audioPlayer = new_player;
        self.audioPlayer.delegate = self;
        if ([self.audioPlayer play] == NO)
        {
            NSLog(@"unsuccess");
        }
        NSLog(@"#2 audioPlayer is : %p", new_player);
    }
    else
    {
        self.currentPlaylist = nil;
    }

    [self showAudioControllerView:(data != nil)];
}

- (void)audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) completed
{
    if (completed == YES) {
        [self runSound];
    }
}

-(void)showAudioControllerView:(BOOL)show
{
    if (show)
    {
        if (self.audioControllerDialog == nil)
        {
            self.audioControllerDialog = [[VBAudioControllerDialog alloc] initWithNibName:@"VBAudioControllerDialog" bundle:nil];
            self.audioControllerDialog.skinManager = self.skinManager;
            self.audioControllerDialog.userInterfaceManager = self;
            self.audioControllerDialog.delegate = self;
            
            CGRect frame = [[self view] frame];
            UIView * mainView = self.audioControllerDialog.view;
            CGRect backFrame = CGRectMake(0, 0, 100, 72);
            if ([[mainView subviews] count] > 0)
            {
                UIView * subView = [[mainView subviews] objectAtIndex:0];
                backFrame = [subView bounds];
            }
            frame.origin.y = frame.size.height - backFrame.size.height;
            frame.size.height = backFrame.size.height;
            CGRect frameSrc = frame;
            frameSrc.origin.y += backFrame.size.height;
            [self insertViewController:self.audioControllerDialog sourceRect:frameSrc targetRect:frame];
            self.audioControllerDialog.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//            [self.audioControllerDialog openDialog];
        }
    }
    else
    {
        if (self.audioControllerDialog != nil)
        {
            [self.audioControllerDialog hideDialog];
            [self.audioControllerDialog closeDialog];
            self.audioControllerDialog = nil;
        }
    }
}

-(void)displayTextWithRequest:(NSURL *)url
{
    NSArray * arr = [url pathComponents];
    NSString * type = [arr objectAtIndex:1];
    NSString * objectName = [FlatFileUtils decodeLinkSafeString:[arr objectAtIndex:2]];

    if ([type isEqualToString:@"WW"])
    {
        objectName = arr[2];
    }
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:type, @"TYPE", objectName, @"LINK", [NSNumber numberWithInt:0], @"RECORDID", [NSValue valueWithCGPoint:CGPointMake(100, 100)], @"POINT", nil];
    
    [self endlessTextView:self.textView2 navigateLink:dict];
}

-(void)endlessTextViewTapWithoutSelection:(UIView *)textView
{
    [self toogleFullScreen:self];
}

-(void)endlessShowBuiltinDictionary:(id)sender
{
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"word"]) {
        UIReferenceLibraryViewController* ref = [[UIReferenceLibraryViewController alloc] initWithTerm:@"word"];
        [self presentViewController:ref animated:YES completion:nil];
    }
}

-(void)endlessShowInContents:(id)sender
{
    [self showContent];

    self.contentBarController.tableController.startingRecord = self.userInteractedRecordId;
    [self.contentBarController.tableController reloadStartPage];
}

-(void)endlessShowInBookmarks:(id)sender
{
    [self showBookmarks];
    
//    self.contentBarController.tableController.startingRecord = self.userInteractedRecordId;
//    [self.contentBarController.tableController reloadStartPage];
}

-(void)endlessShowViewsTranslations:(id)sender
{
    [self endlessShowViews:@"Translations"];
}

-(void)endlessShowViewsVerses:(id)sender
{
    [self endlessShowViews:@"Verses"];
}

-(void)endlessShowViewsTranslationsVerses:(id)sender
{
    [self endlessShowViews:@"Verses & Translations"];
}

-(void)endlessShowViews:(NSString *)tag
{
    NSMutableArray * arr = [NSMutableArray new];
    [arr addObject:tag];
    [self.contentManager fillPath:arr forRecord:self.userInteractedRecordId];
    
    NSString * viewPage = [self.contentManager findViewFromPath:arr];
    
    [self showContent];
    
    [self.contentBarController.tableController loadItems:viewPage];
}

-(void)endlessShowNote:(id)sender
{
    NSString * str = [self.folioSource.folio htmlTextForNoteRecord:self.userInteractedRecordId];
    
    if (self.showNoteController == nil)
    {
        self.showNoteController = [[ShowNoteViewController alloc] initWithNibName:@"ShowNoteViewController" bundle:nil];
        self.showNoteController.delegate = self;
    }
    
    [self.showNoteController openDialog];
    [self.showNoteController showDialog];
    [self.showNoteController setNoteRecordId:self.userInteractedRecordId];
    [self.showNoteController.popupWebView loadHTMLString:str baseURL:[VBMainServant fakeURL]];
}

-(void)endlessEditNote:(id)sender
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];
    
    VBRecordNotes * noterec = [folio.firstStorage createNoteForRecord:self.userInteractedRecordId];
    if ([noterec.recordPath length] == 0)
    {
        noterec.recordPath = [folio.firstStorage findDocumentPath:self.userInteractedRecordId];
    }
    
    if (self.editNoteController == nil)
    {
        EditNoteDialogController * editNoteDlg = [[EditNoteDialogController alloc] initWithNibName:@"EditNoteDialogController" bundle:nil];
        
        editNoteDlg.delegate = self;
        self.editNoteController = editNoteDlg;
    }

    self.editNoteController.selectedObject = noterec;
    self.editNoteController.globalRecordID = self.userInteractedRecordId;
    
    [self.editNoteController openDialog];
    [self.editNoteController showDialog];
}

-(void)endlessAddBookmark:(id)sender
{
    if (self.bookmarksAddNew == nil)
    {
        GetUserStringDialog * dlg = [[GetUserStringDialog alloc] initWithNibName:@"GetUserStringDialog" bundle:nil];
        dlg.delegate = self;
        dlg.callbackDelegate = self;
        self.bookmarksAddNew = dlg;
    }

    self.bookmarksAddNew.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.userInteractedRecordId], @"RECORDID", nil];
    self.bookmarksAddNew.tag = @"ADD_BOOKMARK";
    [self.bookmarksAddNew openDialog];
}

-(void)userHasEnteredString:(NSString *)str inDialog:(NSString *)tag userInfo:(NSDictionary *)userInfo
{
    if ([tag isEqualToString:@"ADD_BOOKMARK"])
    {
        VBFolio * folio = [[VBMainServant instance] currentFolio];
        VBBookmark * bk = [folio bookmarkWithName:str];
        if (bk)
        {
            bk.recordId = [(NSNumber *)[userInfo valueForKey:@"RECORDID"] intValue];
            bk.createDate = [NSDate date];
        }
        else
        {
            [folio saveBookmark:str recordId:[(NSNumber *)[userInfo valueForKey:@"RECORDID"] intValue]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBookmarksListChanged object:nil];
        
        //[self executeTouchCommand:@"refreshRecord" data:nil];
    }
}

-(void)endlessUpdateBookmark:(id)sender
{
    if (self.bookmarksController == nil)
    {
        self.bookmarksController = [[BookmarksEditorDialog alloc] initWithNibName:@"BookmarksEditorDialog" bundle:nil mode:2];
        self.bookmarksController.delegate = self;
        [self.bookmarksController setTransitionDifference:-80];
    }
    
    self.bookmarksController.recordId = self.userInteractedRecordId;
    [self.bookmarksController openDialog];
}

-(void)setNeedsUpdateHighlightPhrases
{
    VBFolioStorage * fs = [[[VBMainServant instance] currentFolio] firstStorage];
    
    [fs setNeedsUpdateHighlightPhrases];
}

-(void)setHighlighterPhrases:(BOOL)bUse
{
    if (bUse)
    {
        self.drawer.highlightPhrases = [[FDTextHighlighter alloc] initWithPhraseSet: self.searchManager.phrases];
    }
    else
    {
        if (self.drawer.highlightPhrases)
        {
            [self setNeedsUpdateHighlightPhrases];
            self.drawer.highlightPhrases = nil;
        }
    }
}

-(void)loadRecord:(NSUInteger)globalRecordId useHighlighting:(BOOL)bUseHigh
{
    [self loadRecord:globalRecordId useHighlighting:bUseHigh textOffset:0];
}

-(void)loadRecord:(NSUInteger)globalRecordId useHighlighting:(BOOL)bUseHigh textOffset:(float)offset
{
    [self setHighlighterPhrases:bUseHigh];
    self.hitNavigationBar.hidden = !bUseHigh;
    [self.textView2 setCurrentRecord:(int)globalRecordId offset:offset];
    [self validateHistoryButtons];
}

-(IBAction)onGoBack:(id)sender
{
    [self.textView2 goBack];
    [self validateHistoryButtons];
}

-(IBAction)onGoForward:(id)sender
{
    [self.textView2 goForward];
    [self validateHistoryButtons];
}

-(void)copy:(id)sender
{
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    /*NSArray * types = paste.pasteboardTypes;
    for(NSString * s in types)
    {
        if ([s compare:@"public.text"] == NSOrderedSame)
        {
            NSData * data = [[self.textView getSelectedText:NO] dataUsingEncoding:NSUTF8StringEncoding];
            [newPasteboardContent setObject:data forKey:@"public.text"];
        }
    }*/
    NSData * data = [[self.textView2 getSelectedText:NO] dataUsingEncoding:NSUTF8StringEncoding];
    [newPasteboardContent setObject:data forKey:@"public.text"];
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
}

-(void)endlessCopyWithRef:(id)sender
{
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    /*NSArray * types = paste.pasteboardTypes;
     for(NSString * s in types)
     {
     if ([s compare:@"public.text"] == NSOrderedSame)
     {
     NSData * data = [[self.textView getSelectedText:YES] dataUsingEncoding:NSUTF8StringEncoding];
     [newPasteboardContent setObject:data forKey:@"public.text"];
     }
     }*/
    
    NSData * data = [[self.textView2 getSelectedText:YES] dataUsingEncoding:NSUTF8StringEncoding];
    [newPasteboardContent setObject:data forKey:@"public.text"];
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
    
}

-(void)speakAction:(id)sender
{
   
    NSString * textToSpeach = [self.textView2 getSelectedText:NO];
    
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ī" withString:@"ee"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"Ī" withString:@"ee"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ā" withString:@"aa"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"Ā" withString:@"aa"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ṣ" withString:@"sh"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ś" withString:@"sh"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ḥ" withString:@"h"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ṇ" withString:@"n"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ṅ" withString:@"n"];
    textToSpeach = [textToSpeach stringByReplacingOccurrencesOfString:@"ṁ" withString:@"m"];
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:textToSpeach];
    
    [utterance setRate:0.4f];
    [synthesizer speakUtterance:utterance];
    
    
}


-(void)highlighterAction:(id)sender
{
    if (self.highlighterDialogController == nil)
    {
        HighlighterSelectionDialog * sel = [[HighlighterSelectionDialog alloc] initWithNibName:@"HighlighterSelectionDialog" bundle:nil];
        sel.delegate = self;
        self.highlighterDialogController = sel;
    }
    
    [self.highlighterDialogController openDialog];
    [self.highlighterDialogController showDialog];
}


-(void)showPopupWithHtmlText:(NSString *)htmlText
{
    if (self.showNoteController == nil)
    {
        self.showNoteController = [[ShowNoteViewController alloc] initWithNibName:@"ShowNoteViewController" bundle:nil];
        self.showNoteController.delegate = self;
    }
    
    //ShowNoteViewController * vc = self.showNoteController;
    [self.showNoteController openDialog];
    [self.showNoteController showDialog];
    [self.showNoteController.popupWebView loadHTMLString:htmlText
                                                 baseURL:[VBMainServant fakeURL]];
}

-(void)onErrorUnreachableDestination:(NSString *)dest
{
    NSString * messageText = [NSString stringWithFormat:@"Target of this link is not available, because it is in different folio package which you did not load. Unavailable target: %@", dest];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Trying to reach another package?" message:messageText preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(void)createUserInterface
{
    self.window.rootViewController = self;

    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    UIDeviceOrientation devOrient = [[UIDevice currentDevice] orientation];
    double d = [user doubleForKey:(UIDeviceOrientationIsLandscape(devOrient) ? @"EndlessMarginsLandscape" : @"EndlessMargins")];
    if (d > 8)
    {
        self.drawer.paddingLeft = d;
        self.drawer.paddingRight = d;
    }
    
    self.pageDownButton.touchCommand = @"pageDown";
    self.pageDownButton.backgroundImage = [VBMainServant imageForName:@"page_down"];
    self.pageDownButton.backgroundImageSize = CGSizeMake(48, 48);
    self.pageDownButton.backgroundColor = [UIColor clearColor];

    self.pageUpButton.touchCommand = @"pageUp";
    self.pageUpButton.backgroundImage = [VBMainServant imageForName:@"page_up"];
    self.pageUpButton.backgroundImageSize = CGSizeMake(48, 48);
    self.pageUpButton.backgroundColor = [UIColor clearColor];

    self.hitPrevButton.touchCommand = @"hitPrev";
    self.hitPrevButton.backgroundImage = [VBMainServant imageForName:@"hit_prev"];
    self.hitPrevButton.backgroundImageSize = CGSizeMake(48,48);
    self.hitPrevButton.backgroundColor = [UIColor clearColor];
    
    self.hitNextButton.touchCommand = @"hitNext";
    self.hitNextButton.backgroundImage = [VBMainServant imageForName:@"hit_next"];
    self.hitNextButton.backgroundImageSize = CGSizeMake(48,48);
    self.hitNextButton.backgroundColor = [UIColor clearColor];
    
    self.hitNavigationBar.backgroundColor = [UIColor clearColor];
    self.hitNavigationBar.hidden = YES;
    
    UIColor * backgroundYellow = [VBMainServant colorForName:@"bodyBackground"];

    ETVDirectSource * ds = [[ETVDirectSource alloc] init];
    ds.folio = [[VBMainServant instance] currentFolio];
    
    self.folioSource = ds;
    
    self.textView2.dataSource = ds;
    self.textView2.delegate = self;
    [self.textView2 setSkin: self.skinManager];
    self.textView2.backgroundColor = backgroundYellow;
    self.textView2.drawer = self.drawer;

    
    self.rightHistoryArrow.backgroundImage = [VBMainServant imageForName:@"hdr_fwd_2"];
    self.rightHistoryArrow.touchCommand = @"textHistoryForward";
    self.leftHistoryArrow.backgroundImage = [VBMainServant imageForName:@"hdr_back_2"];
    self.leftHistoryArrow.touchCommand = @"textHistoryBackward";

    /*
    UIView * tempView1;
    
    tempView1 = [self.window viewWithTag:120];
    tempView1.backgroundColor = backgroundYellow;
    
    tempView1 = [self.window viewWithTag:200];
    tempView1.backgroundColor = backgroundYellow;
    
    UIView * centralView = [tempView1 viewWithTag:220];
    
    UIButton * button = nil;
    
    for(int tag = 230; tag <= 260; tag+=10)
    {
        button = (UIButton *)[centralView viewWithTag:tag];
        [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor brownColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor brownColor] forState:UIControlStateFocused];
    }
    */
    
    [self validateHistoryButtons];

    [self createAdditionalTestViews:self];
    
    return;
}


#pragma mark -
#pragma mark View Hierarchy Management

-(IBAction)toogleFullScreen:(id)sender
{
    UIView * tempView1;
    
    tempView1 = [self.window viewWithTag:120];
    tempView1.hidden = !tempView1.hidden;
    
    tempView1 = [self.window viewWithTag:200];
    tempView1.hidden = !tempView1.hidden;
}

-(void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void)stop
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:UIDeviceOrientationDidChangeNotification]) {
        [self deviceDidChangeOrientation:[UIDevice.currentDevice orientation]];
    }
}


-(void)deviceDidChangeOrientation:(UIDeviceOrientation)deviceOrientation
{
    NSString * key = @"EndlessMargins";
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        key = @"EndlessMarginsLandscape";
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    CGFloat margins = [user doubleForKey:key];
    self.drawer.paddingLeft = margins;
    self.drawer.paddingRight = margins;
    [self.textView2 rearrangeForOrientation];
    [VBEditMenu hide];
}

/*******************************************************
 * returns current frame for current device orientation
 *******************************************************/

-(CGRect)currentFrame
{
    UIDeviceOrientation dor = [[UIDevice currentDevice] orientation];
    CGRect main = [[UIScreen mainScreen] bounds];
    CGRect ret;

    if (dor == UIDeviceOrientationLandscapeLeft
        || dor == UIDeviceOrientationLandscapeRight)
    {
        ret = CGRectMake(0, 0, main.size.height, main.size.width);
    }
    else
    {
        ret = CGRectMake(0, 0, main.size.width, main.size.height);
    }
    
    return ret;
}

/**********************************************************************************
 * inserts given controller into current window with
 * animation like view is comming from specified side
 *
 * side:  CGSizeMake(0, 20)   : this will move view up from 20% of view height
 *        CGSizeMake(0, -15)  : this will move view down from 15% of view height
 *
 **********************************************************************************/

-(void)insertViewController:(UIViewController *)controller fromSide:(CGSize)orientation
{
    CGRect targetRect = self.view.frame;// [self currentFrame];//self.view.frame;
    NSLog(@"(%f,%f,%f,%f)", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
    
    CGRect sourceRect = CGRectMake(targetRect.origin.x - orientation.width / 100.0 * targetRect.size.width, targetRect.origin.y - orientation.height / 100.0 * targetRect.size.height, targetRect.size.width, targetRect.size.height);
    
    [self insertViewController:controller sourceRect:sourceRect targetRect:targetRect];
}

-(void)insertViewController:(UIViewController *)controller withDiff:(CGFloat)ratio
{
    CGRect targetRect = self.view.frame;//[self currentFrame];//self.view.frame;
    NSLog(@"(%f,%f,%f,%f)", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
    
    CGRect sourceRect = CGRectMake(targetRect.origin.x - ratio, targetRect.origin.y - ratio, targetRect.size.width + 2 * ratio, targetRect.size.height + 2 * ratio);

    [self insertViewController:controller sourceRect:sourceRect targetRect:targetRect];
}

-(void)insertViewController:(UIViewController *)controller sourceRect:(CGRect)sourceRect targetRect:(CGRect)targetRect
{
    controller.view.frame = sourceRect;
    controller.view.alpha = 0.0;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if (self.audioControllerDialog != nil && self.audioControllerDialog != controller)
    {
        [self.view insertSubview:controller.view belowSubview:self.audioControllerDialog.view];
    }
    else
    {
        [self.view addSubview:controller.view];
    }
    [self addChildViewController:controller];
    
    [UIView beginAnimations:@"inset" context:nil];
    [UIView setAnimationDuration:0.1];
    
    controller.view.frame = targetRect;
    controller.view.alpha = 1.0;
    
    
    [UIView commitAnimations];
}

/*********************************************************************************
 * this will remove given view controller from current view hierarchy
 * with animation effect on alpha channel and frame
 * argument <name> is important, because due to this we will know
 * in function animationDidStop...
 * which controller disappeared
 *********************************************************************************/

-(void)removeViewController:(UIViewController *)controller toSide:(CGSize)side name:(NSString *)name
{
    CGRect targetRect = [self currentFrame];//self.view.frame;
    CGRect sourceRect = CGRectMake(targetRect.origin.x - side.width / 100.0 * targetRect.size.width, targetRect.origin.y - side.height / 100.0 * targetRect.size.height, targetRect.size.width, targetRect.size.height);
    

    [self removeViewController:controller sourceRect:sourceRect targetRect:targetRect name:name];
}

-(void)removeViewController:(UIViewController *)controller withDiff:(CGFloat)side name:(NSString *)name
{
    CGRect targetRect = [self currentFrame];//self.view.frame;
    CGRect sourceRect = CGRectMake(targetRect.origin.x - side, targetRect.origin.y - side, targetRect.size.width + 2*side, targetRect.size.height + 2*side);
    
    [self removeViewController:controller sourceRect:sourceRect targetRect:targetRect name:name];
}

-(void)removeViewController:(UIViewController *)controller sourceRect:(CGRect)sourceRect targetRect:(CGRect)targetRect name:(NSString *)name
{
    //controller.view.frame = sourceRect;
    controller.view.alpha = 1.0;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [UIView beginAnimations:@"name" context:(__bridge void *)(controller)];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    controller.view.frame = targetRect;
    controller.view.alpha = 0.0;
    
    
    [UIView commitAnimations];
}

/*************************************************************************
 * actual removing view and controller from view hierarchy
 * for this we need to have valid animationID which is argument <name>
 * for function removeViewController:toSide:name:
 *************************************************************************/

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    id controller = (__bridge id)context;
    
    if ([controller isKindOfClass:[UIViewController class]])
    {
        UIViewController * vc = (UIViewController *)controller;
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        
        if (vc == self.dictionaryViewController)
        {
            self.dictionaryViewController = nil;
        }
    }
    else if ([animationID isEqualToString:@"DisappearBottomBar"])
    {
        [self.bottomBarController.view removeFromSuperview];
        [self.bottomBarController removeFromParentViewController];
    }
    else if ([animationID isEqualToString:@"DissappearSearchBar"])
    {
        [self.searchBarController.view removeFromSuperview];
        [self.searchBarController removeFromParentViewController];
    }
    else if ([animationID isEqualToString:@"DissappearContentBar"])
    {
        [self.contentBarController.view removeFromSuperview];
        [self.contentBarController removeFromParentViewController];
    }
    else if ([animationID isEqualToString:@"closeBookmarkView"])
    {
        [self.bookmarksController.view removeFromSuperview];
        [self.bookmarksController removeFromParentViewController];
    }
    
}



-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(endlessShowNote:))
    {
        return [self.folioSource recordHasNote:self.userInteractedRecordId]
        && [self.folioSource canHaveNotes];
    }
    if (action == @selector(endlessEditNote:))
        return [self.folioSource canHaveNotes];
    if (action == @selector(endlessAddBookmark:))
        return [self.folioSource canHaveBookmarks];
    if (action == @selector(endlessUpdateBookmark:))
    {
        return ([self.folioSource bookmarksCount] > 0) && [self.folioSource canHaveBookmarks];
    }
    if (action == @selector(endlessShowViewsTranslations:) || action == @selector(endlessShowViewsTranslationsVerses:) || action == @selector(endlessShowViewsVerses:))
    {
        return YES;
    }
    if (action == @selector(endlessShowInContents:) || action == @selector(endlessShowInBookmarks:))
        return YES;
    
    if (action == @selector(copy:))
    {
        return YES;
    }
    if (action == @selector(endlessCopyWithRef:))
    {
        return YES;
    }
    if (action == @selector(highlighterAction:))
    {
        return YES;
    }
    if (action == @selector(speakAction:))
    {
        return YES;
    }
    
    return NO;
}

-(void)endlessTextView:(UIView *)textView rightAreaClicked:(int)recId withRect:(CGRect)rect
{
    [self endlessTextView:textView leftAreaClicked:recId withRect:rect];
}

-(void)endlessTextView:(UIView *)textView rightAreaLongClicked:(int)recId withRect:(CGRect)rect
{
    [self endlessTextView:textView leftAreaClicked:recId withRect:rect];
}

-(void)endlessTextView:(UIView *)textView leftAreaClicked:(int)recId withRect:(CGRect)rect
{
    [self endlessTextView:textView leftAreaLongClicked:recId withRect:rect];

/*    self.userInteractedRecordId = recId;
    
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Show Note" action:@selector(endlessShowNote:)];
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    theMenu.menuItems = [NSArray arrayWithObject:menuItem];
    [theMenu setMenuVisible:YES animated:YES];*/
}

-(void)endlessTextView:(UIView *)textView leftAreaLongClicked:(int)recId withRect:(CGRect)rect
{
    self.userInteractedRecordId = recId;
    [self becomeFirstResponder];

    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"Edit Note"
                                                       action:@selector(endlessEditNote:)];
    UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:@"Add Bookmark"
                                                       action:@selector(endlessAddBookmark:)];
    UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:@"Update Bookmark"
                                                       action:@selector(endlessUpdateBookmark:)];
    UIMenuItem *menuItem5 = [[UIMenuItem alloc] initWithTitle:@"To Contents"
                                                       action:@selector(endlessShowInContents:)];
    UIMenuItem *menuItem6 = [[UIMenuItem alloc] initWithTitle:@"To Bookmarks"
                                                       action:@selector(endlessShowInBookmarks:)];

    VBEditMenu * tMenu = [[VBEditMenu alloc] initWithFrame:self.view.frame];
    tMenu.menuItems = [NSArray arrayWithObjects:menuItem1, menuItem2, menuItem3, menuItem5, menuItem6, nil];
    tMenu.actionTarget = self;
    [tMenu showForRect:rect];
    return;
    
    
    /*UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    theMenu.menuItems = [NSArray arrayWithObjects:menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, nil];
    [theMenu setMenuVisible:YES animated:YES];*/
}

-(void)endlessTextView:(UIView *)textView selectionDidChange:(CGRect)rect
{
    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"Copy Ref"
                                                       action:@selector(endlessCopyWithRef:)];
    UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:@"Highlighter"
                                                       action:@selector(highlighterAction:)];
    UIMenuItem *menuItem5 = [[UIMenuItem alloc] initWithTitle:@"Speak"
                                                       action:@selector(speakAction:)];
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    theMenu.menuItems = [NSArray arrayWithObjects:menuItem1, menuItem4, menuItem5, nil];
    [theMenu setMenuVisible:YES animated:YES];
    //NSLog(@"visible by 1");
}

- (void)endlessJumpToDestination:(NSString *)jumpDestination
{
    int jumpRecordId = [[VBMainServant instance].currentFolio findJumpDestination:jumpDestination];
    if (jumpRecordId <= 0) {
        [self onErrorUnreachableDestination:jumpDestination];
    } else {
        [self loadRecord:jumpRecordId useHighlighting:NO];
    }
    
    [self showWaitNote:nil];
}

-(void)showWaitNote:(id)sender
{
    self.waitPane.hidden = (sender == nil);
    //NSLog(@"show wait note %d", self.waitPane.hidden);
}

-(void)endlessTextView:(UIView *)textView navigateLink:(NSDictionary *)data
{
    NSString * link = [data valueForKey:@"LINK"];
    NSString * type = [data valueForKey:@"TYPE"];
    VBMainServant * servant = [VBMainServant instance];
    NSLog(@"LINK *** %@ *** %@", type, link);
    
    if ([type isEqualToString:@"DL"])
    {
        VBPlaylist * playList = [[VBPlaylist alloc] initWithStorage:self.folioSource.folio.firstStorage objectName:link];
        [self playPlaylist:playList];
    }
    else if ([type isEqualToString:@"ML"])
    {
        NSString * menuCommand = link;
        if ([menuCommand isEqualToString:@"Go Back"])
        {
            [self onGoBack:self];
        }
        else if ([menuCommand isEqualToString:@"EditMenuContents"])
        {
            NSNumber * recordId = [data valueForKey:@"RECORDID"];
            CGPoint point = [(NSValue *)[data valueForKey:@"POINT"] CGPointValue];
            
            self.userInteractedRecordId = [recordId intValue];
            UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"Show Contents"
                                                               action:@selector(endlessShowInContents:)];
            [self becomeFirstResponder];
            UIMenuController * theMenu = [UIMenuController sharedMenuController];
            [theMenu setTargetRect:CGRectMake(point.x - 16, point.y - 16, 32, 32) inView:textView];
            theMenu.menuItems = [NSArray arrayWithObjects:menuItem1, nil];
            [theMenu setMenuVisible:YES animated:YES];
        }
        else if ([menuCommand isEqualToString:@"EditMenuViews"])
        {
            NSNumber * recordId = [data valueForKey:@"RECORDID"];
            CGPoint point = [(NSValue *)[data valueForKey:@"POINT"] CGPointValue];
            
            self.userInteractedRecordId = [recordId intValue];
            NSMutableArray * menuItems = [NSMutableArray new];
            
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Translations"action:@selector(endlessShowViewsTranslations:)]];
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Verses"action:@selector(endlessShowViewsVerses:)]];
            [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"Verses & Translations"action:@selector(endlessShowViewsTranslationsVerses:)]];
            [self becomeFirstResponder];
            UIMenuController * theMenu = [UIMenuController sharedMenuController];
            [theMenu setTargetRect:CGRectMake(point.x - 16, point.y - 16, 32, 32) inView:textView];
            theMenu.menuItems = menuItems;
            [theMenu setMenuVisible:YES animated:YES];
        }
    }
    else if ([type isEqualToString:@"DP"])
    {
        NSArray * pathComponents = [link componentsSeparatedByString:@"/"];
        if ([pathComponents count] > 1) {
            NSString * objectID = [pathComponents objectAtIndex:0];
            NSString * popupNumber = [pathComponents objectAtIndex:1];
            NSString * htmlBody = @"";
            
            htmlBody = [servant.currentFolio htmlTextForPopup:objectID
                                               forPopupNumber:[popupNumber intValue]];
            
            [self showPopupWithHtmlText:htmlBody];
        }
    }
    else if ([type isEqualToString:@"PX"])
	{
		NSString * str = [servant.currentFolio htmlTextForPopup:link];
        [self showPopupWithHtmlText:str];
	}
    else if ([type isEqualToString:@"PW"])
    {
        NSArray * pathComponents = [link componentsSeparatedByString:@"/"];
        if ([pathComponents count] > 1) {
            NSString * objectID = [pathComponents objectAtIndex:0];
            NSString * popupNumber = [pathComponents objectAtIndex:1];
            NSString * htmlBody = @"";
            
            htmlBody = [servant.currentFolio text:[objectID intValue]
                                   forPopupNumber:[popupNumber intValue]];
            
            [self showPopupWithHtmlText:htmlBody];
        }
    }
    else if ([type isEqualToString:@"QL"] || [type isEqualToString:@"EN"])
    {
        [self.showNoteController closeDialog];
        NSString * siksa = link;
        [self showWaitNote:self];
        [self performSelector:@selector(searchFirstRecordAndShow:)
                   withObject:siksa afterDelay:0.1];
    }
    else if ([type isEqualToString:@"JL"])
    {
        [self.showNoteController closeDialog];
        [self showWaitNote:self];
        [self performSelector:@selector(endlessJumpToDestination:)
                   withObject:link afterDelay:0.1];
    }
    else if ([type isEqualToString:@"WW"]) {
        [self.showNoteController closeDialog];
        NSString * urlString = link;
        if (![urlString hasPrefix:@"http://"]) {
            urlString = [NSString stringWithFormat:@"http://%@", urlString];
        }
        NSDictionary * options_d = [NSDictionary dictionary];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:options_d completionHandler:^(BOOL success) {
            // open web completed
        }];
    }
    else {
        NSLog(@"LINK TYPE '%@'is unknown\n", type);
    }
    
}

-(void)endlessTextView:(UIView *)textView swipeRight:(CGPoint)point
{
    [self swipeRightAction:self];
}

-(void)endlessTextView:(UIView *)textView swipeLeft:(CGPoint)point
{
    [self swipeLeftAction:self];
}


-(void)searchFirstRecordAndShow:(NSString *)siksa
{
    VBMainServant * servant = [VBMainServant instance];
    NSInteger firstRecord = [[servant currentFolio] searchFirstRecord:siksa];
    NSLog(@"QL/query : %@", siksa);
    NSLog(@"Result = %ld", (long)firstRecord);
    if (firstRecord != NSNotFound && firstRecord != 0) {
        [self loadRecord:firstRecord useHighlighting:NO];
    } else {
        [self onErrorUnreachableDestination:siksa];
    }
    
    [self showWaitNote:nil];
}

/*****************************************************************************
 * saving and restoring state of windows in user interface
 *****************************************************************************/

-(void)saveUIState
{
    if (self.contentBarController)
    {
        [self.contentBarController saveUIState];
    }
    
    [self.textView2 saveUIState];
}

-(void)restoreUIState
{
    self.bottomBarController = nil;
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    NSInteger textSizeIndex = [settings integerForKey:@"cont_text_size"];
    CGFloat fontSizeNormal = [ContentTableItemView resolveFontSizeFromIndex:textSizeIndex];
    [ContentTableItemView initializeFontBook:fontSizeNormal];

    if (self.contentBarController)
    {
        [self.contentBarController restoreUIState];
    }
    [self.textView2 restoreUIState];
    [self.textView2 restoreTextPosition];
}

/*****************************************************************************
 * releasing all side views
 *****************************************************************************/

-(void)didReceiveMemoryWarning
{
    self.bottomBarController = nil;
    self.searchBarController = nil;
    self.contentBarController = nil;
    self.bookmarksController = nil;
    self.bookmarksAddNew = nil;
    self.showNoteController = nil;
    self.editNoteController = nil;
    self.audioControllerDialog = nil;
    
    [self.searchManager releaseAllRaws];
    NSLog(@"received m.warn in user interface manager");
}


@end
