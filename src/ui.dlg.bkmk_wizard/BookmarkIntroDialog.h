//
//  BookmarkIntroDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import "VBDialogController.h"

@interface BookmarkIntroDialog : VBDialogController
@property (retain, nonatomic) IBOutlet TGTouchArea *touchArea;
@property (assign) uint32_t recordId;
@property (assign) uint32_t globalRecordId;
@property (retain, nonatomic) IBOutlet UISwitch *modeSwitchButton;

- (IBAction)onCancel:(id)sender;
- (IBAction)onBookmarkAdd:(id)sender;
- (IBAction)onGotoBookmark:(id)sender;
- (IBAction)onBookmarkUpdate:(id)sender;

@end
