//
//  VCHits2.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/22/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBMainServant.h"
#import "VBFolio.h"
#import "SearchKeyboardAccessoryView.h"
#import "CIModel.h"
#import "SearchAdvancedDialog.h"
#import "VCHitsDelegate.h"
#import "EndlessScrollView.h"
#import "EndlessTextView.h"
#import "EndlessTextViewDelegate.h"
#import "VDTreeItem.h"

@class VBSearchManager,VBSkinManager;

@interface VCHits2 : UIViewController <UIWebViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,EndlessTextViewDelegate>

@property id<VCHitsDelegate> delegate;
@property VBUserInterfaceManager * userInterfaceManager;
@property VBSearchManager * searchManager;
@property VBSkinManager * skinManager;
@property int dataSourceType;
@property (strong) NSMutableDictionary * attribWord;
@property (strong) NSDictionary * attribBold;
@property (strong) NSAttributedString * attrStrDots;
@property (strong) SearchAdvancedDialog * searchDialog;
@property IBOutlet UIView * headerBannerView;
@property IBOutlet EndlessScrollView * textView;
//@property IBOutlet EndlessTextView * textView2;
//@property IBOutlet UIScrollView * textScrollView;
//@property IBOutlet UIWebView * webView;
@property IBOutlet UILabel * resultsCountLabel;
@property IBOutlet UIView * progressBanner;
@property int lastRecordNavigated;

//@property IBOutlet UIImageView * headerBackgroundImageView;
@property (nonatomic, strong) CIModel * folioContent;
@property (nonatomic, strong) SearchKeyboardAccessoryView * keyboardAccessoryViewController;

@property NSInteger lastPinchFontSize;
@property NSInteger pinchFontSizeStart;


-(IBAction)buttonClearClicked:(id)sender;
-(IBAction)buttonCloseClicked:(id)sender;

-(void)navigateToPrevRecord;
-(void)navigateToNextRecord;

-(void)setFolio:(VBFolio *)folio;

@end
