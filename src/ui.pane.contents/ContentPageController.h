//
//  VCContent2.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/29/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolioSelectDialog.h"
#import "ContentTableController.h"
#import "VBMainServant.h"
#import "ContentPageDelegate.h"
#import "VBAlertDelegate.h"

@class VBContentManager, VBUserInterfaceManager;

@interface ContentPageController : UIViewController <UIPopoverControllerDelegate, UIGestureRecognizerDelegate, VBAlertDelegateDelegate> {

	UITableView * contentTable;
    UIView * headView;
	ContentTableController * tableController;
    VBFolio * folioToSet;
    
    BOOL isFullScreen;
}

@property id<ContentPageDelegate> delegate;

@property (nonatomic,retain) ContentTableController * tableController;
@property (nonatomic,retain) IBOutlet UITableView * contentTable;
@property (nonatomic,retain) IBOutlet UIView * headView;
@property IBOutlet UIButton * closeButton;
@property IBOutlet UIButton * helpButton;
@property (nonatomic, strong) UIPopoverController * popoverFolioController;
@property VBContentManager * contentManager;
@property VBUserInterfaceManager * userInterfaceManager;
@property VBAlertDelegate * alertDelegate;
@property int startingRecord;
@property NSURLRequest * pendingRequest;

-(IBAction)closeWindow:(id)sender;
-(IBAction)showHelpPage:(id)sender;
-(void)setPageTitle:(NSString *)aTitle;
-(void)setPageImage:(UIImage *)anImage;
-(void)setFolio:(VBFolio *)ifolio;
-(void)saveUIState;
-(void)restoreUIState;

@end
