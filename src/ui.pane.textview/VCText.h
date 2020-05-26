//
//  VCText.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBMainServant.h"
#import "TGTabController.h"
#import "ShowNoteViewController.h"
#import "EndlessTextView.h"
#import "ETVDirectSource.h"

@class VBSearchManager, VBTextHistoryManager, VBUserInterfaceManager;

@interface VCText : UIViewController

@property (weak) EndlessTextView * textView;
@property (weak) VBTextHistoryManager * textHistoryManager;
@property (weak) VBUserInterfaceManager * userInterfaceManager;
@property (weak) VBSearchManager * searchManager;
@property (nonatomic,readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;

@property ETVDirectSource * folioSource;

-(void)loadRecord:(NSUInteger)globalRecordId  useHighlighting:(BOOL)bUseHigh;
-(void)validateHistoryButtons;

-(IBAction)onGoBack:(id)sender;
-(IBAction)onGoForward:(id)sender;

-(void)showPopupWithHtmlText:(NSString *)htmlText;

-(void)setFolio:(VBFolio *)folio;
-(void)onErrorUnreachableDestination:(NSString *)dest;


@end
