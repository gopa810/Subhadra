//
//  VBAudioControllerDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import "VBSkinManager.h"
#import "VBUserInterfaceManager.h"
#import "VBDialogController.h"
#import "HeaderBar.h"

@interface VBAudioControllerDialog : VBDialogController <TGTabBarTouches>

@property (weak) VBSkinManager * skinManager;
@property (weak) VBUserInterfaceManager * userInterfaceManager;

@property IBOutlet HeaderBar * backView;
@property IBOutlet HeaderBar * timeBackView;
@property IBOutlet TGTouchArea * btnBack;
@property IBOutlet TGTouchArea * btnPlay;
@property IBOutlet TGTouchArea * btnStop;
@property IBOutlet TGTouchArea * btnFwd;
@property IBOutlet UILabel * fileNameLabel;
@property IBOutlet UILabel * timeLabel;
@property NSInteger buttonPauseMode;
@property NSTimer * timer;

@end
