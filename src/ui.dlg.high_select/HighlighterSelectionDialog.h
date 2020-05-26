//
//  HighlighterSelectionDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import "VBDialogController.h"

@interface HighlighterSelectionDialog : VBDialogController<TGTabBarTouches>

@property (nonatomic,retain) IBOutlet TGTouchArea * grayBack;
- (IBAction)onSelectOrange:(id)sender;
- (IBAction)onSelectPurple:(id)sender;
- (IBAction)onSelectBlue:(id)sender;

- (IBAction)onSelectClear:(id)sender;
- (IBAction)onBackButton:(id)sender;
- (IBAction)onSelectYellow:(id)sender;
- (IBAction)onSelectGreen:(id)sender;
- (IBAction)onSelectCyan:(id)sender;
- (IBAction)onSelectRed:(id)sender;
- (IBAction)onSelectMagenta:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *buttonsContainerView;

@end
