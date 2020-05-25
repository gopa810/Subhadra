//
//  VCHits2.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VCHits2.h"
#import "ctype.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSAttributedString.h>
#import "VBFindRange.h"
#import "VBFindRangeArray.h"
#import "VBUserColors.h"
#import "VBFolioStorage.h"
#import "CIModel.h"
#import "VBUnicodeToAsciiConverter.h"
#import "VBUnicodeWordMatcher.h"
#import "SearchAdvancedDialog.h"
#import "VBQueryTemplate.h"
#import "VBSearchResultsCollection.h"
#import "SelectQueryTemplateViewController.h"
#import "VBSearchManager.h"
#import "VBSkinManager.h"
#import "ETVRawSource.h"
#import "VBFolioQuery.h"

@implementation VCHits2

@synthesize headerBannerView;
@synthesize folioContent;

#pragma mark -
#pragma mark Initialization

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyFolioOpen object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyFolioContentChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyCmdShowSearchResultsPage object:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        self.lastPinchFontSize = [defaults integerForKey:@"bodySizeSearch"];
        if (self.lastPinchFontSize < 10)
        {
            self.lastPinchFontSize = 14;
            [defaults setInteger:self.lastPinchFontSize forKey:@"bodySizeSearch"];
            [defaults synchronize];
        }
        
        self.lastRecordNavigated = -1;
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.dataSourceType = 0;
    
/*    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [self.textView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [self.textView addGestureRecognizer:swipeLeft];*/
    
    self.progressBanner.hidden = YES;
    
    self.textView.delegate = self;
    self.textView.drawer = [VBMainServant instance].drawer;
    self.textView.dataSource = self.searchManager;
    [self.textView setSkin:self.skinManager];
    //self.textView2.drawLineBeforeRecord = NO;
    //self.textView2.drawRecordNumber = NO;
    //self.textView2.highlightBordersWhenRecordActive = YES;
    self.textView.backgroundColor = [self.skinManager colorForName:@"bodyBackground"];
    self.resultsCountLabel.text = @"No Results";
    self.searchManager.folio = [[VBMainServant instance] currentFolio];
    
    self.headerBannerView.backgroundColor = [self.skinManager colorForName:@"headerBackground"];
    [self.view setBackgroundColor:[UIColor clearColor]];

/*    if (self.textScrollView != nil)
    {
        [self.textView2 setScrollParent:self.textScrollView];
        [self.textScrollView setBackgroundColor:[VBMainServant colorForName:@"darkGradientA"]];
    }*/
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.searchManager.results count] == 0 && self.view.hidden == NO)
    {
        [self performSelector:@selector(buttonClearClicked:) withObject:nil afterDelay:0];
        //[self buttonClearClicked:self];
        //[self loadResultsPage:-1];
    }
}

-(IBAction)onHelpButtonPressed:(id)sender
{
    [self loadResultsPage:-1];
}

- (void)swipeRightAction:(id)ignored
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hitsBar:shouldHide:)])
    {
        [self.delegate hitsBar:self shouldHide:YES];
    }
    
/*    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"use_swipe"])
    {
        //[self.searchText resignFirstResponder];
        [[VBMainServant instance].tabController selectBarItemWithTag:2 direction:TGTabItemTransitionLeftToRight];
    }*/
}

- (void)swipeLeftAction:(id)ignored
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hitsBar:shouldHide:)])
    {
        [self.delegate hitsBar:self shouldHide:YES];
    }

    /*if ([[NSUserDefaults standardUserDefaults] boolForKey:@"use_swipe"])
    {
        //[self.searchText resignFirstResponder];
        [[VBMainServant instance].tabController selectBarItemWithTag:1 direction:TGTabItemTransitionRightToLeft];
    }*/
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

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

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyFolioOpen])
    {
        VBFolio * folio = [note.userInfo objectForKey:@"folio"];
        if (folio)
        {
            [self setFolio:folio];
        }
        self.folioContent = nil;
    }
    else if ([note.name isEqualToString:kNotifyFolioContentChanged])
    {
        self.folioContent = [note.userInfo objectForKey:@"content"];
    }
    else if ([note.name isEqualToString:kNotifyCmdShowSearchResultsPage])
    {
        int requestedPage = [[[note.userInfo objectForKey:@"page"] description] intValue];
        //if (requestedPage != self.activePage)
        [self loadResultsPage:requestedPage];
    }
}

-(void)setFolio:(VBFolio *)folio
{
    [self loadResultsPage:-1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.textView rearrangeForOrientation];
}

#pragma mark -
#pragma mark View Delegates

-(void)searchQueryTextAndShow:(VBUserQuery *)queryText
{
    VBMainServant * servant = [VBMainServant instance];
    //ContentItemModel * folioContent = [servant currentFolioContent];
    
    [servant.currentFolio saveShadow];
    
    [self.searchManager clear];

    BOOL useSel = ([self.searchManager.folio.firstStorage.content selected] == NSMixedState);
    NSString * selectionText = nil;
    if (useSel) {
        selectionText = [VBSearchManager scopeText:queryText.userScope];
        selectionText = [NSString stringWithFormat:@"<AP:18pt><BP:18pt>Search scope<CR><BD+>%@<BD><CR> ", selectionText];
    }
    
    [self.searchManager performSearch:queryText selectedContent:selectionText currentRecord:[servant.userInterfaceManager currentRecordId]];
    
    [self performSelectorOnMainThread:@selector(searchQueryTextAndShowDidFinish)
                           withObject:nil waitUntilDone:NO];
}

-(void)searchQueryTextAndShowDidFinish
{
    [self.userInterfaceManager setNeedsUpdateHighlightPhrases];
    self.textView.drawer.highlightPhrases = [[FDTextHighlighter alloc] initWithPhraseSet:self.searchManager.phrases];
    [self loadResultsPage:0];

    self.progressBanner.hidden = YES;
}

- (IBAction)onButtonQueryTemplate:(id)sender {
    
    SelectQueryTemplateViewController * dlg = [[SelectQueryTemplateViewController alloc] initWithNibName:@"SelectQueryTemplateViewController" bundle:nil];
    
    dlg.delegateSearch = self;
    dlg.delegate = self.userInterfaceManager;
    [dlg setTransitionDifference:-20];
    
    [dlg openDialog];
}

-(void)startQueryUsingTemplate:(VBQueryTemplate *)tpm
{
    SearchAdvancedDialog * dlg = [[SearchAdvancedDialog alloc] initWithNibName:@"SearchAdvancedDialog" bundle:nil template:tpm];
    dlg.delegateSearch = self;
    dlg.searchManager = self.searchManager;
    dlg.folioContent = self.folioContent;
    dlg.delegate = self.userInterfaceManager;
    dlg.mainServant = self.userInterfaceManager.mainServant;
    [dlg setTransitionDifference:-20];
    
    [dlg openDialog];
}

-(IBAction)buttonClearClicked:(id)sender
{
    SearchAdvancedDialog * dlg = [[SearchAdvancedDialog alloc] initWithNibName:@"SearchAdvancedDialog" bundle:nil];
    dlg.delegateSearch = self;
    dlg.delegate = self.userInterfaceManager;
    dlg.searchManager = self.searchManager;
    dlg.folioContent = self.folioContent;
    dlg.mainServant = self.userInterfaceManager.mainServant;
    [dlg setTransitionDifference:-20];
    
    [dlg openDialog];
}

-(IBAction)buttonCloseClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hitsBar:shouldHide:)])
    {
        [self.delegate hitsBar:self shouldHide:YES];
    }
}

-(void)doAction:(NSDictionary *)action
{
    NSString * actionName = [action valueForKey:@"action"];
    if ([actionName isEqualToString:@"search"])
    {
        self.progressBanner.hidden = NO;
        [self performSelectorInBackground:@selector(searchQueryTextAndShow:)
                               withObject:[action valueForKey:@"query"]];
    }
}

-(void)loadResultsPage:(int)nPage
{
    if (self.searchManager.results.count == 0 || nPage < 0) {
        ETVRawSource * raw = [ETVRawSource new];
        //raw.folio = [[VBMainServant instance] currentFolio].firstStorage;
        NSString * helpText = nil;
        if (self.searchManager.lastQuery)
        {
            helpText = @"<BP:36pt><AP:12pt><PT:18pt>No results\n<IT+><PT:10pt>Explain plan for query is as follows:\n<BP:12pt><OB:FO:\"explain_image.png\">\n";
            if (self.searchManager.queries.count > 0)
            {
                VBFolioQueryOperator * oper = [self.searchManager.queries objectAtIndex:0];
                [oper gotoLastRecord];
                UIImage * img = [VBFolioQuery createImageFromQuery:oper];
                [raw.objects setObject:UIImagePNGRepresentation(img) forKey:@"explain_image.png"];
            }
            self.resultsCountLabel.text = @"No results";
        }
        else
        {
            NSString * helpPagePath = [[NSBundle mainBundle] pathForResource:@"SearchExamples" ofType:@"fff"];
            helpText = [NSString stringWithContentsOfFile:helpPagePath
                                                 encoding:NSUTF8StringEncoding error:NULL];
            self.resultsCountLabel.text = @"";
            
        }

        NSArray * arr = [helpText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (NSString * line in arr)
        {
            [raw addFlatText:line];
        }
        
        self.textView.dataSource = raw;
        self.dataSourceType = 0;
        self.textView.delegate = self;
    }
    else
    {
        self.textView.dataSource = self.searchManager;
        self.dataSourceType = 1;
        self.textView.delegate = self;
    }
    
    [self.textView clearRecordViews];
    [self.textView setCurrentRecord:0 offset:0.0];
    [self.textView setNeedsDisplay];

    self.resultsCountLabel.text = [NSString stringWithFormat:@"%d results", (int)self.searchManager.results.count/2];
    self.textView.hidden = NO;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {

    self.progressBanner = nil;
    self.keyboardAccessoryViewController = nil;

}

#pragma mark -
#pragma mark Endless Text View Delegate

-(void)endlessTextView:(UIView *)textView
          navigateLink:(NSDictionary *)data
{
    if (self.dataSourceType == 0)
        return;
    
    NSString * link = [data valueForKey:@"RECORDID"];
    [self navigateToRecord:[link intValue]];
}

-(void)endlessTextView:(UIView *)textView
       paraAreaClicked:(int)recId withRect:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
    [self navigateToRecord:recId];
}

-(void)endlessTextView:(UIView *)textView
       leftAreaClicked:(int)recId
              withRect:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
    [self navigateToRecord:recId];
}

-(void)endlessTextView:(UIView *)textView
   leftAreaLongClicked:(int)recId
              withRect:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
    [self navigateToRecord:recId];
}

-(void)endlessTextView:(UIView *)textView
      rightAreaClicked:(int)recId
              withRect:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
    [self navigateToRecord:recId];
}

-(void)endlessTextView:(UIView *)textView
  rightAreaLongClicked:(int)recId
              withRect:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
    [self navigateToRecord:recId];
}

-(void)endlessTextView:(UIView *)textView
    selectionDidChange:(CGRect)rect
{
    if (self.dataSourceType == 0)
        return;
    
/*    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"Copy Ref"
                                                       action:@selector(endlessCopyWithRef:)];
    UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:@"Highlighter"
                                                       action:@selector(highlighterAction:)];*/
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
//    theMenu.menuItems = [NSArray arrayWithObjects:menuItem1, menuItem4, nil];
    [theMenu setMenuVisible:YES animated:YES];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.dataSourceType == 0)
        return NO;
    
    if (action == @selector(copy:))
    {
        return YES;
    }
    return NO;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)copy:(id)sender
{
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    NSData * data = [[self.textView getSelectedText:NO] dataUsingEncoding:NSUTF8StringEncoding];
    [newPasteboardContent setObject:data forKey:@"public.text"];
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
}

-(void)endlessTextView:(UIView *)textView swipeRight:(CGPoint)point
{
    [self buttonCloseClicked:self];
}

-(void)endlessTextView:(UIView *)textView swipeLeft:(CGPoint)point
{
    [self buttonCloseClicked:self];
}

-(void)navigateToRecord:(int)recId
{
    if (self.dataSourceType == 0)
        return;
    
    self.lastRecordNavigated = recId;
    
    FDRecordBase * rb = [self.searchManager getRawRecord:recId];
    
    [self.textView refreshPartWithRecordId:[self.searchManager setRecordVisited:recId]];
    
    [self.userInterfaceManager loadRecord:rb.linkedRecordId useHighlighting:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hitsBar:shouldHide:)])
    {
        [self.delegate hitsBar:self shouldHide:YES];
    }
}

-(void)navigateToPrevRecord
{
    if (self.lastRecordNavigated > 1)
    {
        [self navigateToRecord:self.lastRecordNavigated - 2];
        [self.textView setCurrentRecord:(self.lastRecordNavigated - 2) offset:0.0];
    }
}

-(void)navigateToNextRecord
{
    if (self.lastRecordNavigated < self.searchManager.results.count - 2)
    {
        [self navigateToRecord:self.lastRecordNavigated + 2];
        [self.textView setCurrentRecord:self.lastRecordNavigated offset:0.0];
    }
}

-(void)endlessTextView:(UIView *)textView topRecordChanged:(int)recordId
{
}

-(void)endlessTextViewTapWithoutSelection:(UIView *)textView
{
}

@end

