//
//  VCText.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VCText.h"
#import "VBFolio.h"
#import "TextHighlighter.h"
#import "FlatFileUtils.h"
#import "TGTabController.h"
#import "TextStyleViewController.h"
#import "HighlighterSelectionDialog.h"
#import "EditNoteDialogController.h"
#import "VBDimensions.h"
#import "BookmarkIntroDialog.h"
#import "BookmarksEditorDialog.h"
#import "GetUserStringDialog.h"
#import "VBSearchManager.h"
#import "VBTextHistoryManager.h"
#import "VBUserInterfaceManager.h"
#import "FDCharFormat.h"
#import "FDTypeface.h"

@implementation VCText


-(id)init
{
    self = [super init];
    if (self) {
        [self myInit];
    }
    return self;
}
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        [self myInit];
    }
    return self;
}

-(void)myInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyFolioOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyCmdOpenUrl object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyCmdShowHtml object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyCmdEditNote object:nil];
    
}


-(void)toogleFullScreen
{
    [self refreshFullScreen];
}

-(void)refreshFullScreen
{
    /*if (isFullScreen) {
        
        CGRect frame = [self.view frame];
//        CGRect frameWeb = [self.webView frame];
        CGRect newRect = CGRectMake(frame.origin.x + webViewMarginLeft, frame.origin.y,
                                    frame.size.width - webViewMarginLeft - webViewMarginRight, frame.size.height);
        [self.webView setFrame:newRect];
    } else {
        CGRect frame = [self.view frame];
        CGRect frame2 = [self.titleBackgView frame];
        CGRect newRect = CGRectMake(frame.origin.x + webViewMarginLeft, frame2.origin.y + frame2.size.height,
                                    frame.size.width - webViewMarginLeft - webViewMarginRight, frame.size.height - (frame2.origin.y + frame2.size.height));
        [self.webView setFrame:newRect];
    }*/
}

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyFolioOpen])
    {
        VBFolio * folio = [note.userInfo objectForKey:@"folio"];
        if (folio)
        {
            [self setFolio:folio];
        }
        self.textView.skinDelegate = [VBMainServant instance].skinManager;
    }
    else if ([note.name isEqualToString:kNotifyCmdOpenUrl])
    {
        NSString * script;
        NSURLRequest * request = [note.userInfo objectForKey:@"request"];
        if (request != nil)
        {
            NSLog(@"VCText::openURLRequest(%@)", request);
            //[webView loadRequest:request];
        } else {
            script = [note.userInfo objectForKey:@"script"];
            if (script != nil)
            {
                //[webView stringByEvaluatingJavaScriptFromString:script];
            }
        }
    }
    else if ([note.name isEqualToString:kNotifyCmdShowHtml])
    {
        [self showPopupWithHtmlText:[note.userInfo objectForKey:@"html"]];
    }
    else if ([note.name isEqualToString:kNotifyCmdEditNote])
    {
        NSString * str = [[note.userInfo objectForKey:@"record"] description];
        [self editNote:[str intValue]];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.view setBackgroundColor:[VBMainServant colorForName:@"bodyBackground"]];
    
    
    //[self.btnBack setImage:[VBMainServant imageForName:@"hdr_text_back"]
    //              forState:UIControlStateNormal];
    //[self.btnForw setImage:[VBMainServant imageForName:@"hdr_text_fwd"]
    //              forState:UIControlStateNormal];

   
    /*UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [webView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [webView addGestureRecognizer:swipeLeft];
    
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchgestureAction:)];

    pinch.delegate = self;
    [webView addGestureRecognizer:pinch];*/
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewDidDisappear:(BOOL)animated
{
    UIMenuController * menu = [UIMenuController sharedMenuController];
    menu.menuItems = nil;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)swipeRightAction:(id)ignored
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"use_swipe"])
    {
        [[VBMainServant instance].tabController selectBarItemWithTag:1 direction:TGTabItemTransitionLeftToRight];
    }
}

- (void)swipeLeftAction:(id)ignored
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"use_swipe"])
    {
        [[VBMainServant instance].tabController selectBarItemWithTag:3 direction:TGTabItemTransitionRightToLeft];
    }
}

-(void)setFolio:(VBFolio *)folio
{
    [self validateHistoryButtons];
    
    ETVDirectSource * ds = [[ETVDirectSource alloc] init];
    ds.folio = folio;
    
    self.folioSource = ds;
    self.textView.dataSource = ds;
    //self.textView.delegate = self;
    [self.textView setNeedsDisplay];
}

-(void)onErrorUnreachableDestination:(NSString *)dest
{
    [self performSelector:@selector(hideLoadingNote) withObject:nil afterDelay:0.4];
    NSString * messageText = [NSString stringWithFormat:@"Target of this link is not available, because it is in different folio package which you did not load. Unavailable target: %@", dest];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Trying to reach another package?" message:messageText delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

-(void)performLinkAction:(NSString *)path
{
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
    
}

-(void)asyncLoadPageWithHighlight:(NSNumber *)recNum
{
    [self loadRecord:[recNum integerValue] useHighlighting:YES];
}

-(void)asyncLoadPageWithoutHighlight:(NSNumber *)recNum
{
    [self loadRecord:[recNum integerValue] useHighlighting:NO];
}

-(void)loadRecord:(NSUInteger)globalRecordId useHighlighting:(BOOL)bUseHigh
{
    [self.textView setCurrentRecord:(int)globalRecordId];
    [self.userInterfaceManager validateHistoryButtons];
}

-(void)loadRecordWithDictionary:(NSDictionary *)arguments
{
    NSUInteger globalRecordId = [(NSNumber *)[arguments valueForKey:@"record"] unsignedIntegerValue];
    BOOL bUseHigh = [(NSNumber *)[arguments valueForKey:@"highlight"] boolValue];
    
	NSData * data = nil;
    VBMainServant * servant = [VBMainServant instance];
	VBFolio *folio = servant.currentFolio;
    
    if (folio == nil)
        return;

    // hiding popup if showed previously
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCmdCloseAllDialogs object:nil];

    @try {
        data = [folio dataForRecordRange:(NSUInteger)globalRecordId];
        
        if (bUseHigh)
        {
            TextHighlighter * tHigh = [[TextHighlighter alloc] initWithPhraseSet:[self.searchManager phrases]];
            data = [tHigh highlightSearchWords:data];
            //[tHigh release];
        }
        
        //self.followUpLink = [NSString stringWithFormat:@"gotoElement('rec%d')", globalRecordId];

        NSDictionary * showData = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", @"text/html", @"mime", @"utf-8", @"code", nil];
        [self performSelector:@selector(loadRecordWillShow:)
                   withObject:showData
                   afterDelay:0.0];
        //	self.btnBack.alpha = [servant canGoBack];
        //	self.btnForw.alpha = [servant canGoForward];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }


}

-(void)loadRecordWillShow:(NSDictionary *)args
{
    //[webView loadData:[args valueForKey:@"data"]
    //         MIMEType:[args valueForKey:@"mime"]
    // textEncodingName:[args valueForKey:@"code"]
    //          baseURL:[VBMainServant fakeURL]];
    [self validateHistoryButtons];
}

-(void)loadCustomURLData:(NSURLRequest *)request
{
	NSURL *url = [request URL];
	VBFolio *folio = [[VBMainServant instance] currentFolio];
	NSString * path = [url path];
	NSString * normalPath = ([path hasPrefix:@"/"]) ? [path substringFromIndex:1] : path;
	NSString * host = [url host];

	if ([host isEqual:@"files"] || [host isEqual:@"search"])
	{
		NSScanner * scan = [NSScanner scannerWithString:normalPath];
		int i32;
		BOOL success = NO;
		if ([scan scanInt:&i32] == YES)
		{
            if (i32 < [[folio firstStorage] findTextCount])
            {
                [self loadRecord:i32  useHighlighting:([host isEqualToString:@"files"] ? NO : YES)];
                success = YES;
            }
		}
        
        if (success == NO)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Trying to reach another package?" message:@"Target of this link is not available, because it is in different folio package which you did not load." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            
            [alert show];
        }
	}
	else if ([host isEqual:@"links"])
	{
		[self performLinkAction:path];
	}
	else if ([host compare:@"popup"] == NSOrderedSame)
	{
		NSString * str = [folio htmlTextForPopup:[FlatFileUtils decodeLinkSafeString:normalPath]];
        [self showPopupWithHtmlText:str];
	}
    else if ([host compare:@"note"] == NSOrderedSame)
    {
        uint32_t recId = [[path substringFromIndex:1] intValue];
        NSString * str = [folio htmlTextForNoteRecord:recId];
        ShowNoteViewController * vnc = [self createNoteViewDialogController];
        [vnc setNoteRecordId:recId];
        [vnc.popupWebView loadHTMLString:str baseURL:[VBMainServant fakeURL]];
        //[self showPopupWithHtmlText:str];
    }
    else if ([host compare:@"editnote"] == NSOrderedSame)
    {
        [self editNote:[[path substringFromIndex:1] intValue]];
    }
    else if ([host compare:@"inlinepopup"] == NSOrderedSame) {
        NSArray * pathComponents = [normalPath componentsSeparatedByString:@"/"];
        if ([pathComponents count] > 2) {
            NSString * linkType = [pathComponents objectAtIndex:0];
            NSString * objectID = [pathComponents objectAtIndex:1];
            NSString * popupNumber = [pathComponents objectAtIndex:2];
            //NSString * htmlText = @"";
            NSString * htmlBody = @"";
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            if ([linkType compare:@"RD"] == NSOrderedSame) {
                htmlBody = [folio text:[objectID intValue] 
                                   forPopupNumber:[popupNumber intValue]];
            } else if ([linkType compare:@"DP"] == NSOrderedSame) {
                htmlBody = [folio htmlTextForPopup:[FlatFileUtils decodeLinkSafeString:objectID]
                                    forPopupNumber:[popupNumber intValue]];
            }
            /*int bodySize = [defaults integerForKey:@"bodySize"];
            bodySize = bodySize < 5 ? 14 : bodySize;
            htmlText = [NSString stringWithFormat:@"<body style=\"font-size:%dpt\" background=\"vbase://stylist_images/background_yellow\">%@</body>", bodySize, htmlBody];*/
            [self showPopupWithHtmlText:htmlBody];
        }
    }
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
	navigationType:(UIWebViewNavigationType)navigationType
{
	NSString * strScheme = [[request URL] scheme];
	
	if ([strScheme isEqual:@"vbase"])
	{
		[self loadCustomURLData:request];
		return NO;
	}
	else if ([strScheme isEqual:@"http"] || [strScheme isEqual:@"https"] || [strScheme isEqual:@"file"])
	{
		return YES;
	}
	return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)iwebView
{
    [self performSelector:@selector(hideLoadingNote) withObject:nil afterDelay:0.4];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self performSelector:@selector(hideLoadingNote) withObject:nil afterDelay:0.4];
}

-(void)showLoadingNote:(NSString *)text
{
}

-(void)hideLoadingNote
{
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.textView setNeedsDisplay];
}

#pragma mark -
#pragma mark History Buttons

-(void)validateHistoryButtons
{
    [self.userInterfaceManager validateHistoryButtons];
}

-(IBAction)onGoBack:(id)sender
{
	if ([self.textHistoryManager canGoBack])
	{
		NSUInteger ui = [self.textHistoryManager historyGetPrev];
		if (ui == NSNotFound) return;
		[self loadRecord:ui useHighlighting:NO];
	}
}

-(IBAction)onGoForward:(id)sender
{
	if ([self.textHistoryManager canGoForward])
	{
		NSUInteger ui = [self.textHistoryManager historyGetNext];
		if (ui == NSNotFound) return;
		[self loadRecord:ui useHighlighting:NO];
	}
}

#pragma mark -
#pragma mark Menu actions

-(IBAction)increaseText:(id)sender
{    
    VBFolio * folio = [[VBMainServant instance] currentFolio];
    
    if (folio.bodyFontSize == 0)
        return;
    if (folio.bodyFontSize < 40)
        folio.bodyFontSize++;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:folio.bodyFontSize forKey:@"bodySize"];
    [defaults synchronize];
}

-(IBAction)decreaseText:(id)sender
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];

    if (folio.bodyFontSize == 0)
        return;
    if (folio.bodyFontSize > 5)
        folio.bodyFontSize--;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:folio.bodyFontSize forKey:@"bodySize"];
    [defaults synchronize];
}



-(void)setBodyFont:(NSString *)aFontFace
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aFontFace forKey:@"bodyFont"];
    [defaults synchronize];
    
    folio.bodyFontFamily = aFontFace;
}

-(IBAction)increaseLineSpacing:(id)sender
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];

    if (folio.bodyLineSpacing > 199) {
        folio.bodyLineSpacing = 200;
    } else if (folio.bodyLineSpacing > 149) {
        folio.bodyLineSpacing = 200;
    } else if (folio.bodyLineSpacing > 119) {
        folio.bodyLineSpacing = 150;
    } else if (folio.bodyLineSpacing > 99) {
        folio.bodyLineSpacing = 120;
    } else {
        folio.bodyLineSpacing = 100;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:folio.bodyLineSpacing forKey:@"bodyLineHeight"];
    [defaults synchronize];
    
}

-(IBAction)decreaseLineSpacing:(id)sender
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];

    if (folio.bodyLineSpacing > 199) {
        folio.bodyLineSpacing =150;
    } else if (folio.bodyLineSpacing > 149) {
        folio.bodyLineSpacing = 120;
    } else if (folio.bodyLineSpacing > 119) {
        folio.bodyLineSpacing = 100;
    } else {
        folio.bodyLineSpacing = 100;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:folio.bodyLineSpacing forKey:@"bodyLineHeight"];
    [defaults synchronize];

}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark Edit menu handlers

-(NSString *)addReferenceToPlainText:(NSString *)originalText
{
    //return [NSString stringWithFormat:@"%@\n[Reference: %@]\n", originalText, self.referenceView.text];
    return @"";
}

-(NSString *)addReferenceToHtmlText:(NSString *)originalText
{
    //return [NSString stringWithFormat:@"%@<p align=right>[Reference: %@]</p>", originalText, self.referenceView.text];
    return @"";
}


-(void)copyWithReference:(id)sender
{
    NSString * webArchiveType = @"Apple Web Archive pasteboard type";
    [[UIApplication sharedApplication] sendAction:@selector(copy:) to:nil from:self forEvent:nil];
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    NSArray * types = paste.pasteboardTypes;
    for(NSString * s in types)
    {
        if ([s compare:@"public.text"] == NSOrderedSame)
        {
            NSData * data = [paste dataForPasteboardType:s];
            NSString * strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [newPasteboardContent setObject:[self addReferenceToPlainText:strData] forKey:@"public.text"];
            //[strData release];
        }
        else if ([s compare:webArchiveType] == NSOrderedSame)
        {
            NSData* archiveData = [[UIPasteboard generalPasteboard] valueForPasteboardType:webArchiveType];
            if (archiveData)
            {
                NSError* error = nil;
                id webArchive = [NSPropertyListSerialization propertyListWithData:archiveData options:NSPropertyListImmutable format:NULL error:&error];
                if (error) {
                    return;
                }
                NSMutableDictionary *mainCopy = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)webArchive];
                NSMutableDictionary *subItems = [NSMutableDictionary dictionaryWithDictionary:[mainCopy objectForKey:@"WebMainResource"]];
                NSData * data = [subItems objectForKey:@"WebResourceData"];
                NSString * html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [subItems setObject:[[self addReferenceToHtmlText:html] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"WebResourceData"];
                [mainCopy setObject:subItems forKey:@"WebMainResource"];
                //[html release];
                [newPasteboardContent setObject:mainCopy forKey:webArchiveType];
            }
        }
    }
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
    //[newPasteboardContent release];
}


-(void)editNote:(int)recId
{
    VBFolio * folio = [[VBMainServant instance] currentFolio];
    
    VBRecordNotes * noterec = [folio createNoteForRecord:recId];
    
    EditNoteDialogController * editNoteDlg = [[EditNoteDialogController alloc] initWithNibName:@"EditNoteDialogController" bundle:nil];
    
    if ([noterec.recordPath length] == 0)
    {
        noterec.recordPath = [folio findDocumentPath:recId];
    }
    //editNoteDlg.delegate = self;
    editNoteDlg.selectedObject = noterec;
    editNoteDlg.globalRecordID = recId;
    //[[VBMainServant mainWindow].rootViewController.view addSubview:editNoteDlg.view];
    [[VBMainServant instance] showDialog:editNoteDlg];
}

-(void)createNote:(id)sender
{
    int iFromCharIndex;
    int iToCharIndex;
    int fromGlobRecId;
    int toGlobRecId;
    
    if ([self getSelectedRangeOfTextStartRec:&fromGlobRecId
                                  startIndex:&iFromCharIndex
                                      endRec:&toGlobRecId
                                    endIndex:&iToCharIndex])
    {
        [self editNote:fromGlobRecId];
    }
}

-(void)highlightPartOfText:(id)sender
{
    HighlighterSelectionDialog * sel = [[HighlighterSelectionDialog alloc] initWithNibName:@"HighlighterSelectionDialog" bundle:nil];
    sel.delegate = self.userInterfaceManager;
    //[[VBMainServant mainWindow].rootViewController.view addSubview:sel.view];
    [[VBMainServant instance] showDialog:sel];
}

-(BOOL)getSelectedRangeOfTextStartRec:(int *)pFromGlobRecId startIndex:(int *)pStartIndex endRec:(int *)pToGlobRecId endIndex:(int *)pEndIndex
{
    return NO;
}

-(void)highlightText:(int)highlighterId
{
    int iFromCharIndex;
    int iToCharIndex;
    int fromGlobRecId;
    int toGlobRecId;
    
    if ([self getSelectedRangeOfTextStartRec:&fromGlobRecId
                                  startIndex:&iFromCharIndex
                                      endRec:&toGlobRecId
                                    endIndex:&iToCharIndex])
    {
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
            [self refreshParagraphInText:i folio:currentFolio];
        }
    }
    
}

-(void)refreshParagraphInText:(int)recId folio:(VBFolio *)currentFolio
{
    NSString * paras = [currentFolio text:recId];
    paras = [paras stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    paras = [paras stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  
}

#pragma mark -
#pragma mark Dialog Window Creators

-(ShowNoteViewController *)createNoteViewDialogController
{
    ShowNoteViewController * vc = [[ShowNoteViewController alloc] initWithNibName:@"ShowNoteViewController" bundle:nil];
//    vc.popupBase = self.popupBase;
    //vc.view.frame = webView.frame;
    //[[VBMainServant mainWindow].rootViewController.view addSubview:vc.view];
    [[VBMainServant instance] showDialog:vc];
    return vc;
}

-(void)showPopupWithHtmlText:(NSString *)htmlText
{
    ShowNoteViewController * vnc = [self createNoteViewDialogController];
    [vnc.popupWebView loadHTMLString:htmlText baseURL:[VBMainServant fakeURL]];
}


#pragma mark -
#pragma mark Dialog Window Callbacks

-(IBAction)onTabButtonPressed:(id)sender
{
    if ([sender isKindOfClass:[TGTouchArea class]])
    {
        TGTouchArea * tar = (TGTouchArea *)sender;
        if ([tar.touchCommand isEqualToString:@"fontSize-"]) {
            [self decreaseText:sender];
        } else if ([tar.touchCommand isEqualToString:@"fontSize+"]) {
            [self increaseText:sender];
        } else if ([tar.touchCommand isEqualToString:@"lineSpace+"]) {
            [self increaseLineSpacing:sender];
        } else if ([tar.touchCommand isEqualToString:@"lineSpace-"]) {
            [self decreaseLineSpacing:sender];
        } else if ([tar.touchCommand isEqualToString:@"fontTypeSans"]) {
            [self setBodyFont:@"Helvetica"];
        } else if ([tar.touchCommand isEqualToString:@"fontTypeSerif"]) {
            [self setBodyFont:@"Times"];
        }
    }
}

-(IBAction)onTabButtonReleased:(id)sender
{
    if ([sender isKindOfClass:[TGTouchArea class]])
    {
        TGTouchArea * tar = (TGTouchArea *)sender;
        if ([tar.touchCommand isEqualToString:@"closePopup"])
        {
        } else {
        }
    }
}

-(IBAction)onTabButtonReleasedOut:(id)sender
{
    if ([sender isKindOfClass:[TGTouchArea class]])
    {
        TGTouchArea * tar = (TGTouchArea *)sender;
        if ([tar.touchCommand isEqualToString:@"closePopup"])
        {
        } else {
        }
    }
}

-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData
{
    if ([command isEqualToString:@"highlightText"])
    {
        if ([aData valueForKey:@"highlighterId"])
        {
            [self highlightText:[(NSNumber *)[aData valueForKey:@"highlighterId"] intValue]];
        }
    }
    else if ([command isEqualToString:@"refreshRecord"])
    {
        if ([aData valueForKey:@"record"])
        {
            int recid = [(NSNumber *)[aData valueForKey:@"record"] intValue];
            VBFolio * folio = [[VBMainServant instance] currentFolio];
            [self refreshParagraphInText:recid folio:folio];
            
            [folio.firstStorage refreshRecordData:recid];
            [self.textView setNeedsDisplay];
        }
    }
    else if ([command isEqualToString:@"setNeedsDisplay"])
    {
        [self.textView setNeedsDisplay];
    }
    else if ([command isEqualToString:@"textSize-"])
    {
        [self decreaseText:self];
    }
    else if ([command isEqualToString:@"textSize+"])
    {
        [self increaseText:self];
    }
    else if ([command isEqualToString:@"lineSpace+"]) {
        [self increaseLineSpacing:self];
    }
    else if ([command isEqualToString:@"lineSpace-"]) {
        [self decreaseLineSpacing:self];
    }
    else if ([command isEqualToString:@"fontTypeSansSerif"]) {
        [self setBodyFont:@"Helvetica"];
    }
    else if ([command isEqualToString:@"fontTypeSerif"]) {
        [self setBodyFont:@"Times"];
    }
    else if ([command isEqualToString:@"showBookmarks"]) {
    }
}



#pragma mark -
#pragma mark Popover Test Style delegate


-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}


#pragma mark -
#pragma mark Endless Text View Delegate





@end
