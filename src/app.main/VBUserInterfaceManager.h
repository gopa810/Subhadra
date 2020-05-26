//
//  VBUserInterfaceManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 14/07/14.
//
//

#import <Foundation/Foundation.h>
#import "BottomBarViewDelegate.h"
#import "BottomBarViewController.h"
#import "VCHitsDelegate.h"
#import "ContentPageDelegate.h"
#import "TGTouchArea.h"
#import "EndlessTextViewDelegate.h"
#import "ETVDirectSource.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "GetUserStringDelegate.h"
#import "FDDrawingProperties.h"

@class VBAudioControllerDialog;
@class VCHits2;
@class EndlessScrollView;
@class ContentPageController, ShowNoteViewController, EditNoteDialogController;
@class BookmarksEditorDialog, GetUserStringDialog, HighlighterSelectionDialog;
@class VBMainServant, VBPlaylist;
@class EndlessTextView;
@class VCText, DictionaryViewController;
@class VBSearchManager, VBContentManager;
@class VBSkinManager, VBTextHistoryManager, TextStyleViewController;

@interface VBUserInterfaceManager : UIViewController<BottomBarViewDelegate,VCHitsDelegate,ContentPageDelegate,UIGestureRecognizerDelegate,TGTabBarTouches,EndlessTextViewDelegate,AVAudioPlayerDelegate,GetUserStringDelegate,UIScrollViewDelegate>

@property (retain,nonatomic) IBOutlet VBMainServant * mainServant;
@property (weak) IBOutlet UIWindow * window;
@property IBOutlet FDDrawingProperties * drawer;
@property AVAudioPlayer * audioPlayer;
@property VBPlaylist * currentPlaylist;
@property NSString * currentPlayObject;

// text layer views
@property UIScreenEdgePanGestureRecognizer * bottomEdgePan;

@property (weak) IBOutlet UIView * textLayer;
@property IBOutlet EndlessScrollView * textView2;
@property IBOutlet UILabel * titlePathLabel;
@property (weak) IBOutlet TGTouchArea * pageDownButton;
@property (weak) IBOutlet TGTouchArea * pageUpButton;
@property (weak) IBOutlet TGTouchArea * rightHistoryArrow;
@property (weak) IBOutlet TGTouchArea * leftHistoryArrow;
//@property (weak) IBOutlet TGTouchArea * rightHistoryUnderShadow;
//@property (weak) IBOutlet TGTouchArea * leftHistoryUnderShadow;
@property (weak) IBOutlet VBSearchManager * searchManager;
@property IBOutlet VBSkinManager * skinManager;
@property IBOutlet VBTextHistoryManager * textHistoryManager;
@property IBOutlet VBContentManager * contentManager;
@property IBOutlet UIView * waitPane;
//@property VCText * textController;
@property ETVDirectSource * folioSource;
@property int userInteractedRecordId;

// bottom bar
@property BottomBarViewController * bottomBarController;

// content bar
@property ContentPageController * contentBarController;

// search bar
@property VCHits2 * searchBarController;

// hit navogation bar
@property IBOutlet UIView * hitNavigationBar;
@property IBOutlet TGTouchArea * hitPrevButton;
@property IBOutlet TGTouchArea * hitNextButton;


// bookmarks bar
@property BookmarksEditorDialog * bookmarksController;
@property GetUserStringDialog * bookmarksAddNew;

// test style settings bar
@property TextStyleViewController * textSettingsController;

// dialogs
@property ShowNoteViewController * showNoteController;
@property EditNoteDialogController * editNoteController;
@property HighlighterSelectionDialog * highlighterDialogController;
@property VBAudioControllerDialog * audioControllerDialog;
@property DictionaryViewController * dictionaryViewController;

-(void)validateHistoryButtons;
-(void)createUserInterface;
-(void)insertViewController:(UIViewController *)controller
                   fromSide:(CGSize)orientation;
-(void)insertViewController:(UIViewController *)controller
                   withDiff:(CGFloat)ratio;
-(void)removeViewController:(UIViewController *)controller
                     toSide:(CGSize)side
                       name:(NSString *)name;
-(void)removeViewController:(UIViewController *)controller
                   withDiff:(CGFloat)side
                       name:(NSString *)name;
-(void)loadRecord:(NSUInteger)globalRecordId useHighlighting:(BOOL)bUseHigh;
-(void)loadRecord:(NSUInteger)globalRecordId useHighlighting:(BOOL)bUseHigh textOffset:(float)offset;

-(void)showPopupWithHtmlText:(NSString *)htmlText;
-(void)displayTextWithRequest:(NSURL *)url;

-(void)setNeedsUpdateHighlightPhrases;
-(void)setNeedsDisplayText;
-(void)showViewRecords:(NSArray *)recs title:(NSString *)title;
-(void)playPlaylist:(VBPlaylist *)pid;

-(void)saveUIState;
-(void)restoreUIState;
-(void)runSound;
-(void)stopSound;
-(void)runSoundPrevious;

-(void)didReceiveMemoryWarning;
-(void)showContent;
-(void)showSearch;
-(void)showTextSettings;
-(void)showDictionary;

-(int)currentRecordId;

-(IBAction)toogleFullScreen:(id)sender;

@end
